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

class ScanViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var lastUpdateLable: UILabel!
    @IBOutlet weak var currentProcessLable: UILabel!
    @IBOutlet weak var marketCondText: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    
    let size = CGSize(width: 100, height: 100)
    let prices = Prices()
    var counter:Int = 0
    var updateRealm:Bool = false
    var lastDateInRealm:Date!
    var galaxie = [String]()
    var marketCondition:Results<MarketCondition>!
    var marketReportString = ("No Title", "No Text")
    var reset:Bool = false

    override func viewDidLoad() {
        title = "Finance"
        galaxie = SymbolLists().allSymbols
        let _ = CheckDatabase().report(debug: true, galaxie: SymbolLists().allSymbols)
        
        //Recalculate().allIndicators(ticker: "REM", debug: true, redoAll: true)
        //PageInfo.showDatesForPages(ticker: "SPY")
        //let allMissing = ["HAR", "HOT", "FTI", "ALTR", "SIAL", "GOOGL", "TYC", "ARG"]
        //let missing2 =   ["PCP", "LLTC", "MHFI", "CVC", "GOOG", "LB", "STJ", "PLL"]
        //let missing3 =   ["POM", "HCBK", "SNDK", "HSP", "DTV", "GMCR", "PCL", "ALLE"]
        //let missing4 =   ["JCI", "JOY", "IRM", "TWC", "ADT", "TE", "NAVI", "MYL", "ACE"]
        //CheckDatabase().replaceThe(missingDays: ["GOOG"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetThis(ticker: "QQQ", isOn: false)
        CheckDatabase().canIgetDataFor(ticker: "ADT", isOn: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if self.reset {
            GetCSV().csvOnly(galaxie: self.galaxie, debug: false)
        } else {
            if  UserDefaults.standard.object(forKey: "FirstRun") == nil  {
                self.firstRun()
            } else {
                // only run database check once a day
                startAnimating(size, message: "Checking Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
                if let todaysDate = UserDefaults.standard.object(forKey: "todaysDate")  {
                    let updateWasToday =  Utilities().thisDateIsToday(date: todaysDate as! Date, debug: false)
                    if !updateWasToday {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 ) {
                            self.manageTradesOrShowEntries(debug: true)
                            self.setUpUI()
                            self.marketConditionUI(debug: false)
                            UserDefaults.standard.set(Date(), forKey: "todaysDate")
                        }
                    } else {
                        self.stopAnimating()
                    }
                }
            }
        }
    }
    
    //MARK: - get new data
    @IBAction func getNewDataAction(_ sender: Any) {
        self.startAnimating(self.size, message: "Requesting group 1 from NYSE", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 ) {
            let segments = SymbolLists().segmented(by: 10, of727loadOnly: 727) // of 727
            print("Num Segments is \(segments.count)")
            let myGroup = DispatchGroup()
            var groupCounter = 0

            for eachSegment in segments {
                myGroup.enter()
                self.updateNewPrices(galaxie: eachSegment, debug: true) { (finished) in
                    if finished {
                        groupCounter += 1
                        let message = "Ticker group \(groupCounter) of \(segments.count) complete"
                        print("\n\n+++++++++++++++> \(message) \t<+++++++++++++++\n\n")
                        self.updateNVActivity(with: message)
                        myGroup.leave()
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                let message = "Finihed All Groups"
                print(message)
                self.updateNVActivity(with: message)
                self.stopAnimating()
            }
        }
        //MARK: - Todo galxie needs to be changed to in all vc's
        //let segments = SymbolLists().segmented(by: 14)
    }
    
    @IBAction func checkPositions(_ sender: Any) {
        manageTradesOrShowEntries(debug: true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    //                              Update New Prices                               //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Update New Prices Only
    func updateNewPrices(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        print("\nwe are updating prices\n")
        //updateNVActivity(with:"Contacting NYSE")
        //IntrioFeed().getDataSegments(galaxie: galaxie, debug: true) { (finished) in
        IntrioFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in
            if finished {
                print("intrinio done")
                self.updateNVActivity(with:"Loading Trend 1")
                SMA().getData(galaxie: galaxie, debug: debug, period: 10, redoAll: false) { ( finished ) in
                    if finished {
                        print("sma(10) done")
                        self.updateNVActivity(with:"Loading Trend 2")
                        SMA().getData(galaxie: galaxie, debug: debug, period: 200, redoAll: false) { ( finished ) in 
                            if finished {
                                print("sma(200) done")
                                self.updateNVActivity(with:"Loading Oscilator")
                                PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                    if finished {
                                        print("oscilator done")
                                       // self.updateNVActivity(with:"Loading Market Condition")
                                        // only load once a day
                                        //MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                            //if finished  {
                                             //   print("mc done")
                                                self.updateNVActivity(with:"Finding Trades")
                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                    if finished  {
                                                        print("Entry done")
                                                        self.updateNVActivity(with:"Brute Force Back Test")
                                                        //CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                            completion(true)
                                                            print("\ncalc Stars done!\n")
                                                            print("Finished calculating indicators and trades")
                                                        Utilities().playAlertSound()
                                                           // self.stopAnimating()
                                                           // self.marketConditionUI(debug: false)
                                                            //self.updateNVActivity(with:"Daily + Weekly Back Test")
                                                            //self.manageTradesOrShowEntries(debug: true)
                                                        //})
                                                    }
                                                })
                                           // }//
                                        //}) //
                                    }
                                })
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
            Utilities().playAlertSound()
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
    
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
            self.lastUpdateLable.text = with
        }
    }
  
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    @IBAction func manageTradesAction(_ sender: Any) {
        segueToCandidatesVC()
    }
    
    //MARK: - Trade Management
    private func manageTradesOrShowEntries(debug:Bool) {
        // search for trade management scenario else segue to candidates
        //startAnimating(size, message: "Checking Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
        let tasks = RealmHelpers().getOpenTrades()
        print("Open trade count is \(tasks.count)")
        if ( tasks.count > 0) {
            for trades in tasks {
                //MARK: - Check if stop hit
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
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    func resetThis(ticker:String, isOn:Bool){
        if isOn { ReplacePrices().writeOverPrblemSymbol(ticker: ticker)    }
    }

    private func setUpUI() {
        let lastUpdate = Prices().getLastDateInRealm(debug: false)
        let dateString = Utilities().convertToStringNoTimeFrom(date: lastUpdate)
        let portfolioCost = RealmHelpers().calcPortfolioCost()
        let costStr = Utilities().dollarStr(largeNumber: portfolioCost)
        let trailStops = ShowStops().textForMainUI()
        lastUpdateLable.text = "Last Update: \(dateString) $\(costStr) Comitted"
        if trailStops == "\n--------> Trail Stop Change <--------\n" {
            currentProcessLable.text = "Waiting for Position Check"
        } else {
            currentProcessLable.text = "Trail Stop Change"
        }
        
        
        //self.startAnimating(self.size, message: "Checking Database", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballRotateChase.rawValue)!)
    }
    
    private func firstRun() {
        print("\nThis is the first run.\n")
        FirstRun().initializeEverything(galaxie: galaxie, debug: false)
        UserDefaults.standard.set(false, forKey: "FirstRun")
        // set up all of the ap keys
        let myVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func workOnDataBase() {
        // RealmHelpers().pathToDatabase()
        // ManualTrades().showProfit()
        //CheckDatabase().testPastEntries()
        ReplacePrices().writeOverPrblemSymbol(ticker: "MDY")
        // ReplacePrices().deleteOldSymbol(ticker: "QRVO")
        //self.manageTradesOrShowEntries(debug: true)
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


