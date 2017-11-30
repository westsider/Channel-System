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
    func calcStopTarget(close: Double)->(Double,Double, Double) {
        let stopDistance = close * 0.03
        let stop = close - stopDistance
        let target = close + stopDistance
        return (stop: stop, target: target, dist: stopDistance)
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
