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
    let firebaseBlock = { print( "Firebase Complete" ) }
    let prices = Prices()
    var counter:Int = 0
    var updateRealm:Bool = false
    var lastDateInRealm:Date!
    var galaxie = [String]()
    var marketCondition:Results<MarketCondition>!
    var marketReportString = ("No Title", "No Text")
    var reset:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finance"
        // ManualTrades().showProfit()
        // testPastEntries()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetThis(ticker: "IYJ", isOn: false)
        self.canIgetDataFor(ticker: "REM", isOn: false)
        manageTradesOrShowEntries(debug: true)
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
    
    private func setUpUI() {
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 100)
        let lastUpdate = Prices().getLastDateInRealm(debug: false)
        let dateString = Utilities().convertToStringNoTimeFrom(date: lastUpdate)
        let portfolioCost = RealmHelpers().calcPortfolioCost()
        let costStr = Utilities().dollarStr(largeNumber: portfolioCost)
        lastUpdateLable.text = "Last Update: \(dateString) $\(costStr) Comitted"
        currentProcessLable.text = "Waiting for Position Check"
        marketConditionUI(debug: false)
        self.startAnimating(self.size, message: "Checking Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
    }
    
    
    private func firstRun() {
        print("\nThis is the first run.\n")
        initializeEverything(galaxie: galaxie, debug: false)
        UserDefaults.standard.set(false, forKey: "FirstRun")
    }

    //MARK: - get new data
    @IBAction func getNewDataAction(_ sender: Any) {
        self.startAnimating(self.size, message: "Updating Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
        updateNewPrices(galaxie: galaxie, debug: true)
    }
    
    @IBAction func checkPositions(_ sender: Any) {
        manageTradesOrShowEntries(debug: true)
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////
    //                              Update New Prices                               //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func updateNewPrices(galaxie: [String], debug:Bool) {
        //updateNVActivity(with:"Updating Database")                                                   // 1.0
        //Account().updateRisk(risk: currentRisk); print("1.1 Risk Cmplete")
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
                                                            self.manageTradesOrShowEntries(debug: true)
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
    //                                  First Run                                   //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func initializeEverything(galaxie:[String], debug:Bool) {
        updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        //Account().updateRisk(risk: currentRisk); print("1.1 Risk Cmplete")
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
    //                               Clear for csv only                             //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func csvOnly(galaxie: [String], debug:Bool) {
        updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        //Account().updateRisk(risk: 50); print("1.1 Risk Cmplete")
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
            self.textColor()
            let uiText = MarketCondition().overview(galaxie: self.galaxie, debug: debug)
            self.titleLabel.text = uiText.0
            self.marketCondText.text = uiText.1
            self.stopAnimating()
            self.playAlertSound()
        }
    }
    
    func textColor() {
        let pctChange = MarketCondition().todaysPctChange(debug: true)
        if pctChange > 0 {
            marketCondText.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            titleLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else {
            marketCondText.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            titleLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
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
            FirbaseLink().backUp(completion: firebaseBlock)
        }
    }
    
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    

    @IBAction func manageTradesAction(_ sender: Any) {
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
                    segueToManageVC(taskID: trades.taskID, action: "Stop", ticker: trades.ticker, entryDate: trades.dateString)
                } else if trades.close > trades.target {
                    if debug { print("\nTarget Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Target", ticker: trades.ticker, entryDate: trades.dateString)
                } else if trades.wPctR > -30 {
                    if debug { print("\nwPctR Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Pct(R) Targe", ticker: trades.ticker, entryDate: trades.dateString)
                } else if Date() >= trades.exitDate {
                    if debug { print("\nTime Stop Hit for \(trades.ticker) from \(trades.dateString)\n")}
                    segueToManageVC(taskID: trades.taskID, action: "Date Stop", ticker: trades.ticker, entryDate: trades.dateString)
                } else {
                    print("Hey! No positions need attention!")
                    currentProcessLable.text = "No open positions need attention"
                }
            }
        } else {
            // exit here if no entries found
        }
    }
    
    func testPastEntries() {
         ManualTrades().oneEntryForTesting()
        // ManualTrades().removeExitFrom(yyyyMMdd: "2017/12/29", exityyyyMMdd: "2018/01/22", ticker: "AAPL", exitPrice: 0.0, debug: true)
        // ManualTrades().removeEntry(yyyyMMdd: "2018/01/22", ticker: "IBM", debug: true)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    private func checkDuplicates() {
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
        for ticker in galaxie {
            let _ = CheckDatabase().findDuplicates(ticker: ticker, debug: true)
        }
        print("\nDeleting duplicatre dates from realm...\nmake sure this runs A F T E R csv load!\n")
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
    
    private func segueToChart(ticker: String) {
        let myVC:SCSSyncMultiChartView = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = Prices().getLastTaskID()
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func segueToCandidatesVC() {
        let myVC:SymbolsViewController = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    private func segueToManageVC(taskID: String, action: String, ticker:String, entryDate:String) {
        let myVC:ManageViewController = storyboard?.instantiateViewController(withIdentifier: "ManageVC") as! ManageViewController
        myVC.taskID = taskID
        myVC.action = action
        // add ticker
        myVC.ticker = ticker
        // add date
        myVC.entryDate = entryDate
        navigationController?.pushViewController(myVC, animated: true)
    }
}


