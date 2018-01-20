//
//  3.0 Every Entry.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation
import RealmSwift

class Entry {
    
    let currentRisk = Account().currentRisk()
    
    /**
     - Author: Warren Hansen
     - Step 1 of 3 Complete backtest process
     -      Entry().getEntry()
     -      CalcStars().backTest() calls BackTest().bruteForceTradesForEach()
     -      weeklyProfit()  # the mess
     - loop though each Prices sorted by tickerate and d
     - update realm with longEntry, shares, target, stop, cap required
     ### Declare As:
            let done = self.calcLongForOnly(ticker: symbols, deBug: debug)
     ## galaxie ttt
     */
    func getEveryEntry(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        var counter = 0
        let total = galaxie.count
        var done:Bool = false
        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                done = false
                done = self.calcLongForOnly(ticker: symbols, deBug: debug)
                if done {
                    DispatchQueue.main.async {
                        counter += 1
                        print("Entry \(counter) of \(total)")
                        if counter == total {
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func testGetEntry(galaxie: [String], summaryOnly:Bool){
        var totalEntries:Int = 0
        var totalTickers:Int = 0
        for ticker in galaxie {
            var counter:Int = 0
            let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
            for each in prices {
                if each.longEntry {
                    counter += 1
                }
                
            }
            totalTickers += 1
            totalEntries += counter
            if !summaryOnly { print("\(prices.last?.ticker ?? "nil") had \(counter) entries. Total Entries: \(totalEntries) Total Tickers \(totalTickers)") }
        }
        
        print("\n---------------------------------------\n\t\tSummary of Entry test\nTotal Entries \(totalEntries), Total Tickers \(totalTickers)\n---------------------------------------\n")
        
    }
    func calcLongForOnly(ticker:String, deBug:Bool)->Bool {
        print("Getting all dates for \(ticker) to calc entries")
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        let realm = try! Realm()
        for each in prices {
            if ( each.close < each.movAvg10 && each.close > each.movAvg200 && each.wPctR < -80 ) {
                try! realm.write {
                    let stopDist = TradeHelpers().calcStopTarget(ticker: each.ticker, close: each.close, debug: false)
                    let shares = TradeHelpers().calcShares(stopDist: stopDist.2, risk: currentRisk)
                    each.longEntry = true
                    each.shares = shares
                    each.capitalReq = TradeHelpers().capitalRequired(close: each.close, shares: shares)
                    each.stop = stopDist.0
                    each.target = stopDist.1
                }
                if ( deBug ) { print("LE on \(each.dateString)") }
            }
        }
        print("Calc long for \(ticker) only complete")
        return true
    }

    func resetEntryFor(ticker: String, reset:Bool) {
        
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        
        if reset {
            for each in prices {
                
                let realm = try! Realm()
                try! realm.write {
                    each.longEntry = false
                    each.backTestProfit = 0.00
                    each.shares = 0
                    each.capitalReq = 0.00
                    each.stop = 0.00
                    each.target = 0.00
                }
            }
        }
        print("Reset of \(ticker) complete")
    }

    func calcLong(lastDate: Date, debug: Bool, prices: Results<Prices>, completion: @escaping () -> ()) {
        let realm = try! Realm()
        let sortedPrices = prices
        for ( index, each) in sortedPrices.enumerated() {
            // add long entry if none exists
            // need to find a better filer than this
            if ( sortedPrices[index].date! > lastDate ) {
                if ( each.close < each.movAvg10 && each.close > each.movAvg200 && each.wPctR < -80 ) {
                    try! realm.write {
                        let stopDist = TradeHelpers().calcStopTarget(ticker: each.ticker, close: each.close, debug: false)
                        let shares = TradeHelpers().calcShares(stopDist: stopDist.2, risk: currentRisk)
                        each.longEntry = true
                        each.shares = shares
                        each.capitalReq = TradeHelpers().capitalRequired(close: each.close, shares: shares)
                        each.stop = stopDist.0
                        each.target = stopDist.1
                    }
                    if ( debug ) { print("LE on \(each.dateString)") }
                } else {
                    try! realm.write {
                        each.longEntry = false
                    }
                }
            }
        }
    }
}
