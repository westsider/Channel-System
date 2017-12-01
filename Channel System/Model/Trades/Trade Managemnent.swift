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
        for trades in tasks {
            print("\(trades.dateString) \(trades.ticker) close:\(trades.close) risk:\(trades.risk)")
        }
    }
    
    //MARK: - Stop 3% dow s&p, 5% others = Remove from portfolio
    // might have to get the taskID for trade
    fileprivate func checkStop() {
        for trades in tasks {
            if trades.close < trades.stop {
                // alert vc for stop hit
                
                
                try! realm.write {
                    trades.loss = trades.risk
                    trades.shares    = 0
                    trades.exitDate = Date()
                    trades.exitedTrade = true
                    trades.inTrade   = false
                }
            }
        }

    }
    //MARK: - Exit after 7 trading days, Trail stop
    
    //MARK: - Sell above PctR(10) > -30
    
}
