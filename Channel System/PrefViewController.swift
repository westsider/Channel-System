//
//  PrefViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 12/10/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift
import NVActivityIndicatorView

class PrefViewController: UIViewController, UITextViewDelegate, NVActivityIndicatorViewable {
    
    //all buttons
    @IBOutlet weak var riskBttn: UIButton!
    @IBOutlet weak var ibBttn: UIButton!
    @IBOutlet weak var tdaBttn: UIButton!
    @IBOutlet weak var etradeBttn: UIButton!
    @IBOutlet weak var csvBttn: UIButton!
    @IBOutlet weak var sma10Bttn: UIButton!
    @IBOutlet weak var sma200Bttn: UIButton!
    @IBOutlet weak var wPctRbttn: UIButton!
    @IBOutlet weak var entriesBttn: UIButton!
    @IBOutlet weak var backtestBttn: UIButton!
    @IBOutlet weak var starsButton: UIButton!
    
    // all labels
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
    @IBOutlet weak var acctTotalLabel: UILabel!
    @IBOutlet weak var starsTextField: UITextField!
    
    var galaxie = [String]()
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let infoBlock = { print( "\nCompany Info Returned <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    let backtestBlock = { print( "\nBackTest finished  <----------\n" ) }
    let calcStatsBlock = { print( "\nCalc Stats finished  <----------\n" ) }
    let size = CGSize(width: 100, height: 100)
    var symbolCount = 0
    var textEntered:String = "No Text"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Account().debugAccount()
        title = "Preferences"
        populateLables()
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 100)
        symbolCount = galaxie.count
    }
    
    
    @IBAction func changeStarsAction(_ sender: Any) {
        if (starsTextField.text! != "") {
            textEntered = starsTextField.text!
            // convert text entered to double
            if let numberStars = Int(textEntered) {
                // safely get number from risk
                Stats().changeMinStars(stars: numberStars)
                print("\n-------> Saved new stars of \(numberStars) <------\n")
            } else {
                print("\n-------> ERROR unwrapping stars <------\n")
            }
        } else {
            print("\n-------> ERROR reading stars String <------\n")
        }
    }
    
