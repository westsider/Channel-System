//
//  Trade Helpers.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class TradeHelpers {
    
    /**
     - Author: Warren Hansen
     - close: Double - the close of last bar
     - returns: stop, target, stopDistance
     ### Declare As:
    let stop = TradeHelpers().calcStopTarget(close: close).0
     */
    func calcStopTarget(ticker: String, close: Double, debug: Bool)->(stop:Double,target:Double, stopDistance:Double) {
        if let thisTicker = CompanyData().getExchangeFrom(ticker: ticker, debug: false) {
            if debug { print("\(thisTicker.ticker) \(thisTicker.name) \(thisTicker.stockExchange)") }
            let thisTickersStop = Double(thisTicker.stopSize) * 0.01
            let stopDistance = close * thisTickersStop
            let stop = close - stopDistance
            let target = close + stopDistance
            return  (stop: stop, target: target, stopDistance: stopDistance)
        } else {
            print("\n*** Warning *** Couldn't get stop and target for \(ticker)\n")
            return (stop: 0.0, target: 0.0, stopDistance: 0.0)
        }
    }
    
    func stopString(stop:Double)-> String {
        return String(format: "%.2f", stop)
    }
    
    func calcShares(stopDist:Double, risk:Int)-> Int {
        let shares = Double(risk) / stopDist
        return Int( shares )
    }
    
    func capitalRequired(close: Double, shares: Int)-> Double {
        return close * Double( shares )
    }
}
