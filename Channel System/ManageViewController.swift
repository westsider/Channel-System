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
    
    override func viewWillAppear(_ animated: Bool) {
        let thisTrade = RealmHelpers().getEntryFor(taskID: taskID)
        debugPrint(thisTrade)
        
        if let close = thisTrade.last?.close {
            textInput.text = String(close)
        }
        
        topLeft.text = action
        
        if let ticker = thisTrade.last?.ticker {
            topRight.text = ticker
        }
        
        if let entry = thisTrade.last?.entry {
            midLeft.text = "Entry \(String(entry))"
        }
        
        if let shares = thisTrade.last?.shares {
            midRight.text = "\(String(shares)) Shares"
        }
        
        if let stop = thisTrade.last?.stop {
            bottomLeft.text = "Stop \(String(format: "%.2f", stop))"
        }
        
        if let target = thisTrade.last?.target {
            bottomRight.text = "Target \(String(format: "%.2f", target))"
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Trade"

        // close the trade, add profit/loss
    }

    // MARK: - Keyboard behavior functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
    
    @IBAction func inputTextAction(_ sender: Any) {
        if let thisText = textInput.text {
            print(thisText)
        }
    }
    // unwinnd segue
    @IBAction func cancelAction(_ sender: Any) {
        print("Cancel: Unwind from Manage trades VC")
        self.performSegue(withIdentifier: "unwindToScan", sender: self)
    }
    
    // replace  correct value to realm price object
    @IBAction func recordAction(_ sender: Any) {
        print("Record: Unwind from Manage trades VC")
        self.performSegue(withIdentifier: "unwindToScan", sender: self)
    }
    
    
    
}
