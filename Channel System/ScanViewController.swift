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
import NVActivityIndicatorView

//, NVActivityIndicatorViewable
class ScanViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var lastUpdateLable: UILabel!
    @IBOutlet weak var currentProcessLable: UILabel!
    @IBOutlet weak var marketCondText: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    
    let size = CGSize(width: 100, height: 100)
    let csvBlock = { print( "1.2 CSV Complete" ) }
    let infoBlock = { print( "1.3 Company Info Complete" ) }
    let intrioBlock = { print( "1.4 Intrinio Complete" ) }
    let smaBlock1 = { print( "2.1 SMA(10) Complete" ) }
    let smaBlock2 = { print( "SMA(200) Complete" ) }
    let wPctRBlock = { print( "wPct(R) Complete" ) }
    let entryBlock = { print( "Entry Complete" ) }
    
    let mcBlock = { print( "Market Condition ) Complete" ) }
    let firebaseBlock = { print( "Firebase Complete" ) }
    let prices = Prices()
    var updatedProgress: Float = 0
    var incProgress: Float = 0
    var counter:Int = 0
    var updateRealm:Bool = false
    var lastDateInRealm:Date!
    var galaxie = [String]()
    var marketCondition:Results<MarketCondition>!
    var marketReportString = ("No Title", "No Text")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finance"
//        tradeButton(isOn: false)
//        updateButton(isOn: false)
//        ManualTrades().showProfit()
//        //RealmHelpers().deleteAll()
//
//        let oldClosedTrades =  RealmHelpers().getClosedTrades()
//        print("\nPrinting Closed trades in realm")
//        for each in oldClosedTrades {
//            print("\(each.ticker) \(each.dateString) entry: \(each.entry) profit: \(each.profit) loss: \(each.loss)")
//        }
//        // iphone 7+ Sim is  191634
//
//        // stats get stuck in inf loop.. might be calcMarketCondFirstRun() didnt get calles
//        // in pref run
//        // [ ] entries
//        // [ ] backtest

//        print("\n", marketReportString, "\n")
//
//        // this was never called on first run
//        CumulativeProfit().weeklyProfit(debug: true) {
//            (result: Bool) in
//            if result {
//                DispatchQueue.main.async {
//                    self.printDone()
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.startAnimating(self.size, message: "Loading Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.initializeEverything(tenOnly: true, debug: true)
            
//            CumulativeProfit().weeklyProfit(debug: true, completion: { (finished) in
//                if finished {
//                    print("\n----------------------------------------------------------\n\t\t\tdone with weekly\n")
//                }
//            })
            
            
           //let master = CumulativeProfit().allTickerBacktestWithCost(debug: true, saveToRealm: false)
        
        }
//        SMA().getData(tenOnly: true, debug: true, period: 10) { ( finished ) in // 2.0
//            if finished {
//                print("\nfinished redo of sma 10\n")
//            }
//        }
//        if  UserDefaults.standard.object(forKey: "FirstRun") == nil  {
//            firstRun()
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                self.subsequentRuns()
//                self.firebaseBackup(now: false)
//                FirbaseLink().allData(clear: false)
//            }
//        }
    }
    
