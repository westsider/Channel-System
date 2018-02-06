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
    var ticker = ""
    var entryDate = ""
    var close:Double = 0.0
    var stopDistance:Double = 0.0
    var stop:Double = 0.0
    var target:Double = 0.0
    var stopString:String = " "
    var currentRisk:Int = 0
    var shares:Int = 0
    var account:String = "TDA"
    var capReq:Double = 0.0
    var portfolioCost:Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Trade"
        TradeManage().printOpenTrades()
        costDict = RealmHelpers().portfolioDict()
        portfolioCost =  RealmHelpers().calcPortfolioCost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("This is the taskID passes in to VC \(taskID) this is action \(action)")
        currentRisk = Account().currentRisk()
        thisTrade = Prices().getFrom(taskID: taskID).last!
        populateLables(action: action, debug: false)
        if action == "Entry for" {
            exitSwitch.isEnabled = false
            exitSwitch.alpha = 0.2
        } else {
            exitSwitchSet()
        }
        // if we can buy in IB do it else use TDA
        if portfolioCost < 100000 - thisTrade.capitalReq {
            print("switch is IB")
            accountSwitch.selectedSegmentIndex = 2
            account = "IB"
        } else {
            print("switch is TDA")
            accountSwitch.selectedSegmentIndex = 0
            account = "TDA"
        }
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
    
    @IBAction func cancelAction(_ sender: Any) {
        print("Cancel: Unwind charts VC")
        if ( action == "Entry For") {
            self.performSegue(withIdentifier: "unwindToCharts", sender: self)
        } else {
            print("Cancel: Unwind from Manage trades VC")
            self.performSegue(withIdentifier: "unwindToScan", sender: self)
        }
    }
    
    @IBAction func recordAction(_ sender: Any) {
        if (textInput.text! != "") {
            textEntered = textInput.text!
        }

        switch action {
        case "Entry For":
            print("\nIn Manage VC case \(action)")
            if let entryPrice = Double(textEntered) {
                print("Converted text to double \(entryPrice)")
                RealmHelpers().makeEntry(taskID: taskID, entry: entryPrice, stop: stop, target: target, shares: shares, risk: Double(currentRisk), debug: true, account: account, capital: capReq)
                sequeToPortfolio()
            }
        case "Target":
            if let exitPrice = Double(textEntered) {
                print("Closing the trade, target hit, sending target for \(ticker) of \(exitPrice) to ManageTrade()")
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

    func populateLables(action: String, debug: Bool) {
        
        if debug { print("\npopulate lables") }
        if (action == "Entry For") {
            print("\n calc trade entry, then populate lables\n")
            //thisTrade = Prices().getFrom(taskID: taskID).last!
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
            let cashCom = Utilities().dollarStr(largeNumber:portfolioCost)
            cashCommited.text = "$\(cashCom) Comitted"
            textInput.text = String(thisTrade.close)
            topLeft.text = "\(action) \(thisTrade.ticker)"
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
        } else {
            thisTrade = RealmHelpers().getEntryFor(taskID: taskID).last!
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
