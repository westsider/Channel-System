//
//  Back Test.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class BackTest {
    /**
     - Author: Warren Hansen
     - ticker: String - a symbol to retrieve a record
     - returns: grossProfit, roi, winPct
     ### Declare As:
     let result = BackTest().getResults(ticker: "INTC")
     */
    func getResults(ticker: String)->(Double, Double, Double) {
    
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        
        var flat = true
        var entryPrice = 0.00
        var tradeGain = 0.00
        var grossProfit = 0.00
        var daysInTrade = 0
        var tradeCount = 0
        var winCount = 0
        var shares = 100.0
        var stop = 0.00
        var winPct = 0.00
        var roi = 0.00
        var cost = 0.00
        
        for each in prices {
            // enter trade
            // print("\(each.dateString) \(each.close) \(each.ticker)")
            if flat && each.longEntry {
                flat = false
                entryPrice = each.close
                daysInTrade = 0
                tradeCount += 1
                //print("\(each.dateString) Trade count \(tradeCount)")
                let stopDist = TradeHelpers().calcStopTarget(close: entryPrice).2
                shares = Double( TradeHelpers().calcShares(stopDist: stopDist, risk: 250))
                stop =  TradeHelpers().calcStopTarget(close: entryPrice).0
                cost = TradeHelpers().capitalRequired(close: entryPrice, shares: Int(shares))
            }
            // manage trade
            if !flat {
                daysInTrade += 1
                if !flat && each.wPctR > -80 {
                    flat = true
                    tradeGain = (each.close - entryPrice) * shares
                    winCount += 1
                    print("\(each.dateString) Win Pct R")
                } else if !flat && daysInTrade == 7 {
                    flat = true
                    tradeGain = (each.close - entryPrice) * shares
                    if (( each.close - entryPrice ) >=  0 ) {
                        winCount += 1
                        print("\(each.dateString) Win Time stop")
                    } else {
                        print("\(each.dateString) Loss Time stop")
                    }
                } else if !flat && each.low <= stop {
                    flat = true
                    tradeGain = ( entryPrice - each.low ) * shares
                    print("\(each.dateString) Loss stop")
                }
                winPct =   Double( winCount ) / Double( tradeCount ) * 100.00
                let thisROI = tradeGain / cost
                roi += thisROI
                grossProfit += tradeGain
            }
        }
        
        let annualRoi = ( roi / 3.0 ) * 100.00
        print("winPct \(winPct) = winCount \(winCount) / tradeCount \(tradeCount)")
        return ( grossProfit, annualRoi, winPct )
    }
    //MARK: - TODO - rank tickers
    // ( score 50% each for  roi > 10% = 50% < 5% = 0, winPct literal ) = 80% = 4 stars, 100% = 5 stars
    // largest win, largest loss
    //MARK: - TODO - save to realm STATS object
    //MARK: - TODO - load with candidates tableview | SPY 70% $11,021 18.7% ROI ⭐️⭐️⭐️⭐️⭐️ |
    //MARK: - TODO - add STATS to PRICES object when loadDataFeed
    //MARK: - TODO - Stats VC scrollview of: stats as lables at top, graph p&L, sorted tableview,
}
