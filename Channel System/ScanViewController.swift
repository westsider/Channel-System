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
        super.viewDidLoad()
        title = "Finance"
        // ManualTrades().showProfit()
        // CheckDatabase().testPastEntries()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetThis(ticker: "IYJ", isOn: false)
        CheckDatabase().canIgetDataFor(ticker: "REM", isOn: false)
        manageTradesOrShowEntries(debug: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if self.reset {
                GetCSV().csvOnly(galaxie: self.galaxie, debug: false)
            } else {
                if  UserDefaults.standard.object(forKey: "FirstRun") == nil  {
                    self.firstRun()
                } else {
                    self.stopAnimating()
                }
            }
        }
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
        updateNVActivity(with:"Contacting NYSE")
        IntrioFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in
            if finished {
                print("intrinio done")
                self.updateNVActivity(with:"Loading Trend 1")
                SMA().getData(galaxie: galaxie, debug: debug, period: 10) { ( finished ) in
                    if finished {
                        print("sma(10) done")
                        self.updateNVActivity(with:"Loading Trend 2")
                        SMA().getData(galaxie: galaxie, debug: debug, period: 200) { ( finished ) in 
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
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    func resetThis(ticker:String, isOn:Bool){
        if isOn { ReplacePrices().writeOverPrblemSymbol(ticker: ticker) }
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
        FirstRun().initializeEverything(galaxie: galaxie, debug: false)
        UserDefaults.standard.set(false, forKey: "FirstRun")
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


