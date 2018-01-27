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
    @IBOutlet weak var wPctRbttn: UIButton!
    @IBOutlet weak var starsButton: UIButton!
    
    // all labels
    @IBOutlet weak var riskLabel: UITextField!
    @IBOutlet weak var maxPositionsText: UITextField!
    @IBOutlet weak var ibLabel: UITextField!
    @IBOutlet weak var tdaLabel: UITextField!
    @IBOutlet weak var etradeLabel: UITextField!
    @IBOutlet weak var acctTotalLabel: UILabel!
    @IBOutlet weak var starsTextField: UITextField!
    @IBOutlet weak var addTickerText: UITextField!
    
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
    
    // MARK: - Max positions change
    @IBAction func maxPosAction(_ sender: Any) {
        if (maxPositionsText.text! != "") {
            textEntered = maxPositionsText.text!
            // convert text entered to double
            if let numberPos = Int(textEntered) {
                // safely get number from max pos
                UserDefaults.standard.set(numberPos, forKey: "maxPositions")
            }
        }
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
        
        // getting max pos
        if  UserDefaults.standard.object(forKey: "maxPositions") == nil  {
            UserDefaults.standard.set(20, forKey: "maxPositions")
            maxPositionsText.text = "\(10)"
        } else {
            let maxPos:Int = UserDefaults.standard.object(forKey: "maxPositions") as! Int
            maxPositionsText.text = "\(maxPos)"
        }
    }
    
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
                    Utilities().playAlertSound()
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
    
    //MARK: - Add Ticker, must add to ETF200 as well VXF
    @IBAction func addTickerAction(_ sender: Any) {
        if (addTickerText.text! != "") {
            textEntered = addTickerText.text!
            // get companie info
            CompanyData().getInfoFor(ticker: textEntered, debug: true, completion: { (finished) in
                print("Got Comany info for \(self.textEntered)")
                ReplacePrices().writeOverPrblemSymbol(ticker: self.textEntered)
                //MARK: - TODO - need to make user added ticker realm object that is sent to the server so all devices can have access
            })
        } else {
            print("\n-------> ERROR reading Ticker String \(addTickerText.text!) <------\n")
        }
    }
    
    
    @IBAction func apiKeysAction(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        navigationController?.pushViewController(myVC, animated: true)
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
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                let firstDate  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false)
                Entry().calcLong(lastDate: firstDate, debug: false, prices: oneTicker, completion: self.entryBlock)
                count = index
                print("\(count) of \(self.symbolCount)")
            }
            DispatchQueue.main.async {
                if count == self.symbolCount-1 {
                    completion()
                    self.backtest(completion: self.backtestBlock)
                }
            }
        }
    }
    
    func backtest(completion: @escaping () -> ()) {
        var count = 0
        var tickerStar = [(ticker:String, grossProfit:Double, Roi:Double, WinPct:Double)]()
        DispatchQueue.global(qos: .background).async {
            for ( symC, symbols) in self.galaxie.enumerated() {
                let results =   BackTest().enterWhenFlat(ticker: symbols, debug: false, updateRealm: true)
                tickerStar.append((ticker: symbols, grossProfit: results.0, Roi: results.3, WinPct: results.4))
                print("\(symC) of \(self.symbolCount)")
            }
            // loop through array and update stars
            for (index, each) in tickerStar.enumerated() {
                count = index
                let stars = CalcStars().calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: false)
                Prices().addStarToTicker(ticker: each.ticker, stars: stars.stars, debug: true)
                count += 1
            }
            print("\nYo - Exited 2nd loop with count of \(count) and tickerStar count is \(tickerStar.count)")
            DispatchQueue.main.async {
                if count == tickerStar.count {
     
                    completion()
                }
            }
        }
    }
    
    @IBAction func allChartsAction(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DebugVC") as! DeBugViewController
        navigationController?.pushViewController(myVC, animated: true)
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
