//
//  3.2 Calc Stars.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class CalcStars {
    func backtest(testTenOnly: Bool,debug:Bool, completion: @escaping () -> ()) {

        let galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: testTenOnly)
        var count = 0
        var tickerStar = [(ticker:String, grossProfit:Double, Roi:Double, WinPct:Double)]()
        DispatchQueue.global(qos: .background).async {
            for ( symC, symbols) in galaxie.enumerated() {
                let results =   BackTest().bruteForceTradesForEach(ticker: symbols, debug: debug, updateRealm: true)
                tickerStar.append((ticker: symbols, grossProfit: results.0, Roi: results.3, WinPct: results.4))
                print("\(symC) of \(galaxie.count)")
            }
            // loop through array and update stars
            for (index, each) in tickerStar.enumerated() {
                count = index
                let stars = BackTest().calcStars(grossProfit: each.grossProfit, annualRoi: each.Roi, winPct: each.WinPct, debug: debug)
                Prices().addStarToTicker(ticker: each.ticker, stars: stars.stars, debug: debug)
                count += 1
            }
            print("\nYo - Exited 2nd loop with count of \(count) and tickerStar count is \(tickerStar.count)")
            DispatchQueue.main.async {
                if count == tickerStar.count {
                    completion()
                }
            }
        }
    }
}
