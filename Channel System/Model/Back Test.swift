//
//  Back Test.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class BackTest {
    
    func getResults(ticker: String)->(Double, Double, Double) {
    
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        
        var flat = true
        var entryPrice = 0.00
        var gain = 0.00
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
            if flat && each.longEntry {
                flat = false
                entryPrice = each.close
                daysInTrade = 0
                tradeCount += 1
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
                    gain += (each.close - entryPrice) * shares
                    winCount += 1
                } else if !flat && daysInTrade == 7 {
                    flat = true
                    gain += (each.close - entryPrice) * shares
                    if (( each.close - entryPrice ) >=  0 ) {
                        winCount += 1
                    }
                } else if !flat && each.low <= stop {
                    flat = true
                    gain += ( entryPrice - each.low ) * shares
                }
            }
        }
        
        //MARK: - TODO - calc gain, roi, win%
        //MARK: - TODO - rank tickers ( score 50% each for  roi > 10% = 50% < 5% = 0, winPct literal ) = 80% = 4 stars, 100% = 5 stars
        // unsure how to annualize roi, 200 days?
        //MARK: - TODO - save to realm STATS object
        
        return ( gain, roi, winPct )
    }
    //MARK: - TODO - create basic stats vc with backtest button
    //MARK: - TODO - load with candidates tableview | SPY 70% $11,021 18.7% ROI ⭐️⭐️⭐️⭐️⭐️ |
    //MARK: - TODO - add STATS to PRICES object when loadDataFeed
    //MARK: - TODO - Stats VC scrollview of: stats as lables at top, graph p&L, sorted tableview,
}