//////////////////////////////////////////////////////////////////////////////////
//                              New First Run                                   //
//////////////////////////////////////////////////////////////////////////////////
    
    //MARK: - Initialize Everything
    func initializeEverything(tenOnly: Bool, debug:Bool) {
        updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        Account().updateRisk(risk: 50); print("1.1 Risk Cmplete")
        updateNVActivity(with:"Loading Historical Prices")                                            // 1.1
        CSVFeed().getData(tenOnly: tenOnly, debug: debug) { ( finished ) in            // 1.2
            if finished {
                print("csv done")
                self.updateNVActivity(with:"Loading Exchanges")
                CompanyData().getInfo(tenOnly: tenOnly, debug: debug) { ( finished ) in // 1.3
                    if finished {
                        print("info done")
                        self.updateNVActivity(with:"Contacting NYSE")
                        IntrioFeed().getData(tenOnly: tenOnly, debug: debug) { ( finished ) in // 1.4
                            if finished {
                                print("intrinio done")
                                self.updateNVActivity(with:"Loading Trend 1")
                                SMA().getData(tenOnly: tenOnly, debug: debug, period: 10) { ( finished ) in // 2.0
                                    if finished {
                                        print("sma(10) done")
                                        self.updateNVActivity(with:"Loading Trend 2")
                                        SMA().getData(tenOnly: tenOnly, debug: debug, period: 200) { ( finished ) in // 2.0
                                            if finished {
                                                print("sma(200) done")
                                                self.updateNVActivity(with:"Loading Oscilator")
                                                PctR().getwPctR(tenOnly: tenOnly, debug: false, completion: { (finished) in
                                                    if finished {
                                                        print("oscilator done")
                                                        self.updateNVActivity(with:"Loading Market Condition")
                                                        MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                            if finished  {
                                                                print("mc done")
                                                                self.updateNVActivity(with:"Finding Trades")
                                                                Entry().getEntry(tenOnly: tenOnly, debug: debug, completion: { (finished) in
                                                                    if finished  {
                                                                        print("Entry done")
                                                                        self.updateNVActivity(with:"Brute Force Back Test")
                                                                        CalcStars().backtest(testTenOnly: true, debug: true, completion: {
                                                                            print("\ncalc Stars done!\n")
                                                                            self.updateNVActivity(with:"Daily + Weekly Back Test")
                                                                            CumulativeProfit().backtestDailyWeekly(debug: true, completion: { (finished) in
                                                                                if finished  {
                                                                                    print("Backtest done")
                                                                                    DispatchQueue.main.async {
                                                                                        self.stopAnimating()
                                                                                        self.marketConditionUI(debug: false)
                                                                                    }
                                                                                }
                                                                            })
                                                                        })
                                                                    }
                                                                })
                                                            }
                                                        })
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func marketConditionUI(debug:Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let uiText = MarketCondition().overview(debug: debug)
            self.titleLabel.text = uiText.0
            self.marketCondText.text = uiText.1
        }
    }
    
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
        }
    }
    

    
    func firebaseBackup(now:Bool) {
        if now {
            tradeButton(isOn: false)
            updateButton(isOn: false)
            self.updateUI(with: "Backing Up To Firebase...")
            FirbaseLink().backUp(completion: firebaseBlock)
            self.updateUI(with: "Backing Up Complete")
            tradeButton(isOn: true)
            updateButton(isOn: true)
        }
    }
    
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func saveCompanyInfoToRealm() {
//        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
//        for ticker in galaxie {
//            CompanyData().getInfoFor(ticker: ticker, debug: false, completion: self.infoBlock)
//        }
    }
    
    private func firstRun() {
        lastUpdateLable.text = "First run of app."
        print("\nThis was first run so I will load CSV historical data\n")
        initially(deleteAll: true, printPrices: false, printTrades: false)
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        self.updateUI(with: "Cleaning CSV Data...")
        GetCSV().areTickersValid(megaSymbols: galaxie)
        getDataFromCSV(completion: self.csvBlock) // get entries crash on first run, lastUpdateInRealm = Nil
        checkDuplicates()
        saveCompanyInfoToRealm()
        //MarketCondition().calcMarketCondFirstRun(debug: true, completion: mcBlock)
        UserDefaults.standard.set(false, forKey: "FirstRun")
    }
    
    private func subsequentRuns() {
        print("\nThis is NOT the first run.\n")
        updateRealm = Utilities().realmNotCurrent(debug: false)
        lastDateInRealm = Prices().getLastDateInRealm(debug: false)
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        let lastUpDate = Utilities().convertToStringNoTimeFrom(date: lastDateInRealm)
        let lastUpDateString = "Updated on \(lastUpDate)"
        NVActivityIndicatorPresenter.sharedInstance.setMessage(lastUpDateString)
        currentProcessLable.text = lastUpDateString
        tradeButton(isOn: true)
        updateButton(isOn: true)
 
        self.stopAnimating()
        titleLabel.text = marketReportString.0
//        marketCondText.text = marketReportString.1
//        print("title \(marketReportString.0) body \(marketReportString.1)")
//        print("Last Date in Realm: \(lastDateInRealm) today is\(Date())")
//        let this = Utilities().lastUpdateWasToday(debug: true)
//        print("Last dat is today \(this.0)")
    }

    func overview(debug:Bool)-> (String, String ) {
        let latest = marketCondition.last!
        var pct:Double = 0.0
        var longTrendString = ""
        let dateString = Utilities().convertToStringNoTimeFrom(date: latest.date!)
        if latest.close > latest.upperBand {
            pct = ((latest.close - latest.upperBand ) / latest.close) * 100
            longTrendString = "\n\t\t\(String(format: "%.2f", pct))% above the long term trend"
        } else if latest.close < latest.lowerBand {
            pct = ((latest.close - latest.upperBand ) / latest.close) * 100
            longTrendString = "\n\t\t\(String(format: "%.2f", pct))%) below the long term trend"
        } else {
            longTrendString = "\n\t\the index is withing the trend bands"
        }
        
        let titleString = "Market Condition \(dateString)"
        
        var thisString  = "\t\tS&P 500 Index is at \(latest.close)"
        
        thisString  += longTrendString
        
        thisString  += "\n\t\tWe are in a \(latest.trendString) Trend"
        
        thisString += "\n\t\tThe volatility is currently \(latest.volatilityString)"
        
        thisString += "\n\t\t\(latest.guidanceChart) for Longs"
        
        if ( debug ) { print(thisString) }
        return ( titleString, thisString )
    }
    
    @IBAction func getNewDataAction(_ sender: Any) {
        //MARK: - get new data
        LastUpdate().incUpdate()
       // getDataFromDataFeed(debug: false, completion: self.datafeedBlock)
    }
    
    @IBAction func manageTradesAction(_ sender: Any) {
        updateUI(with: "Calculating Performance")
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

///////////////////////////////////////////////////////////

    
    //MARK: - 1.2 Get Data From CSV
    private func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                self.updateUI(with: "Getting local data for \(symbols) \(index+1) of \( self.galaxie.count)")
               // CSVFeed().getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
            }
            self.updateUI(with: "All tickers have been downloaded!")
            self.calcSMA10(completion: self.smaBlock2)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - Get Data From Datafeed
    private func getDataFromDataFeed(debug: Bool, completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            self.startAnimating(self.size, message: "Contacting NYSE", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.orbit.rawValue)!)
        }
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                //self.updateUI(with: "Getting remote data for \(symbols) \(index+1) of \( self.galaxie.count)", spinIsOff: false)
                DataFeed().getLastPrice(ticker: symbols, lastInRealm: self.lastDateInRealm, debug: true, completion: {
                    self.counter += 1
                    DispatchQueue.main.async {
                        NVActivityIndicatorPresenter.sharedInstance.setMessage("Getting remote data for \(symbols) \(index+1) of \( self.galaxie.count)")
                    }
                    if ( debug ) { print("\n----> counter: \(self.counter) universe: \(self.galaxie.count) <----\n") }
                    if ( self.counter == self.galaxie.count ) {
                        self.updateUI(with: "All remote data has been downloaded!\n")
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
//        self.updateUI(with: "Calulating Trend 1")
//        DispatchQueue.global(qos: .background).async {
//            for ( index, symbols ) in self.galaxie.enumerated() {
//                //self.updateUI(with: "Processing SMA(10) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
//                NVActivityIndicatorPresenter.sharedInstance.setMessage("Processing SMA(10) for \(symbols) \(index+1) of \(self.galaxie.count)")
//                //let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
//                //SMA().averageOf(period: 10, debug: false, priorCount: oneTicker.count, prices: oneTicker, redoAll: false, completion: self.smaBlock1)
//                //self.updateUI(with: "Finished Processing SMA(10) for \(symbols)", spinIsOff: true)
//            }
//            DispatchQueue.main.async {
//                completion()
//                self.updateUI(with: "Calculating Main Trend")
//                print("\nSegue to Charts\n")
//                self.calcSMA200(completion: self.smaBlock2)
//            }
//        }
    }
    //MARK: - SMA 200
    private func calcSMA200(completion: @escaping () -> ()) {
//        self.updateUI(with: "Calculating Main Trend")
//        DispatchQueue.global(qos: .background).async {
//            for ( index, symbols ) in self.galaxie.enumerated() {
//                //self.updateUI(with: "Processing SMA(200) for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
//                NVActivityIndicatorPresenter.sharedInstance.setMessage("Processing SMA(200) for \(symbols) \(index+1) of \(self.galaxie.count)")
//                //let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
//                //SMA().averageOf(period: 200, debug: false, priorCount: oneTicker.count, prices: oneTicker, redoAll: false, completion: self.smaBlock1)
//                //self.updateUI(with: "Finished Processing SMA(200) for \(symbols)", spinIsOff: true)
//            }
//            DispatchQueue.main.async {
//                completion()
//                self.updateUI(with: "Processing SMA(200) Complete")
//                self.calcwPctR(completion: self.wPctRBlock)
//            }
//        }
    }
    //MARK: - wPctR
    private func calcwPctR(completion: @escaping () -> ()) {
//        self.updateUI(with: "Processing Oscilator")
//        DispatchQueue.global(qos: .background).async {
//            for ( index, symbols ) in self.galaxie.enumerated() {
//               // self.updateUI(with: "Processing PctR for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
//                NVActivityIndicatorPresenter.sharedInstance.setMessage("Processing PctR for \(symbols) \(index+1) of \(self.galaxie.count)")
//                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
//                PctR().williamsPctR(priorCount: oneTicker.count, debug: false, prices: oneTicker, redoAll: false, completion: self.wPctRBlock)
//                //self.updateUI(with: "Finished Processing PctR for \(symbols)", spinIsOff: true)
//            }
//            DispatchQueue.main.async {
//                completion()
//                self.updateUI(with: "Processing Oscilator Complete")
//                self.calcEntries(completion: self.entryBlock)
//                MarketCondition().calcMarketCondUpdate(debug: true)
//            }
//        }
    }
    //MARK: - Entries
    private func calcEntries(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing Trades")
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                //self.updateUI(with: "Processing Entries for \(symbols) \(index+1) of \(self.galaxie.count)", spinIsOff: false)
                
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Processing Entries for \(symbols) \(index+1) of \(self.galaxie.count)")
                
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                if ( self.lastDateInRealm != nil ) {
                    Entry().calcLong(lastDate: self.lastDateInRealm, debug: false, prices: oneTicker, completion: self.entryBlock)
                } else {
                    // if first run when lastDateInRealm == nil and i need to load all symbols
                    // so i will pass in the first date in the CSV
                    let firstDate  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false)
                    Entry().calcLong(lastDate: firstDate, debug: false, prices: oneTicker, completion: self.entryBlock)
                }
                //self.updateUI(with: "Finished Processing Entries for \(symbols)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing Entries Complete")
                self.stopAnimating()
                self.manageTradesOrShowEntries(debug: false)
            }
        }
    }
    
    private func updateUI(with: String) {
        DispatchQueue.main.async {
            //print(with)
            self.lastUpdateLable.text =  with
        }
    }
    
    func screenDim(isOn:Bool) {
        if isOn {
            tradeButton(isOn:false)
            updateButton(isOn:false)
        } else {
            tradeButton(isOn:false)
            updateButton(isOn:false)
        }
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
    
    func printDone() {
        print("done weekly stats")
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


