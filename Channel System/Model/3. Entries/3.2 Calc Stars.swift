//
//  3.2 Calc Stars.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

/**
 - Author: Warren Hansen
 - Step 2 of 3 Complete backtest process
 -      Entry().getEntry()
 -      CalcStars().backTest() calls BackTest().bruteForceTradesForEach()
 -      weeklyProfit()  # the mess
 - loop though each Prices sorted by tickerate and d
 - update realm with longEntry, shares, target, stop, cap required
 ### Declare As:
 let stars = self.calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: debug)
 */
class CalcStars {
    func backtest(galaxie: [String], debug:Bool, completion: @escaping () -> ()) {
        var count = 0
        var allStars:[Int] = []
        var tickerStar = [(ticker:String, grossProfit:Double, Roi:Double, WinPct:Double)]()
        WklyStats().clearWeekly()
        DispatchQueue.global(qos: .background).async {
            var totals:[Double] = [0.0]
            for ( symC, symbols) in galaxie.enumerated() {
                let results =   BackTest().enterWhenFlat(ticker: symbols, debug: debug, updateRealm: true)
                tickerStar.append((ticker: symbols, grossProfit: results.0, Roi: results.3, WinPct: results.4))
                print("\(symC) of \(galaxie.count)")
                totals.append(results.grossProfit)
            }
            let sum = totals.reduce(0, +)
            print("\n---------------------------------------\n\t\tSummary of Brute force backtest\nTotal Tickers \(galaxie.count)\nSum of all trades \(Utilities().dollarStr(largeNumber: sum))\n---------------------------------------\n")
            // loop through array and update stars
            for (index, each) in tickerStar.enumerated() {
                count = index
                let stars = self.calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: debug)
                Prices().addStarToTicker(ticker: each.ticker, stars: stars.stars, debug: debug)
                // array of all stars to get average stars
                allStars.append(stars.stars)
                count += 1
            }
            print("\nYo - Exited 2nd loop with count of \(count) and tickerStar count is \(tickerStar.count)")
            
            DispatchQueue.main.async {
                if count == tickerStar.count {
                    let sumOfStars = allStars.reduce(0, +)
                    let averageStars = Double( sumOfStars / tickerStar.count )
                    print("\n--------------------\nAverage  Stars \(averageStars)\n--------------------\n")
                    Stats().changeAvgStars(avgStars: averageStars)
                    completion()
                }
            }
        }
    }
    
    // ( score 50% each for  , winPct literal ) = 80% = 4 stars, 100% = 5 stars
    func calcStars(grossProfit:Double, annualRoi: Double, winPct:Double, debug:Bool)-> (stars:Int, starIcon:String) {
        var totalPercent = 0.0
        var stars = 0
        var starIcon = "★"
        
        if grossProfit <= 0 {
            return (1, starIcon )
        }
        
        switch annualRoi {
        case 0..<2:
            totalPercent = 25.0
        case 2..<3:
            totalPercent = 50.0
        case 3..<5:
            totalPercent = 75.0
        case 5..<100:
            totalPercent = 120.0
        default:
            totalPercent = 100.0
        }
        // sliding scale for winPct
        switch winPct {
        case 0..<55:
            totalPercent += 0
        case 55..<60:
            totalPercent += 50.0
        case 60..<75:
            totalPercent += 75.0
        case 75..<85:
            totalPercent += 85.00
        case 85..<100:
            totalPercent += 100.0
        default:
            totalPercent += 0.0
        }
        
        // assign stars 1 - 5
        switch totalPercent {
        case 0..<40:
            stars = 1
        case 40..<80:
            stars = 2
        case 80..<120:
            stars = 3
        case 120..<160:
            stars = 4
        case 160...400:
            stars = 5
        default:
            stars = 1
        }
        if debug { print("Total Percent: \(totalPercent) = \(stars) Stars") }
        
        // ⭐️⭐️⭐️⭐️⭐️
        if stars == 2 {
            starIcon = "★★"
        } else if stars == 3 {
            starIcon = "★★★"
        } else if stars == 4 {
            starIcon = "★★★★"
        } else if stars == 5 {
            starIcon = "★★★★★"
        }
        return (stars, starIcon )
    }
}
