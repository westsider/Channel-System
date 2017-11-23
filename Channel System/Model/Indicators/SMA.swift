//
//  SMA.swift
//  Channel System
//
//  Created by Warren Hansen on 11/15/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class SMA {
    
    func averageOf(period:Int, debug: Bool, priorCount: Int, prices: Results<Prices>, completion: @escaping () -> ()) {
        
        let sortedPrices = prices
        
        // count objects in old realm = 300
        
        var closes = [Double]()
        
        for eachClose in sortedPrices {
            closes.append(eachClose.close)
        }
        
        var sum:Double
        var tenPeriodArray = [Double]()
        var averages = [Double]()
        for close in closes {
            tenPeriodArray.append(close)
            if tenPeriodArray.count > period {
                tenPeriodArray.remove(at: 0)
                sum = tenPeriodArray.reduce(0, +)
                let average = sum / Double(period)
                averages.append(average)
            } else {
                averages.append(close)
            }
        }
        
        if ( debug ) { print("\nFinished calc for\(period) SMA for \(String(describing: sortedPrices.last!.ticker))\n") }
        if ( period == 10 ) {
            for (index, eachAverage) in averages.enumerated() {
                
                // skip value already calculated
                if ( index < priorCount ) {
                    if ( debug ) { print("skip index \(index)") }
                } else {
                    if ( debug ) { print("calculating \(index)") }
                
                    let realm = try! Realm()
                    try! realm.write {
                        sortedPrices[index].movAvg10 = eachAverage
                    }
                    if ( debug ) {print("\(sortedPrices[index].close) \(eachAverage)") }
                }
            }
        } else {
            for (index, eachAverage) in averages.enumerated() {
                
                // skip value already calculated
                if ( index < priorCount ) {
                    if ( debug ) { print("skip index \(index)") }
                } else {
                    if ( debug ) { print("calculating \(index)") }
                    let realm = try! Realm()
                    try! realm.write {
                        sortedPrices[index].movAvg200 = eachAverage
                    }
                    if ( debug ) { print("\(sortedPrices[index].close) \(eachAverage)") }
                }
            }
        }
        if (debug) {
            // show SMA 10 on Spy
            let smaTicker = Prices().sortOneTicker(ticker: "SPY", debug: false)
            // Print results
            for each in smaTicker {
                
                print("\(each.ticker) \(each.dateString) c:\(String(format: "%.02f", each.close)) 10:\(String(format: "%.02f",each.movAvg10))")
            }
        }
        DispatchQueue.main.async {
            completion()
        }
    }
}