    func populateLables() {
        let riskRecd = Account().currentRisk()
        print("Loading risk of \(riskRecd)")
        //riskLabel.text = "\(riskRecd)"
        riskLabel.text = Account().textValueFor(account: "Risk")
        ibLabel.text = Account().textValueFor(account:"IB" )
        tdaLabel.text = Account().textValueFor(account:"TDA" )
        etradeLabel.text = Account().textValueFor(account:"E*Trade" )
        acctTotalLabel.text = Account().textValueFor(account:"Accounts" )
        starsTextField.text = "\(Stats().getStars())"
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
                print("\nNow running getEveryEntry to reset shares, stop and capRequired\n")
                recCalcEntry(debug: true)
            } else {
                print("\n-------> ERROR unwrapping Risk <------\n")
            }
        } else {
            print("\n-------> ERROR reading Risk String <------\n")
        }
        
        //MARK: - call entries then backtest then update realm then segue
        // entriesWithCompletion(completion: entryBlock)
    }
    
    func recCalcEntry(debug:Bool) {
        startAnimating(self.size, message: "Optimizing Portfolio", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballClipRotateMultiple.rawValue)!, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),  textColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
            if finished  {
                print("Entry done")
                self.updateNVActivity(with:"Recalculating Stars")
                CalcStars().backtest(galaxie: self.galaxie, debug: debug, completion: {
                    print("\ncalc Stars done!\n")
                    self.stopAnimating()
                })
            }
        })
    }
    
    @IBAction func ibAction(_ sender: Any) {
        if (ibLabel.text! != "") {
            textEntered = ibLabel.text!
            // convert text entered to double
            if let number = Double(textEntered) {
                // safely get number from risk
                Account().updateIB(ib: number)
                print("\n-------> Saved IB of \(number) <------\n")
            } else {
                print("\n-------> ERROR unwrapping IB <------\n")
            }
        } else {
            print("\n-------> ERROR reading IB String <------\n")
        }
    }
    
    @IBAction func tdaAction(_ sender: Any) {
        if (tdaLabel.text! != "") {
            textEntered = tdaLabel.text!
            // convert text entered to double
            if let number = Double(textEntered) {
                // safely get number from risk
                Account().updateTDA(tda: number)
                print("\n-------> Saved TDA of \(number) <------\n")
            } else {
                print("\n-------> ERROR unwrapping TDA <------\n")
            }
        } else {
            print("\n-------> ERROR reading TDA String <------\n")
        }
    }
    
    @IBAction func etradeAction(_ sender: Any) {
        if (etradeLabel.text! != "") {
            textEntered = etradeLabel.text!
            // convert text entered to double
            if let number = Double(textEntered) {
                // safely get number from risk
                Account().updateEtrade(eTrade: number)
                print("\n-------> Saved Etrade of \(number) <------\n")
            } else {
                print("\n-------> ERROR unwrapping Etrade <------\n")
            }
        } else {
            print("\n-------> ERROR reading Etrade String <------\n")
        }
    }
    
    @IBAction func csvAction(_ sender: Any) {

    }
    
    @IBAction func smaTenAction(_ sender: Any) {

    }
    
    @IBAction func smaTwoHundrd(_ sender: Any) {

    }
    
    @IBAction func williamsPctAction(_ sender: Any) {

    }
    
    @IBAction func entriesAction(_ sender: Any) {
        entriesWithCompletion(completion: entryBlock)
    }
    
    func entriesWithCompletion(completion: @escaping () -> ()) {
        var count = 0
        Entry().getEveryEntry(galaxie: galaxie, debug: true, completion: { (finished) in
            if finished  {
                print("Entry done")
                CalcStars().backtest(galaxie: self.galaxie, debug: true, completion: {
                    print("\ncalc Stars done!\n")
                    
                })
            }
        })
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
                    self.entriesLabel.text = "Updated"
                    completion()
                    self.backtest(completion: self.backtestBlock)
                }
            }
        }
    }
    
    @IBAction func backtestAction(_ sender: Any) {
        //backtest(completion: backtestBlock)
    }
    
    func backtest(completion: @escaping () -> ()) {
        var count = 0
        var tickerStar = [(ticker:String, grossProfit:Double, Roi:Double, WinPct:Double)]()
        DispatchQueue.global(qos: .background).async {
            for ( symC, symbols) in self.galaxie.enumerated() {
                DispatchQueue.main.async {
                    self.backTestLabel.text = "profit \(symC) of \(self.galaxie.count)"
                }
                let results =   BackTest().enterWhenFlat(ticker: symbols, debug: false, updateRealm: true)
                tickerStar.append((ticker: symbols, grossProfit: results.0, Roi: results.3, WinPct: results.4))
                print("\(symC) of \(self.symbolCount)")
            }
            // loop through array and update stars
            for (index, each) in tickerStar.enumerated() {
                count = index
                DispatchQueue.main.async {
                    self.backTestLabel.text = "star calc \(count) of \(tickerStar.count)"
                }
                let stars = CalcStars().calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: false)
                Prices().addStarToTicker(ticker: each.ticker, stars: stars.stars, debug: true)
                count += 1
            }
            print("\nYo - Exited 2nd loop with count of \(count) and tickerStar count is \(tickerStar.count)")
            DispatchQueue.main.async {
                if count == tickerStar.count {
        
                    self.backTestLabel.text = "Updated"
                    completion()
                }
            }
        }
    }

    
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
        }
    }
    
    func segueToStats() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        navigationController?.pushViewController(myVC, animated: true)
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
        starsTextField.resignFirstResponder()
        return true
    }
}
