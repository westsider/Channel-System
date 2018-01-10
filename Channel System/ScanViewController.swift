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
import AVFoundation

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
    var reset:Bool = false                              //    var testTicker:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finance"
        ManualTrades().showProfit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.startAnimating(self.size, message: "Loading Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
            self.galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 100)
            CompanyData().databeseReport(debug: false, galaxie: self.galaxie)
            self.resetThis(ticker: "DGL", isOn: true)
            self.canIgetDataFor(ticker: "AAPL", isOn: false)
            
            //CleanData().report(debug: true, galaxie: self.galaxie)
        }
    }
    
    func resetThis(ticker:String, isOn:Bool){
        if isOn { ReplacePrices().writeOverPrblemSymbol(ticker: ticker) }
    }
    
    func canIgetDataFor(ticker:String, isOn:Bool) {
        if isOn {
            ReplacePrices().getLastPrice(ticker: ticker, debug: true, page: 1, saveToRealm: false, completion: { (finished) in
                if finished {
                    print("finished getting prices for \(ticker)")
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if self.reset {
                self.csvOnly(galaxie: self.galaxie, debug: false)
            } else {
                if  UserDefaults.standard.object(forKey: "FirstRun") == nil  {
                    self.firstRun()
                } else {
                    self.stopAnimating()
                }
            }
        }
    }
    
    private func firstRun() {
        print("\nThis is the first run.\n")
        initializeEverything(galaxie: galaxie, debug: false)
        UserDefaults.standard.set(false, forKey: "FirstRun")
    }
    
    private func subsequentRuns() {
        print("\nThis is NOT the first run. Updating Prices \n")
        updateNewPrices(galaxie: galaxie, debug: false)
    }
    
    //MARK: - get new data
    @IBAction func getNewDataAction(_ sender: Any) {
        self.startAnimating(self.size, message: "Updating Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
        subsequentRuns()
    }
    //////////////////////////////////////////////////////////////////////////////////
    //                                  First Run                                   //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func initializeEverything(galaxie:[String], debug:Bool) {
        updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        Account().updateRisk(risk: 50); print("1.1 Risk Cmplete")
        updateNVActivity(with:"Loading Historical Prices")                                            // 1.1
        CSVFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in            // 1.2
            if finished {
                print("csv done")
                self.updateNVActivity(with:"Loading Exchanges")
                CompanyData().getInfo(galaxie: galaxie, debug: debug) { ( finished ) in // 1.3
                    if finished {
                        print("\n*** Company Info done ***\n")
                        self.updateNVActivity(with:"Contacting NYSE")
                        IntrioFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in // 1.4
                            if finished {
                                print("intrinio done")
                                self.updateNVActivity(with:"Loading Trend 1")
                                SMA().getData(galaxie: galaxie, debug: debug, period: 10) { ( finished ) in // 2.0
                                    if finished {
                                        print("sma(10) done")
                                        self.updateNVActivity(with:"Loading Trend 2")
                                        SMA().getData(galaxie: galaxie, debug: debug, period: 200) { ( finished ) in // 2.0
                                            if finished {
                                                print("sma(200) done")
                                                self.updateNVActivity(with:"Loading Oscilator")
                                                PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                    if finished {
                                                        print("oscilator done")
                                                        self.updateNVActivity(with:"Loading Market Condition")
                                                        MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                            if finished  {
                                                                print("mc done")
                                                                self.updateNVActivity(with:"Finding Trades")
                                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                                    if finished  {
                                                                        print("Entry done")
                                                                        self.updateNVActivity(with:"Brute Force Back Test")
                                                                        CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                                            print("\ncalc Stars done!\n")
                                                                            self.stopAnimating()
                                                                            self.marketConditionUI(debug: false)
                                                                            
                                                                            //self.updateNVActivity(with:"Daily + Weekly Back Test")
//                                                                            CumulativeProfit().backtestDailyWeekly(debug: debug, completion: { (finished) in
//                                                                                if finished  {
//                                                                                    print("Backtest done")
//                                                                                    DispatchQueue.main.async {
//                                                                                        self.stopAnimating()
//                                                                                        self.marketConditionUI(debug: false)
//
//                                                                                    }
//                                                                                }
//                                                                            })
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
    
    //////////////////////////////////////////////////////////////////////////////////
    //                              Update New Prices                               //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func updateNewPrices(galaxie: [String], debug:Bool) {
        //updateNVActivity(with:"Updating Database")                                                   // 1.0
        Account().updateRisk(risk: 50); print("1.1 Risk Cmplete")
        updateNVActivity(with:"Contacting NYSE")                                            // 1.1
        IntrioFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in // 1.4
            if finished {
                print("intrinio done")
                self.updateNVActivity(with:"Loading Trend 1")
                SMA().getData(galaxie: galaxie, debug: debug, period: 10) { ( finished ) in // 2.0
                    if finished {
                        print("sma(10) done")
                        self.updateNVActivity(with:"Loading Trend 2")
                        SMA().getData(galaxie: galaxie, debug: debug, period: 200) { ( finished ) in // 2.0
                            if finished {
                                print("sma(200) done")
                                self.updateNVActivity(with:"Loading Oscilator")
                                PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                    if finished {
                                        print("oscilator done")
                                        self.updateNVActivity(with:"Loading Market Condition")
                                        MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                            if finished  {
                                                print("mc done")
                                                self.updateNVActivity(with:"Finding Trades")
                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                    if finished  {
                                                        print("Entry done")
                                                        self.updateNVActivity(with:"Brute Force Back Test")
                                                        CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                            print("\ncalc Stars done!\n")
                                                            self.stopAnimating()
                                                            self.marketConditionUI(debug: false)
                                                            self.updateNVActivity(with:"Daily + Weekly Back Test")
//                                                            CumulativeProfit().backtestDailyWeekly(debug: debug, completion: { (finished) in
//                                                                if finished  {
//                                                                    print("Backtest done")
//                                                                    DispatchQueue.main.async {
//                                                                        self.stopAnimating()
//                                                                        self.marketConditionUI(debug: false)
//                                                                    }
//                                                                }
//                                                            })
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
    
    //////////////////////////////////////////////////////////////////////////////////
    //                               Clear for csv only                             //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func csvOnly(galaxie: [String], debug:Bool) {
        updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        Account().updateRisk(risk: 50); print("1.1 Risk Cmplete")
        updateNVActivity(with:"Loading Historical Prices")                                            // 1.1
        CSVFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in            // 1.2
            if finished {
                print("csv done")
                self.updateNVActivity(with:"Loading Exchanges")
                CompanyData().getInfo(galaxie: galaxie, debug: debug) { ( finished ) in // 1.3
                    if finished {
                        print("info done")
                        self.updateNVActivity(with:"Contacting NYSE")
                                print("skipping intrinio")
                                self.updateNVActivity(with:"Loading Trend 1")
                                SMA().getData(galaxie: galaxie, debug: debug, period: 10) { ( finished ) in // 2.0
                                    if finished {
                                        print("sma(10) done")
                                        self.updateNVActivity(with:"Loading Trend 2")
                                        SMA().getData(galaxie: galaxie, debug: debug, period: 200) { ( finished ) in // 2.0
                                            if finished {
                                                print("sma(200) done")
                                                self.updateNVActivity(with:"Loading Oscilator")
                                                PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                    if finished {
                                                        print("oscilator done")
                                                        self.updateNVActivity(with:"Loading Market Condition")
                                                        MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                            if finished  {
                                                                print("mc done")
                                                                self.updateNVActivity(with:"Finding Trades")
                                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                                    if finished  {
                                                                        print("Entry done")
                                                                        self.updateNVActivity(with:"Brute Force Back Test")
                                                                        CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                                            print("\ncalc Stars done!\n")
                                                                            self.stopAnimating()
                                                                            self.marketConditionUI(debug: false)
//                                                                            self.updateNVActivity(with:"Daily + Weekly Back Test")
//                                                                            CumulativeProfit().backtestDailyWeekly(debug: debug, completion: { (finished) in
//                                                                                if finished  {
//                                                                                    print("Backtest done")
//                                                                                    DispatchQueue.main.async {
//                                                                                        self.stopAnimating()
//                                                                                        self.marketConditionUI(debug: false)
//                                                                                    }
//                                                                                }
//                                                                            })
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
    
    func marketConditionUI(debug:Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let uiText = MarketCondition().overview(debug: debug)
            self.titleLabel.text = uiText.0
            self.marketCondText.text = uiText.1
            self.playAlertSound()
        }
    }
    
    func playAlertSound() {
        let systemSoundId: SystemSoundID = 1106 // connect to power // 1052 tube bell //1016 tweet
        AudioServicesPlaySystemSound(systemSoundId)
    }
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
        }
    }
    
    func firebaseBackup(now:Bool) {
        if now {
            self.updateUI(with: "Backing Up To Firebase...")
            FirbaseLink().backUp(completion: firebaseBlock)
            self.updateUI(with: "Backing Up Complete")
        }
    }
    
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
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
    
    private func updateUI(with: String) {
        DispatchQueue.main.async {
            //print(with)
            self.lastUpdateLable.text =  with
        }
    }
    
    private func checkDuplicates() {
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
        for ticker in galaxie {
            let _ = CleanData().findDuplicates(ticker: ticker, debug: true)
        }
        print("\nDeleting duplicatre dates from realm...\nmake sure this runs A F T E R csv load!\n")
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


