//
//  Trade Managemnent.swift
//  Channel System
//
//  Created by Warren Hansen on 11/19/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class TradeManage {
    
    let realm = try! Realm()
    //MARK: - check for open entries
    var tasks = RealmHelpers().getOpenTrades()
    
    func printOpenTrades() {
        print("\nShowing all open trades")
        for trades in tasks {
            print("\(trades.dateString) \(trades.ticker) close:\(trades.close) risk:\(trades.risk) cost: \(trades.capitalReq)")
        }
        print("")
    }
    
    //MARK: - Stop 3% dow s&p, 5% others = Remove from portfolio
    // might have to get the taskID for trade
    fileprivate func checkStop() {
        try! realm.write {
            for trades in tasks {
                if trades.close < trades.stop {
                    // alert vc for stop hit
                    //try! realm.write {
                    trades.loss = trades.risk
                    trades.shares    = 0
                    trades.exitDate = Date()
                    trades.exitedTrade = true
                    trades.inTrade   = false
                }
            }
        }
    }

    //MARK: - Make an exit from a specific entry
    func exitTrade(yyyyMMdd: String, ticker: String, exitPrice:Double, debug:Bool) {
        // get entry
        let tickerDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: debug)
        let entryToExit = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        print("\nThis is \(ticker) on \(yyyyMMdd)")
        debugPrint(entryToExit)
        print("")
        
        // calc profit
        let profitForThisTrade = (exitPrice - entryToExit.entry) * Double(entryToExit.shares) - (1.05 * 2) // comm
        print("profit \(profitForThisTrade) =  exit \(exitPrice) - entry \(entryToExit.entry) * shares \(entryToExit.shares)")
        let realm = try! Realm()
        try! realm.write {
            entryToExit.inTrade = false
            entryToExit.exitedTrade = true
            entryToExit.profit = profitForThisTrade
            entryToExit.exitPrice = exitPrice
            entryToExit.exitDate = Date()
        }
        
        let closedCheck = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }

    
}
