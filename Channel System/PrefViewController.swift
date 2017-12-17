//
//  PrefViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 12/10/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift

class PrefViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var activityDial: UIActivityIndicatorView!
    
    @IBOutlet weak var riskLabel: UITextField!
    
    @IBOutlet weak var ibLabel: UITextField!
    
    @IBOutlet weak var tdaLabel: UITextField!
    
    @IBOutlet weak var etradeLabel: UITextField!
    
    @IBOutlet weak var csvLabel: UILabel!
    
    @IBOutlet weak var smaLabel: UILabel!
    
    @IBOutlet weak var smaTwoHundoLabel: UILabel!
    
    @IBOutlet weak var williamsPctLabel: UILabel!
    
    @IBOutlet weak var entriesLabel: UILabel!
    
    @IBOutlet weak var backTestLabel: UILabel!
    
    var galaxie = [String]()
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let infoBlock = { print( "\nCompany Info Returned <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    
    var symbolCount = 0
    var textEntered:String = "No Text"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Account().debugAccount()
        title = "Preferences"
        populateLables()
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        symbolCount = galaxie.count
        activityDial.stopAnimating()
    }
    
    func populateLables() {
        let riskRecd = Account().currentRisk()
        print("Loading risk of \(riskRecd)")
        //riskLabel.text = "\(riskRecd)"
        riskLabel.text = Account().textValueFor(account: "Risk")
        ibLabel.text = Account().textValueFor(account:"IB" )
        tdaLabel.text = Account().textValueFor(account:"TDA" )
        etradeLabel.text = Account().textValueFor(account:"E*Trade" )
    }
    
    //MARK: - TODO - need to make an account realm object to track account size and risk
    @IBAction func riskAction(_ sender: Any) {
        if (riskLabel.text! != "") {
            textEntered = riskLabel.text!
            // convert text entered to double
            if let numberRisk = Int(textEntered) {
                // safely get number from risk
                Account().updateRisk(risk: numberRisk )
                print("\n-------> Saved new Risk of \(numberRisk) <------\n")
            } else {
                print("\n-------> ERROR unwrapping Risk <------\n")
            }
        } else {
            print("\n-------> ERROR reading Risk String <------\n")
        }
    }
    
    @IBAction func ibAction(_ sender: Any) {
    }
    
    @IBAction func tdaAction(_ sender: Any) {
    }
    
    @IBAction func etradeAction(_ sender: Any) {
    }
    
    @IBAction func csvAction(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.csvLabel.text = "Loading \(index) of \(self.symbolCount)"
                }
                DataFeed().getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
                count = index
            }
        }
        DispatchQueue.main.async {
            if count == self.symbolCount-1 {
                self.activityDial.stopAnimating()
                self.csvLabel.text = "Updated"
            }
        }
    }
    
    @IBAction func smaTenAction(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.smaLabel.text = "Loading \(index) of \(self.symbolCount)"
                }
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: true, priorCount: oneTicker.count, prices: oneTicker, redoAll: true, completion: self.smaBlock1)
                count = index
            }
            DispatchQueue.main.async {
                if count == self.symbolCount-1 {
                    self.activityDial.stopAnimating()
                    self.smaLabel.text = "Updated"
                }
            }
        }
    }
    
    @IBAction func smaTwoHundrd(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.smaTwoHundoLabel.text = "Loading \(index) of \(self.symbolCount)"
                }
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, priorCount: oneTicker.count, prices: oneTicker, redoAll: true, completion: self.smaBlock1)
                count = index
            }
            DispatchQueue.main.async {
                if count == self.symbolCount-1 {
                    self.activityDial.stopAnimating()
                    self.smaTwoHundoLabel.text = "Updated"
                }
            }
        }
    }
    
    @IBAction func williamsPctAction(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.williamsPctLabel.text = "Loading \(index) of \(self.symbolCount)"
                }
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(priorCount: oneTicker.count, debug: false, prices: oneTicker, redoAll: true, completion: self.wPctRBlock)
                count = index
            }
            DispatchQueue.main.async {
                if count == self.symbolCount-1 {
                    self.activityDial.stopAnimating()
                    self.williamsPctLabel.text = "Updated"
                }
            }
        }
    }
    
    @IBAction func entriesAction(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.entriesLabel.text = "Loading \(index) of \(self.symbolCount)"
                }
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                let firstDate  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false)
                Entry().calcLong(lastDate: firstDate, debug: false, prices: oneTicker, completion: self.entryBlock)
                count = index
                print("\(count) of \(self.symbolCount)")
            }
            DispatchQueue.main.async {
                if count == self.symbolCount-1 {
                    self.activityDial.stopAnimating()
                    self.entriesLabel.text = "Updated"
                }
            }
        }
    }
    
    @IBAction func backtestAction(_ sender: Any) {
        activityDial.startAnimating()
        var count = 0
        var tickerStar = [(ticker:String, grossProfit:Double, Roi:Double, WinPct:Double)]()
        DispatchQueue.global(qos: .background).async {
            for ( symC, symbols) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.backTestLabel.text = "profit \(symC) of \(self.galaxie.count)"
                }
                let results =   BackTest().bruteForceTradesForEach(ticker: symbols, debug: false, updateRealm: true)
                tickerStar.append((ticker: symbols, grossProfit: results.0, Roi: results.3, WinPct: results.4))
                print("\(symC) of \(self.symbolCount)")
            }
            // loop through array and update stars
            for (index, each) in tickerStar.enumerated() {
                count = index
                DispatchQueue.main.async {
                    self.backTestLabel.text = "star calc \(count) of \(tickerStar.count)"
                }
                let stars = BackTest().calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: false)
                Prices().addStarToTicker(ticker: each.ticker, stars: stars.stars, debug: true)
            }
            
            DispatchQueue.main.async {
                if count == tickerStar.count-2 {
                    self.activityDial.stopAnimating()
                    self.backTestLabel.text = "Updated"
                }
            }
        }
    }
    
    //MARK: - Keyboard behavior functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        riskLabel.resignFirstResponder()
        ibLabel.resignFirstResponder()
        tdaLabel.resignFirstResponder()
        etradeLabel.resignFirstResponder()
        return true
    }
}
