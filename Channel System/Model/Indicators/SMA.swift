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
            print("\n---> num of 10 SMA \(averages.count) prior count \(priorCount) closes = \(closes.count) <---\n")
            for (index, eachAverage) in averages.enumerated() {
                // add indicator if none exists
                if ( sortedPrices[index].movAvg10 == 0.0 ) {
                    if ( debug ) { print("adding SMA 10 \(eachAverage) to \(sortedPrices[index].ticker)") }
                    let realm = try! Realm()
                    try! realm.write {
                        sortedPrices[index].movAvg10 = eachAverage
                    }
                }
            }
        } else {
            for (index, eachAverage) in averages.enumerated() {
                
                // add indicator if none exists
                if ( sortedPrices[index].movAvg200 == 0.0 ) {
                    if ( debug ) { print("adding SMA 200 \(eachAverage) to \(sortedPrices[index].ticker)") }
                    let realm = try! Realm()
                    try! realm.write {
                        sortedPrices[index].movAvg200 = eachAverage
                    }
                }
            }
        }

        DispatchQueue.main.async {
            completion()
        }
    }
}


