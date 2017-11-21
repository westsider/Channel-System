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
    
    var taskID = ""
    
    var action = ""
    
    var thisTrade = Prices()
    
    var textEntered = "No Text"
    
    override func viewWillAppear(_ animated: Bool) {
        print("This is the taskID passes in to VC \(taskID)")
        populateLables()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Trade"
    }
    
    @IBAction func inputTextAction(_ sender: Any) {
        if let thisText = textInput.text {
            textEntered = thisText
            print(thisText)
        }
    }
    // MARK: - Cancel
    @IBAction func cancelAction(_ sender: Any) {
        print("Cancel: Unwind from Manage trades VC")
        self.performSegue(withIdentifier: "unwindToScan", sender: self)
    }
    
    // MARK: - Record Trade Exit
    @IBAction func recordAction(_ sender: Any) {
        if (textInput.text! != "") {
            textEntered = textInput.text!
        }
        
        switch action {
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
    // fireplace, dog, lights
    
    func updateRealm(gain: Double, loss: Double) {
        // ok - you are updateing the right taskID
        print("This is the taskID passes in to update realm \(thisTrade.taskID)")
        let realm = try! Realm()
        try! realm.write {
            print(Date())
            thisTrade.exitDate = Date()
            print(gain)
            thisTrade.profit = gain
            print(loss)
            thisTrade.loss = loss
            print(true)
            thisTrade.exitedTrade = true
            print(false)
            thisTrade.inTrade = false
        }
        proveUpdateTrade()
    }
    
    func proveUpdateTrade() {
        print("Proving the trade has been updated for taskID \(taskID)")
        let checkTrades = RealmHelpers().checkExitedTrade(taskID: taskID)
        print("\n//ok - lets figure out what this object is...")
        debugPrint(checkTrades)
    }
    
    //MARK: - Populate Lables
    func populateLables() {
        thisTrade = RealmHelpers().getEntryFor(taskID: taskID).last!
        print("\npopulate lables")
        debugPrint(thisTrade)

        textInput.text = String(thisTrade.close)
        
        topLeft.text = action
      
        topRight.text = thisTrade.ticker
   
        midLeft.text = "Entry \(String(thisTrade.entry))"
   
        midRight.text = "\(String(thisTrade.shares)) Shares"
  
        bottomLeft.text = "Stop \(String(format: "%.2f", thisTrade.stop))"
       
        bottomRight.text = "Target \(String(format: "%.2f", thisTrade.target))"
        
    }
    //MARK: - Keyboard behavior functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
    
}
