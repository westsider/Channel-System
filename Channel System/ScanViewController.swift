//
//  ScanViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation
import RealmSwift
import UIKit

class ScanViewController: UIViewController {
    
    @IBOutlet weak var lastUpdateLable: UILabel!
    
    @IBOutlet weak var currentProcessLable: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var circleImage: UIImageView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var tradeButton: UIButton!
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let infoBlock = { print( "\nCompany Info Returned <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    let mcBlock = { print( "\nMarket Condition block finished  <----------\n" ) }
    
    let prices = Prices()
    var updatedProgress: Float = 0
    var incProgress: Float = 0
    var counter:Int = 0
    var updateRealm:Bool = false
    var lastDateInRealm:Date!
    var galaxie = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finance"
        tradeButton(isOn: false)
        updateButton(isOn: false)
        ManualTrades().showProfit()
        // iphone 7+ Sim is  192397        
        //MarketCondition().calcMarketCondFirstRun(debug: true, completion: mcBlock) // needs a completion handler
        _ = SpReturns().textForStats(yearEnding: 2007)
        _ = SpReturns().textForStats(yearEnding: 2017)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if  UserDefaults.standard.object(forKey: "FirstRun") == nil  {
            firstRun()
        } else {
            subsequentRuns()
        }
    }
    
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func saveCompanyInfoToRealm() {
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        for ticker in galaxie {
            CompanyData().getInfoFor(ticker: ticker, debug: false, completion: self.infoBlock)
        }
    }
    
    private func firstRun() {
        lastUpdateLable.text = "First run of app."
        print("\nThis was first run so I will load CSV historical data\n")
        initially(deleteAll: true, printPrices: false, printTrades: false)
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        initProgressBar()
        self.updateUI(with: "Cleaning CSV Data...", spinIsOff: true)
        GetCSV().areTickersValid(megaSymbols: galaxie)
        getDataFromCSV(completion: self.csvBlock) // get entries crash on first run, lastUpdateInRealm = Nil
        checkDuplicates()
        saveCompanyInfoToRealm()
        MarketCondition().calcMarketCondFirstRun(debug: true, completion: mcBlock)
        UserDefaults.standard.set(false, forKey: "FirstRun")
    }
    
    private func subsequentRuns() {
        print("\nThis is NOT the first run.\n")
        updateRealm = Utilities().realmNotCurrent(debug: false)
        lastDateInRealm = Prices().getLastDateInRealm(debug: false)
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        currentProcessLable.text = LastUpdate().checkUpate()
        activity.stopAnimating()
        tradeButton(isOn: true)
        updateButton(isOn: true)
    }

    @IBAction func getNewDataAction(_ sender: Any) {
        //MARK: - get new data
        LastUpdate().incUpdate()
        getDataFromDataFeed(debug: false, completion: self.datafeedBlock)
    }
    
    @IBAction func manageTradesAction(_ sender: Any) {
        updateUI(with: "Calculating Performance", spinIsOff: false)
        segueToCandidatesVC()
    }
    
    private func getRealmFrom(ticker: String, DateString: String) {
        let specificNSDate = Utilities().convertToDateFrom(string: DateString, debug: false)
        let realm = try! Realm()
        let predicate = NSPredicate(format: "date == %@", specificNSDate as CVarArg)
        let results = realm.objects(Prices.self).filter(predicate)
        print("/nEntries to make:")
        for each in results {
            if ( each.ticker == ticker)  {
                print("\(each.ticker) \(each.dateString) \(each.close)  \(each.taskID)")
                let close:Double = each.close
                let stop:Double = TradeHelpers().calcStopTarget(ticker: each.ticker, close: close, debug: false).0
                let target:Double = TradeHelpers().calcStopTarget(ticker: each.ticker, close: close, debug: false).1
                let stopDistance:Double = TradeHelpers().calcStopTarget(ticker: each.ticker, close: close, debug: false).2
                let currentRisk = Account().currentRisk()
                let shares:Int = TradeHelpers().calcShares(stopDist: stopDistance, risk: currentRisk)
                let stopString:String = TradeHelpers().stopString(stop: stop)
                let capReq:Double = TradeHelpers().capitalRequired(close: close, shares: shares)
                let message:String = "Entry:\(close)\tShares:\(shares)\nStop:\(stopString)\tTarget:\(String(format: "%.2f", target))"; print(message)
                RealmHelpers().makeEntry(taskID: each.taskID, entry: each.close, stop: stop, target: target, shares: shares, risk: Double(currentRisk), debug: false, account: "Test Account", capital: capReq)
            }
        }
    }
    
    private func initially(deleteAll: Bool, printPrices: Bool, printTrades: Bool){
        if ( deleteAll ) { RealmHelpers().deleteAll() }
        if ( printPrices ) { Prices().printLastPrices(symbols: galaxie, last: 4) }
        if ( printTrades ) { RealmHelpers().printOpenTrades() }
    }
    
    //MARK: - Trade Management
    private func manageTradesOrShowEntries(debug:Bool) {
        // search for trade management scenario else segue to candidates
        let tasks = RealmHelpers().getOpenTrades()
        print("Open trade count is \(tasks.count)")
        if ( tasks.count > 0) {
            for trades in tasks {
                //MARK: - TODO - Check if stop
                if trades.close < trades.stop {
                    if debug { print("\nStop Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Stop")
                }
                //MARK: - TODO - Check if target
                if trades.close > trades.target {
                    if debug { print("\nTarget Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Target")
                }
                if trades.wPctR > -30 {
                    if debug { print("\nwPctR Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Pct(R) Target")
                }
                //MARK: - TODO - Set up exit date on entry
                if Date() >= trades.exitDate {
                    if debug { print("\nTime Stop Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Date Stop")
                }
            }
        } else {
            // exit here if no entries found
            segueToCandidatesVC()
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    //MARK: - Get Data From CSV
    private func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Getting local data for \(symbols) \(index+1) of \( self.galaxie.count)", spinIsOff: false)
                DataFeed().getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
            }
            self.updateUI(with: "All tickers have been downloaded!", spinIsOff: true)
            self.calcSMA10(completion: self.smaBlock2)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - Get Data From Datafeed
    private func getDataFromDataFeed(debug: Bool, completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Getting remote data for \(symbols) \(index+1) of \( self.galaxie.count)", spinIsOff: false)
                DataFeed().getLastPrice(ticker: symbols, lastInRealm: self.lastDateInRealm, debug: false, completion: {
                    self.counter += 1
                    if ( debug ) { print("\n----> counter: \(self.counter) universe: \(self.galaxie.count) <----\n") }
                    if ( self.counter == self.galaxie.count ) {
                        self.updateUI(with: "All remote data has been downloaded!\n", spinIsOff: true)
                        self.calcSMA10(completion: self.smaBlock2)
                    }
                })
            }
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - SMA 10
    private func calcSMA10(completion: @escaping () -> ()) {
        self.updateUI(with: "Calulating SMA(10)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing SMA(10) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, priorCount: oneTicker.count, prices: oneTicker, redoAll: false, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(10) for \(symbols)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(10) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcSMA200(completion: self.smaBlock2)
            }
        }
    }
    //MARK: - SMA 200
    private func calcSMA200(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing SMA(200)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing SMA(200) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, priorCount: oneTicker.count, prices: oneTicker, redoAll: false, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(200) for \(symbols)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(200) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcwPctR(completion: self.wPctRBlock)
            }
        }
    }
    //MARK: - wPctR
    private func calcwPctR(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing PctR...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing PctR for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(priorCount: oneTicker.count, debug: false, prices: oneTicker, redoAll: false, completion: self.wPctRBlock)
                self.updateUI(with: "Finished Processing PctR for \(symbols)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SPctR Complete", spinIsOff: true)
                self.calcEntries(completion: self.entryBlock)
                MarketCondition().calcMarketCondUpdate(debug: true)
            }
        }
    }
    //MARK: - Entries
    private func calcEntries(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing Entries...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing Entries for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                if ( self.lastDateInRealm != nil ) {
                    Entry().calcLong(lastDate: self.lastDateInRealm, debug: false, prices: oneTicker, completion: self.entryBlock)
                } else {
                    // if first run when lastDateInRealm == nil and i need to load all symbols
                    // so i will pass in the first date in the CSV
                    let firstDate  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false)
                    Entry().calcLong(lastDate: firstDate, debug: false, prices: oneTicker, completion: self.entryBlock)
                }
                self.updateUI(with: "Finished Processing Entries for \(symbols)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing Entries Complete", spinIsOff: true)
                self.manageTradesOrShowEntries(debug: false)
            }
        }
    }
    
    private func updateUI(with: String, spinIsOff: Bool) {
        DispatchQueue.main.async {
            //print(with)
            self.lastUpdateLable.text =  with
            
            if spinIsOff {
                self.activity.stopAnimating()
                
            } else {
                self.activity.startAnimating()
            }
        }
    }
    
    private func initProgressBar() {
        let tickerCount:Double = Double(galaxie.count)
        let processCount:Double = Double(5)
        let divisor:Double = Double(1)
        incProgress = Float( divisor / (tickerCount * processCount ) )
    }
    
    private func checkDuplicates() {
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        for ticker in galaxie {
            Prices().findDuplicates(ticker: ticker, debug: true)
        }
        print("\nDeleting duplicatre dates from realm...\nmake sure this runs A F T E R csv load!\n")
    }
    
    private func tradeButton(isOn:Bool) {
        if isOn {
            tradeButton.isEnabled = true
            tradeButton.alpha = 1.0
        } else {
            tradeButton.isEnabled = false
            tradeButton.alpha = 0.4
        }
    }
    
    private func updateButton(isOn:Bool){
        if isOn {
            updateButton.isEnabled = true
            updateButton.alpha = 1.0
        } else {
            updateButton.isEnabled = false
            updateButton.alpha = 0.4
        }
    }
    
    private func segueToChart(ticker: String) {
        let myVC:SCSSyncMultiChartView = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = Prices().getLastTaskID()
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func segueToCandidatesVC() {
        let myVC:SymbolsViewController = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func segueToManageVC(taskID: String, action: String) {
        let myVC:ManageViewController = storyboard?.instantiateViewController(withIdentifier: "ManageVC") as! ManageViewController
        myVC.taskID = taskID
        myVC.action = action
        navigationController?.pushViewController(myVC, animated: true)
    }
}


