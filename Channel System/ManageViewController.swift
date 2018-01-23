//
//  ManageViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/20/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift

class ManageViewController: UIViewController, UITextViewDelegate {

    // lables
    
    @IBOutlet weak var cashCommited: UILabel!
    @IBOutlet weak var topLeft: UILabel! // Entry For
    
    @IBOutlet weak var topRight: UILabel! // QQQ
    
    @IBOutlet weak var midLeft: UILabel!
    
    @IBOutlet weak var midRight: UILabel!
    
    @IBOutlet weak var bottomLeft: UILabel!
    
    @IBOutlet weak var bottomRight: UILabel!
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var accountSwitch: UISegmentedControl!
    
    @IBOutlet weak var capitalReq: UILabel!
    
    @IBOutlet weak var stopSizeLable: UILabel!

    @IBOutlet weak var exitSwitch: UISegmentedControl!
    
    var taskID:String = ""
    var action:String = "" // Entry For || Manage
    var thisTrade = Prices()
    var textEntered:String = "No Text"
    var costDict: [String:Double] = [:]
    // new vars to manage open trade
    var ticker = ""
    var entryDate = ""
    
    // preserve calc of shares ect
    var close:Double = 0.0
    var stopDistance:Double = 0.0
    var stop:Double = 0.0
    var target:Double = 0.0
    var stopString:String = " "
    var currentRisk:Int = 0
    var shares:Int = 0
    var account:String = "TDA"
    var capReq:Double = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        print("This is the taskID passes in to VC \(taskID)")
        currentRisk = Account().currentRisk()
        accountSwitch.selectedSegmentIndex = 2
        populateLables(action: action, debug: false)
        if action == "Entry for" {
            exitSwitch.isEnabled = false
            exitSwitch.alpha = 0.2
        } else {
            exitSwitchSet()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Trade"
        TradeManage().printOpenTrades()
        costDict = RealmHelpers().portfolioDict()
    }
    
    func exitSwitchSet() {
        switch action {
        case "Target":
            print("Target action Recieved")
            exitSwitch.selectedSegmentIndex = 0
        case "Stop":
            print("Stop action Recieved")
            exitSwitch.selectedSegmentIndex = 1
        case "Date Stop":
            print("Date Stop action Recieved")
            exitSwitch.selectedSegmentIndex = 2
        default:
            print("No action Recieved")
        }
    }
    @IBAction func accountSwitchAction(_ sender: UISegmentedControl) {
        
        switch accountSwitch.selectedSegmentIndex {
            case 0: account = "TDA"; print("account: \(account)");
            case 1: account = "E*Trade"; print("account: \(account)");
            case 2: account = "IB"; print("account: \(account)");
            default: break;
        }
    }
    //MARK: - populate lables from exit
    @IBAction func exitSwitchAction(_ sender: UISegmentedControl) {
        switch exitSwitch.selectedSegmentIndex {
        case 0: print("Target Selected"); topLeft.text = "Target Exit"; action = "Target"
        //MARK: - TODO - selet the proper exit to record in the database
            case 1: print("Stop Selected"); topLeft.text = "Stop Exit"; action = "Stop"
            case 2: print("Time Selected"); topLeft.text = "Time Exit"; action = "Date Stop"
            default: break;
        }
    }
    
    
    @IBAction func inputTextAction(_ sender: Any) {
        if let thisText = textInput.text {
            textEntered = thisText
            print(thisText)
        }
    }
    // MARK: - Cancel
    @IBAction func cancelAction(_ sender: Any) {
        print("Cancel: Unwind charts VC")
        if ( action == "Entry For") {
            self.performSegue(withIdentifier: "unwindToCharts", sender: self)
        } else {
            print("Cancel: Unwind from Manage trades VC")
            self.performSegue(withIdentifier: "unwindToScan", sender: self)
        }
    }
    
    // MARK: - Record Trade Entry or Exit
    @IBAction func recordAction(_ sender: Any) {
        if (textInput.text! != "") {
            textEntered = textInput.text!
        }

        switch action {
        case "Entry For":
            print("In Manage VC case Entry Triggered")
            //MARK: - TODO - make entry func
            if let entryPrice = Double(textEntered) {
                RealmHelpers().makeEntry(taskID: taskID, entry: entryPrice, stop: stop, target: target, shares: shares, risk: Double(currentRisk), debug: false, account: account, capital: capReq)
                sequeToPortfolio()
            }
        case "Target":
            if let exitPrice = Double(textEntered) {
                print("Closing the trade, target hit, sending target of \(exitPrice) to ManageTrade()")
                TradeManage().exitTrade(yyyyMMdd: entryDate, ticker: ticker, exitPrice: exitPrice, debug: true)
            }
        case "Stop":
            if let exitPrice = Double(textEntered) {
                print("Closing the trade, stop hit, sending stop of \(exitPrice) to ManageTrade()")
                TradeManage().exitTrade(yyyyMMdd: entryDate, ticker: ticker, exitPrice: exitPrice, debug: true)
            }
        case "Pct(R) Target":
            if let exitPrice = Double(textEntered) {
                print("Closing the trade, Pct(R) Target hit, sending price of \(exitPrice) to ManageTrade()")
                TradeManage().exitTrade(yyyyMMdd: entryDate, ticker: ticker, exitPrice: exitPrice, debug: true)
            }
        case "Date Stop":
            if let exitPrice = Double(textEntered) {
                print("Closing the trade, Date Stop hit, sending price of \(exitPrice) to ManageTrade()")
                TradeManage().exitTrade(yyyyMMdd: entryDate, ticker: ticker, exitPrice: exitPrice, debug: true)
            }
            
        default:
            print("\ndefault triggered in manage trades\n")
        }
        print("Record: Unwind from Manage trades VC")
        self.performSegue(withIdentifier: "unwindToScan", sender: self)
    }

