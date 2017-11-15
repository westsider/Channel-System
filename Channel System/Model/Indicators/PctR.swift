//
//  PctR.swift
//  Channel System
//
//  Created by Warren Hansen on 11/15/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class PctR {
    
    func williamsPctR(debug: Bool, prices: [LastPrice] )-> [LastPrice]  {
        // %R = (Highest High – Closing Price) / (Highest High – Lowest Low) x -100
        let sortedPrices = prices
        // need to find HH + LL of last N periods
        var highs = [Double]()
        var lows = [Double]()
        var highestHigh = [Double]()
        var lowestLow = [Double]()
        for each in sortedPrices {
            highs.append(each.high!)
            lows.append(each.low!)
        }
        
        // max high of last 10
        var highArray = [Double]()
        for high in highs {
            highArray.append(high)
            if highArray.count > 10 {
                highArray.remove(at: 0)
            }
            highestHigh.append(highArray.max()!)
        }
        
        // min low of last 10
        var lowArray = [Double]()
        for low in lows {
            lowArray.append(low)
            if lowArray.count > 10 {
                lowArray.remove(at: 0)
            }
            lowestLow.append(lowArray.min()!)
        }
        
        //(Highest High – Closing Price)
        var leftSideEquation = [Double]()
        for ( index, each ) in sortedPrices.enumerated() {
            let answer = highestHigh[index] - each.close!
            leftSideEquation.append(answer)
        }
        
        //(Highest High – Lowest Low)
        var rightSideEquation = [Double]()
        for ( index, eachLow ) in lowestLow.enumerated() {
            let answer = highestHigh[index] - eachLow
            rightSideEquation.append(answer)
        }
        
        // divide then multiply answer
        for ( index, each ) in sortedPrices.enumerated() {
            var answer = leftSideEquation[index] / rightSideEquation[index]
            answer = answer * -100
            each.wPctR = answer
            if ( debug) {
                print("\(each.ticker!) wPctR: \(answer)")
                if ( answer > 300 || answer < -300) {
                    print("\n----------> \(answer) is suspicious!\n")
                    each.wPctR = 0.00
                }
            }
            //print("%R \(answer) = (Highest High – Closing Price) \(leftSideEquation[index]) / (Highest High – Lowest Low) \( rightSideEquation[index]) x -100")
        }
        if ( debug ) { print("\nFinished calc for wPctR for \(String(describing: prices.last!.ticker!))\n") }
        return sortedPrices
    }
}
