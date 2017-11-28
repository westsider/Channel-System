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
    
    @IBOutlet weak var updateLable: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    let prices = Prices()
    
    var updatedProgress: Float = 0
    
    var incProgress: Float = 0
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    
    var counter = 0
    
    var updateRealm = false
    
    var lastDateInRealm:Date!
   
    var galaxie = [String]()
    
    let resetAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
                        //checkDuplicates()
                        //checkEarlyDates()
        
        //MARK: - reset
        if ( resetAll ) {
            print("--> 0. <-- we are resetting csv")
            initially(deleteAll: true, printPrices: true, printTrades: false)
            galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
            initProgressBar()
            GetCSV().areTickersValid(megaSymbols: galaxie)
            getDataFromCSV(completion: self.csvBlock)
        }
        //MARK: - dont reset get csv or datafeed
        if ( !resetAll ) {
            let allCountRealm = Prices().allPricesCount()
            if ( allCountRealm  > 0 ) {
                print("--> 1. <--  check realm status first")
// if check entries then make updateRealm = false manually also - DONT GET NEW DATA UNTIL 2PM
                updateRealm = DateHelper().realmNotCurrent(debug: true)
                updateRealm = false
                lastDateInRealm = Prices().getLastDateInRealm(debug: true)
                galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
                
                //MARK: - database not current - get new data
                if ( updateRealm ) {
                    print("--> 2. <-- database not current - get new data")
                    getDataFromDataFeed(debug: false, completion: self.datafeedBlock)
                //MARK: - Prices current check for candidates
                } else {
                    print("--> 3. <-- database is current - manage trades / show entries")
                    //MARK: - search for trade management scenario else segue to candidates
                    manageTradesOrShowEntries()
                }

            } else {
            //MARK: - First run - this needs work, how can I get csv then datafeed?
                print("--> 0.1 <-- First Run, No Prices, get csv, calc SMA, get new data")
                initially(deleteAll: true, printPrices: false, printTrades: false)
                galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: true)
                GetCSV().areTickersValid(megaSymbols: galaxie)
                getDataFromCSV(completion: self.csvBlock)
            }
        }
        //simPastEntries()
    }
    
    func simPastEntries() {
        getRealmFrom(ticker: "INTC", DateString: "2017/10/20") // exit after 7 days  Target Hit for INTC from 2017-11-28
        getRealmFrom(ticker: "EWD", DateString: "2017/10/17")  // stop hit   wPctR Hit for EWD from 2017-11-28
        getRealmFrom(ticker: "JNJ", DateString: "2017/11/22")  // target hit  wPctR Hit for JNJ from 2017-11-28
    }
    
    func getRealmFrom(ticker: String, DateString: String) {
        let specificNSDate = DateHelper().convertToDateFrom(string: DateString, debug: false)
        let realm = try! Realm()
        let predicate = NSPredicate(format: "date == %@", specificNSDate as CVarArg)
        let results = realm.objects(Prices.self).filter(predicate)
        print("/nEntries to make:")
        for each in results {
            if ( each.ticker == ticker)  {
                print("\(each.ticker) \(each.dateString) \(each.close)  \(each.taskID)")
                
                let close = each.close
                let stopDistance = close * 0.03
                let stop = close - stopDistance
                let target = close + stopDistance
                let shares = RealmHelpers().calcShares(stopDist: stopDistance, risk: 50)
                let stopString = String(format: "%.2f", stop)
                let message = "Entry:\(close)\tShares:\(shares)\nStop:\(stopString)\tTarget:\(String(format: "%.2f", target))"; print(message)
                RealmHelpers().makeEntry(taskID: each.taskID, entry: each.close, stop: stop, target: target, shares: shares, risk: Double(50), debug: false)
            }
        }
    }
    
    func initially(deleteAll: Bool, printPrices: Bool, printTrades: Bool){
        if ( deleteAll ) { RealmHelpers().deleteAll() }
        if ( printPrices ) { Prices().printLastPrices(symbols: galaxie, last: 4) }
        if ( printTrades ) { RealmHelpers().printOpenTrades() }
    }
    
    //MARK: - Trade Management
    func manageTradesOrShowEntries() {
        // search for trade management scenario else segue to candidates
        let tasks = RealmHelpers().getOpenTrades()
        print("Open trade count is \(tasks.count)")
        if ( tasks.count > 0) {
            for trades in tasks {
                //MARK: - TODO - Check if stop
                if trades.close < trades.stop {
                    print("\nStop Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Stop")
                }
                //MARK: - TODO - Check if target
                if trades.close > trades.target {
                    print("\nTarget Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Target")
                }
                if trades.wPctR > -30 {
                    print("\nwPctR Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Pct(R) Target")
                }
                //MARK: - TODO - Set up exit date on entry
                if Date() >= trades.exitDate {
                    print("\nTime Stop Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Date Stop")
                }
                self.updateProgressBar()
            }
        } else {
            // exit here if no entries found
            segueToCandidatesVC()
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    //MARK: - Get Data From CSV
    func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Getting local data for \(current) \(index+1) of \( self.galaxie.count)", spinIsOff: false)
                DataFeed().getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
                self.updateProgressBar()
            }
            self.updateUI(with: "All tickers have been downloaded!", spinIsOff: true)
            self.calcSMA10(completion: self.smaBlock2)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - Get Data From Datafeed
    func getDataFromDataFeed(debug: Bool, completion: @escaping () -> ()) {
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
                    self.updateProgressBar()
                })
            }
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - SMA 10
    func calcSMA10(completion: @escaping () -> ()) {
        self.updateUI(with: "Calulating SMA(10)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing SMA(10) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, priorCount: oneTicker.count, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(10) for \(symbols)", spinIsOff: true)
                self.updateProgressBar()
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
    func calcSMA200(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing SMA(200)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing SMA(200) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, priorCount: oneTicker.count, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(200) for \(symbols)", spinIsOff: true)
                self.updateProgressBar()
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
    func calcwPctR(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing PctR...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing PctR for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(priorCount: oneTicker.count, debug: false, prices: oneTicker, completion: self.wPctRBlock)
                self.updateUI(with: "Finished Processing PctR for \(symbols)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SPctR Complete", spinIsOff: true)
                self.calcEntries(completion: self.entryBlock)
            }
        }
    }
    //MARK: - Entries
    func calcEntries(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing Entries...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Processing Entries for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                Entry().calcLong(lastDate: self.lastDateInRealm, debug: false, prices: oneTicker, completion: self.entryBlock)
                self.updateUI(with: "Finished Processing Entries for \(symbols)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing Entries Complete", spinIsOff: true)
                print("\n-------> Now printing database <--------\n")
                Prices().printLastPrices(symbols: self.galaxie, last: 4)
                //self.segueToCandidatesVC()
                self.manageTradesOrShowEntries()
            }
        }
    }
    
    func updateProgressBar() {
        DispatchQueue.main.async {
            self.updatedProgress += self.incProgress
            self.progressView.progress = self.updatedProgress
        }
    }
    
    func updateUI(with: String, spinIsOff: Bool) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
            self.updateProgressBar()
        }
    }
    
    func initProgressBar() {
        let tickerCount = Double(galaxie.count)
        let processCount = Double(5)
        let divisor = Double(1)
        print("tickerCount \(tickerCount), processCount \(processCount), divisor \(divisor),")
        incProgress = Float( divisor / (tickerCount * processCount ) )
        print("\nProgress inc = \(incProgress)\n")
        progressView.setProgress(incProgress, animated: true)
        progressView.isHidden = false
    }
    
    func checkDuplicates() {
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: true)
        for ticker in galaxie {
            Prices().findDuplicates(ticker: ticker, debug: true)
        }
    }
    
    func checkEarlyDates() {
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        for ticker in galaxie {
            GetCSV().removeEarlyDates(ticker: ticker)
        }
    }
    
    func segueToChart(ticker: String) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = Prices().getLastTaskID()
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func segueToCandidatesVC() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func segueToManageVC(taskID: String, action: String) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ManageVC") as! ManageViewController
        myVC.taskID = taskID
        myVC.action = action
        navigationController?.pushViewController(myVC, animated: true)
    }
}


