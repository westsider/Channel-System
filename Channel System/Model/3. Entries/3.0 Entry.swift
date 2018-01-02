//
//  3.0 Entry.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation
import RealmSwift

class Entry {
    
    func getEntry(tenOnly:Bool, debug:Bool, completion: @escaping (Bool) -> Void) {
        let galaxie = SymbolLists().getSymbols(tenOnly: true)
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
    func calcLongForOnly(ticker:String, deBug:Bool)->Bool {
        
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
    //let risk = 50
    let currentRisk = Account().currentRisk()
    
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
        let currentRisk = Account().currentRisk()
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
