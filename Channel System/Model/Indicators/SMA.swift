//
//  SMA.swift
//  Channel System
//
//  Created by Warren Hansen on 11/15/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class SMA {
    
    func averageOf(period:Int, debug: Bool, prices: [LastPrice] )-> [LastPrice]  {
        
        var sortedPrices = prices
        
        var closes = [Double]()
        
        for eachClose in sortedPrices {
            closes.append(eachClose.close!)
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
        
        if ( debug ) { print("\nFinished calc for\(period) SMA for \(String(describing: sortedPrices.last!.ticker!))\n") }
        if ( period == 10 ) {
            for (index, eachAverage) in averages.enumerated() {
                sortedPrices[index].movAvg10 = eachAverage
                //if ( debug ) {print("\(sortedPrices[index].close!) \(eachAverage)") }
            }
        } else {
            for (index, eachAverage) in averages.enumerated() {
                sortedPrices[index].movAvg200 = eachAverage
                //if ( debug ) { print("\(sortedPrices[index].close!) \(eachAverage)") }
            }
        }
        return sortedPrices
    }
}


