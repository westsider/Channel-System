//
//  ProcessCSV.swift
//  Channel System
//
//  Created by Warren Hansen on 11/15/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class ProcessCSV {
    
    // load 1 ticker,
    // process indicators,
    // save to realm
    // get next symbol

    let universe = ["SPY", "QQQ"] //, "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL"]
    
    
//    func calcIndicators(prices: [LastPrice])-> [LastPrice] {
//        var pricesProcessed  = SMA().averageOf(period: 10, debug: true, prices: prices)
//        pricesProcessed  = SMA().averageOf(period: 200, debug: true, prices: pricesProcessed)
//        pricesProcessed  = PctR().williamsPctR(debug: false, prices: pricesProcessed)
//        pricesProcessed = Entry().calcLong(debug: false, prices: pricesProcessed)
//        return pricesProcessed
//    }
//    
//    func saveCSVtoRealm(ticker:String, doneWork: @escaping (Bool) -> Void ) {
//        doneWork(false)
//        //let tickers = loadTicker(ticker: ticker)
//        let tickers = GetCSV().load(fromCSV: ticker, debug: true)
//        let processedTickers = calcIndicators(prices: tickers())
//        //RealmHelpers().saveSymbolsToRealm(prices: processedTickers)
//        doneWork(true)
//    }
//    
//    func loopThroughTickers(doneTickers: @escaping (Bool) -> Void ) {
//        doneTickers(false)
//        for symbol in universe {
//            saveCSVtoRealm(ticker: symbol){ ( doneWork ) in
//                if doneWork {
//                    print("Saved \(symbol) to realm")
//                }
//            }
//        }
//        doneTickers(true)
//    }
}

/*
     Closure example
 
     func makeIncrementer(forIncrement amount: Int) -> () -> Int {
     var runningTotal = 0
     func incrementer() -> Int {
     runningTotal += amount
     return runningTotal
     }
     return incrementer
     }
     
     let incrementByTen = makeIncrementer(forIncrement: 10)
 */

class PresentAlertVC: UIViewController {
    // needs completion handler
    func showIt(trades: Prices )-> ( UIAlertController ) {
        var myReturnText = "nothing"
        //let message = "Entry:\(close)\tShares:\(shares)\nStop:\(stopString)\tTarget:\(String(format: "%.2f", target))"
        let alert = UIAlertController(title: "\(trades.ticker) Stop", message: "Do Some Stuff", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Record", style: .default) { (alertAction) in
            //MARK: - TODO make textField error proof
            let textField = alert.textFields![0] as UITextField
            if let entryString = textField.text {
                myReturnText = entryString
                print("Now Add \(myReturnText) to the realm object")
                
                //now calc the actual loss from string
                let stop = Double(myReturnText)
                let loss = ( trades.entry - stop! ) * Double( trades.shares)
                let realm = try! Realm()
                try! realm.write {
                    trades.loss = loss
                    trades.shares    = 0
                    trades.exitDate = Date()
                    trades.exitedTrade = true
                    trades.inTrade   = false
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
        }
        alert.addTextField { (textField) in
            textField.text = "Hi Warren G"
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
            myReturnText = textField.text!
        }
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated:true, completion: nil)
        return ( alert )
    }
    
}








