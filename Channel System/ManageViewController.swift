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
    @IBOutlet weak var topLeft: UILabel! // Entry For
    
    @IBOutlet weak var topRight: UILabel! // QQQ
    
    @IBOutlet weak var midLeft: UILabel!
    
    @IBOutlet weak var midRight: UILabel!
    
    @IBOutlet weak var bottomLeft: UILabel!
    
    @IBOutlet weak var bottomRight: UILabel!
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var accountSwitch: UISegmentedControl!
    
    var taskID = ""
    
    var action = ""
    
    var thisTrade = Prices()
    
    var textEntered = "No Text"
    
    // preserve calc of shares ect
    var close = 0.0
    var stopDistance = 0.0
    var stop = 0.0
    var target = 0.0
    var stopString = " "
    let risk = 50
    var shares = 0
    var account = "TDA"
    
    override func viewWillAppear(_ animated: Bool) {
        print("This is the taskID passes in to VC \(taskID)")
        populateLables(action: action)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Trade"
    }
    
    @IBAction func accountSwitchAction(_ sender: UISegmentedControl) {
        
        switch accountSwitch.selectedSegmentIndex {
        case 0: account = "TDA";
        case 1: account = "E*Trade";
        case 2: account = "IB";
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
// stupmed why jumping past this vc to Candidates when I have a trade to enter
        switch action {
        case "Entry For":
            print("In Manage VC case Entry Triggered")
            //MARK: - TODO - make entry func
            if let entryPrice = Double(textEntered) {
                RealmHelpers().makeEntry(taskID: taskID, entry: entryPrice, stop: stop, target: target, shares: shares, risk: Double(risk), debug: false)
                sequeToPortfolio()
            }
        case "Target":
            let thisResult = calcGainOrLoss()
            print("\nclose the trade, add gain of \(thisResult) from Target at \(textEntered)\n")
        case "Stop":
            let thisResult = calcGainOrLoss()
            print("\nclose the trade, add loss of \(thisResult) from stop at \(textEntered)\n")
           // let loss = entryPrice - exitPrice
            
        case "Pct(R) Target":
            let thisResult = calcGainOrLoss()
            print("\nHere is the trade afer modification\n")
            debugPrint(thisTrade)
            print("\nclose the trade, add gain of \(thisResult) from Pct(R) at \(textEntered) \n")
        case "Date Stop":
            let thisResult = calcGainOrLoss()
            print("\nclose the trade, add result from Date Stop at \(textEntered) \(thisResult)\n")
            
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
            let entryPrice = thisTrade.entry
            let shares = thisTrade.shares
            let result = (exitPrice - entryPrice) * Double(shares)
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
        }
        proveUpdateTrade()
    }
    
    func proveUpdateTrade() {
        print("Proof the trade has been updated for taskID \(taskID)")
        let checkTrades = RealmHelpers().checkExitedTrade(taskID: taskID)
        print("\ndubug - checkTrades")
        debugPrint(checkTrades)
    }
    
    //MARK: - Populate Lables
    func populateLables(action: String) {
        
        print("\npopulate lables")
        

        if (action == "Entry For") {
            print("\n calc trade entry, then populate lables\n")
            thisTrade = Prices().getFrom(taskID: taskID).last!
            debugPrint(thisTrade)
            // calc target / stop
            close = thisTrade.close
            stopDistance = close * 0.03
            stop = close - stopDistance
            target = close + stopDistance
            stopString = String(format: "%.2f", stop)
            shares = RealmHelpers().calcShares(stopDist: stopDistance, risk: risk)
            let message = "Entry:\(close)\tShares:\(shares)\nStop:\(stopString)\tTarget:\(String(format: "%.2f", target))"; print(message)
            // populate lables
            textInput.text = String(thisTrade.close)
            
            topLeft.text = action
            
            topRight.text = thisTrade.ticker
            
            midLeft.text = "Entry \(String(thisTrade.close))"
            
            midRight.text = "\(String(shares)) Shares"
            
            bottomLeft.text = "Stop \(String(format: "%.2f", stop))"
            
            bottomRight.text = "Target \(String(format: "%.2f", target))"
            
        } else {
            
            print("\nJust poplulate lables")
            thisTrade = RealmHelpers().getEntryFor(taskID: taskID).last!
            debugPrint(thisTrade)
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
    //MARK: - Keyboard behavior functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
    
    func sequeToPortfolio() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PortfolioVC") as! PortfolioViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
}
