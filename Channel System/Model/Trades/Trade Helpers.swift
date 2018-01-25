//
//  Trade Helpers.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class TradeHelpers {
    
    /**
     - Author: Warren Hansen
     - close: Double - the close of last bar
     - returns: stop, target, stopDistance
     ### Declare As:
    let stop = TradeHelpers().calcStopTarget(close: close).0
     */
    func calcStopTarget(ticker: String, close: Double, debug: Bool)->(stop:Double,target:Double, stopDistance:Double) {
        if let thisTicker = CompanyData().getExchangeFrom(ticker: ticker, debug: false) {
            if debug { print("\(thisTicker.ticker) \(thisTicker.name) \(thisTicker.stockExchange)") }
            let thisTickersStop = Double(thisTicker.stopSize) * 0.01
            let stopDistance = close * thisTickersStop
            let stop = close - stopDistance
            let target = close + stopDistance
            return  (stop: stop, target: target, stopDistance: stopDistance)
        } else {
            print("\n*** Warning *** Couldn't get company data for \(ticker)\nsetting stop at5%\n")
            let thisTickersStop = Double(5) * 0.01
            let stopDistance = close * thisTickersStop
            let stop = close - stopDistance
            let target = close + stopDistance
            return (stop: stop, target: target, stopDistance: stopDistance)
        }
    }
    
    func stopString(stop:Double)-> String {
        return String(format: "%.2f", stop)
    }
    
    func calcShares(stopDist:Double, risk:Int)-> Int {
        let shares = Double(risk) / stopDist
        return Int( shares )
    }
    
    func capitalRequired(close: Double, shares: Int)-> Double {
        return close * Double( shares )
    }
    
    func totalOpenProfit(tasks:Results<Prices>, debug:Bool)->(String,String) {
        var sum = 0.00
        var wins = 0.00
        for each in tasks {
            let thisSymbol = Prices().sortOneTicker(ticker: each.ticker, debug: false).last
            let profit:Double = (thisSymbol!.close - each.entry ) * Double(each.shares)
            if debug {print("\(each.ticker) profit: \(String(format: "%.2f", profit)) = c:\(thisSymbol!.close) - e:\(each.entry) * s:\(each.shares)")}
            sum += profit
            if profit > 0 {
                wins += 1
            }
        }
        let winPct = (wins / Double(tasks.count)) * 100
        let winPctStr = String(format: "%.2f", winPct)
        return (String(format: "%.2f", sum), winPctStr)
    }
    
    func totalClosedProfit(tasks:Results<Prices>, debug:Bool)->(String,String) {
        var sum = 0.00
        var wins = 0.00
        for each in tasks {
            
            let profit:Double = each.profit
            if debug {print("\(each.ticker) profit: \(String(format: "%.2f", profit))")}
            sum += profit
            if profit > 0 {
                wins += 1
            }
        }
        let winPct = (wins / Double(tasks.count)) * 100
        let winPctStr = String(format: "%.2f", winPct)
        return (String(format: "%.2f", sum), winPctStr)
    }
    
    func calcGainOrLoss(thisTrade:Prices, textEntered:String, taskID:String, shares:Int, entryPrice:Double, capReq:Double, account:String)-> Double {
        print("This is the taskID passes in to calcGain \(taskID)")
        if let exitPrice = Double(textEntered) {
            print("\n-----> We have  if let exitPrice of \(exitPrice)<------\n")
            //let entryPrice:Double = thisTrade.entry
            //let shares:Int = thisTrade.shares
            let result:Double = (exitPrice - entryPrice) * Double(shares)
            if ( result >= 0 ) {
                print("\nCalc gain of \(result)")
                RealmHelpers().updateRealm(thisTrade: thisTrade, gain: result, loss: 0.0, account: account, capReq: capReq)
            } else {
                print("\nCalc loss of \(result)")
                RealmHelpers().updateRealm(thisTrade: thisTrade, gain: 0.0, loss: result, account: account, capReq: capReq)
            }
            return result
        } else {
            return 0.00
        }
    }
    
    func proveUpdateTrade(taskID:String) {
        print("Proof the trade has been updated for taskID \(taskID)")
        let checkTrades:Results<Prices> = RealmHelpers().checkExitedTrade(taskID: taskID)
        print("\ndubug - checkTrades")
        debugPrint(checkTrades)
    }
}
