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