    func calcGainOrLoss()-> Double {
        print("This is the taskID passes in to calcGain \(thisTrade.taskID)")
        
        if let exitPrice = Double(textEntered) {
            print("\n-----> We have  if let exitPrice of \(exitPrice)<------\n")
            let entryPrice:Double = thisTrade.entry
            let shares:Int = thisTrade.shares
            let result:Double = (exitPrice - entryPrice) * Double(shares)
            if ( result >= 0 ) {
                print("\nCalc gain of \(result)")
                updateRealm(gain: result, loss: 0.0)
            } else {
                print("\nCalc loss of \(result)")
                updateRealm(gain: 0.0, loss: result)
            }
            return result
        } else {
            return 0.00
        }
    }
    
    func updateRealm(gain: Double, loss: Double) {
        // ok - you are updateing the right taskID
        print("This is the taskID passed in to update realm \(thisTrade.taskID)")
        let realm = try! Realm()
        try! realm.write {
            thisTrade.exitDate = Date()
            thisTrade.profit = gain
            thisTrade.loss = loss
            thisTrade.exitedTrade = true
            thisTrade.inTrade = false
            thisTrade.account = account
            thisTrade.capitalReq = capReq
        }
        proveUpdateTrade()
    }
    
    func proveUpdateTrade() {
        print("Proof the trade has been updated for taskID \(taskID)")
        let checkTrades:Results<Prices> = RealmHelpers().checkExitedTrade(taskID: taskID)
        print("\ndubug - checkTrades")
        debugPrint(checkTrades)
    }

    
    //MARK: - Populate Lables
    func populateLables(action: String, debug: Bool) {
        
        if debug { print("\npopulate lables") }

        if (action == "Entry For") {
            print("\n calc trade entry, then populate lables\n")
            thisTrade = Prices().getFrom(taskID: taskID).last!
            if debug { debugPrint(thisTrade) }
            // calc target / stop
            close = thisTrade.close
            stop = TradeHelpers().calcStopTarget(ticker: thisTrade.ticker, close: close, debug: false).0
            target = TradeHelpers().calcStopTarget(ticker: thisTrade.ticker, close: close, debug: false).1
            stopDistance = TradeHelpers().calcStopTarget(ticker: thisTrade.ticker, close: close, debug: false).2
            stopString = TradeHelpers().stopString(stop: stop)
            shares = TradeHelpers().calcShares(stopDist: stopDistance, risk: currentRisk)
            if debug {
                let message:String = "Entry:\(close)\tShares:\(shares)\nStop:\(stopString)\tTarget:\(String(format: "%.2f", target))"; print(message)
            }
            // populate lables
            let cashCom = Utilities().dollarStr(largeNumber: RealmHelpers().calcPortfolioCost())
            cashCommited.text = "$\(cashCom) Comitted"
            textInput.text = String(thisTrade.close)
            
            topLeft.text = action
            
            topRight.text = thisTrade.ticker
            
            midLeft.text = "Entry \(String(thisTrade.close))"
            
            midRight.text = "\(String(shares)) Shares"
            
            bottomLeft.text = "Stop \(String(format: "%.2f", stop))"
            
            bottomRight.text = "Target \(String(format: "%.2f", target))"
            
            capReq = TradeHelpers().capitalRequired(close: close, shares: shares)
            
            let capReqd:String =  String(format: "%.2f", capReq)
            
            capitalReq.text = "Cost $\(capReqd)"
            
            if let stopSize:CompanyData = CompanyData().getExchangeFrom(ticker: thisTrade.ticker, debug: false) {
                stopSizeLable.text = "Stop Size \(stopSize.stopSize)%"
            } else {
                stopSizeLable.text = "Stop Size was nil"
            }
            
            
            
        } else if (action == "Manage") {
            //MARK: - TODO - set up lables
            //MARK: - TODO - record trade profit 
            
            
        } else {
            
            //print("\nJust poplulate lables")
            thisTrade = RealmHelpers().getEntryFor(taskID: taskID).last!
            //debugPrint(thisTrade)
            textInput.text = String(thisTrade.close)
            
            topLeft.text = action
            
            topRight.text = thisTrade.ticker
            
            midLeft.text = "Entry \(String(thisTrade.entry))"
            
            midRight.text = "\(String(thisTrade.shares)) Shares"
            
            bottomLeft.text = "Stop \(String(format: "%.2f", thisTrade.stop))"
            
            bottomRight.text = "Target \(String(format: "%.2f", thisTrade.target))"

            switch thisTrade.account {
                case "TDA" :
                    accountSwitch.selectedSegmentIndex = 0
                case "E*Trade" :
                    accountSwitch.selectedSegmentIndex = 1
                case "IB" :
                    accountSwitch.selectedSegmentIndex = 2
                default:
                    accountSwitch.selectedSegmentIndex = 0
            }
        }
        
        
    }
    
    @IBAction func segueToChartAction(_ sender: Any) {
        let myVC:SCSSyncMultiChartView = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = taskID
        myVC.maxBarsOnChart = 30
        myVC.showTrailStop = true
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    
    //MARK: - Keyboard behavior functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
    
    func sequeToPortfolio() {
        let myVC:PortfolioViewController = storyboard?.instantiateViewController(withIdentifier: "PortfolioVC") as! PortfolioViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
}
