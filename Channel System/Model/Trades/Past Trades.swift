//
//  Past Trades.swift
//  Channel System
//
//  Created by Warren Hansen on 12/13/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MyPrice {
    
    func profit(ticker: String, date: String, entry:Double, exit:Double, shares: Double)-> (String, Double, Double) {
        var profit:Double = 0.00
        if exit != 0.00 {
            profit = (exit - entry) * shares - (1.05 * 2) // comm
        }
        let cost = shares * entry
        let profitString = String(format: "%.2f", profit)
        let textToShow = "\(ticker)\t\(date)\t\t\(profitString)"
        return (textToShow, profit, cost)
    }
}

class ManualTrades {
    
    func showProfit() {
        var trades = [(ticker:String, profit:Double, cost:Double)]()
        var cumProfit = [Double]()
        var cumCost = [Double]()
        var winCount:Int = 0
        print("\n----------------------------\n \tLive Trades\n----------------------------")
        trades.append( MyPrice().profit(ticker: "DBB", date: "2017-11-28", entry: 18.21, exit: 17.8, shares: 90.00) )
        trades.append( MyPrice().profit(ticker: "KO", date: "2017-11-28", entry: 45.57, exit: 46.19, shares: 36.00) )
        trades.append( MyPrice().profit(ticker: "DJP", date: "2017-12-01", entry: 23.91, exit: 23.05, shares: 100.00) )
        trades.append( MyPrice().profit(ticker: "EWH", date: "2017-12-01", entry: 25.57, exit: 25.35, shares: 65.00) )
        trades.append( MyPrice().profit(ticker: "V", date: "2017-12-05", entry: 108.64, exit: 111.99, shares: 15.00) )
        trades.append( MyPrice().profit(ticker: "SMH", date: "2017-12-05", entry: 97.4, exit: 97.8, shares: 17.00) )
        trades.append( MyPrice().profit(ticker: "EWT", date: "2017-12-06", entry: 35.98, exit: 36.6, shares: 46.00) )
    trades.append( MyPrice().profit(ticker: "EFA", date: "2017-12-06", entry: 69.28, exit: 70.28, shares: 14.00) )
        trades.append( MyPrice().profit(ticker: "SOXX", date: "2017-12-06", entry: 167.38, exit: 167.87, shares: 5.00) )
        trades.append( MyPrice().profit(ticker: "EEM", date: "2017-12-07", entry: 45.92, exit: 46.45, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWA", date: "2017-12-07", entry: 22.6, exit: 23.17, shares: 73.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "2017-12-08", entry: 74.38, exit: 75.54, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWT", date: "2017-12-08", entry: 36.28, exit: 36.6, shares: 45.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "2017-12-08", entry: 74.38, exit: 75.55, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWI", date: "2017-12-14", entry: 30.84, exit: 30.70, shares: 53.00) )
        trades.append( MyPrice().profit(ticker: "EWI", date: "2017-12-15", entry: 30.38, exit: 30.70, shares: 54.00) )
        trades.append( MyPrice().profit(ticker: "RSX", date: "2017-12-19", entry: 20.82, exit: 21.71, shares: 80.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "12017-12-19", entry: 73.00, exit: 74.84, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "TLT", date: "2017-12-19", entry: 125.64, exit: 126.94, shares: 7.00) )
    trades.append( MyPrice().profit(ticker: "EFA", date: "2017-12-20", entry: 69.74, exit: 70.73, shares: 14.00) )
        trades.append( MyPrice().profit(ticker: "MCD", date: "12017-12-20", entry: 172.21, exit: 173.33, shares: 9.00) )
        trades.append( MyPrice().profit(ticker: "MMM", date: "12017-12-20", entry: 237.05, exit: 235.11, shares: 7.00) )
        trades.append( MyPrice().profit(ticker: "VEA", date: "2017-12-22", entry: 44.58, exit: 45.19, shares: 37.00) )
        trades.append( MyPrice().profit(ticker: "UNH", date: "2017-12-22", entry: 220.07, exit: 225.65, shares: 7.00) )
        trades.append( MyPrice().profit(ticker: "AAPL", date: "2017-12-27", entry: 170.27, exit: 174.9, shares: 5.00) )
        trades.append( MyPrice().profit(ticker: "IFY", date: "2017-01-3", entry: 119.41, exit: 120.69, shares: 13.00) )
        trades.append( MyPrice().profit(ticker: "FXO", date: "2017-01-3", entry: 31.28, exit: 31.68, shares: 53.00) )
        trades.append( MyPrice().profit(ticker: "PG", date: "2017-01-3", entry: 90.80, exit: 90.87, shares: 18.00) )
        
        for each in trades {
            print("\(each.ticker)")
            cumProfit.append(each.1)
            cumCost.append(each.2)
            if each.1 >= 0 {
                winCount += 1
            }
        }
        print("\n----------------------------\n")
        let profitSum = cumProfit.reduce(0, +)
        let profitSumStr = String(format: "%.2f", profitSum)
        let winPct = ( Double(winCount) / Double(cumProfit.count) ) * 100
        let winPctStr = String(format: "%.1f", winPct)
        
        // simplified cost accounting
        let costSum = cumCost.reduce(0, +)
        let avgCost = ( Int(costSum) / trades.count ) / 2 // using 2:1 margin
        let meanCost = avgCost  * 7
        let approxRoi = ( profitSum / Double(meanCost) ) * 100  // 1 month of profits
        let approxRoiStr = String(format: "%.2f", approxRoi)
        let annumRoi = approxRoi * 12
        let annumRoiStr = String(format: "%.2f", annumRoi)
        let annumReturn = (annumRoi * 0.01) * 850000
        let annumReturnStr = Utilities().dollarStr(largeNumber: annumReturn)
        print("Total\t\t$\(profitSumStr)\t\(winPctStr)% win\n\n$\(avgCost) avg cost\t\t$\(meanCost) mean cost\n\(approxRoiStr)% roi\t\t\t\(annumRoiStr)% annual return\n$\(annumReturnStr) annual gain\n\n")

        makePastEntry(yyyyMMdd: "2017-12-06", ticker: "EFA", entry: 69.74, stop: 66.24, target: 73.21, shares: 14, risk: 50.00, account: "IB")
        //makePastExit(yyyyMMdd: "2017-12-20", exityyyyMMdd: "2017-12-06", ticker: "EFA", debug: false)
        //RealmHelpers().getOpenTrades()
        //EFA    2017-12-06        11.90
      
        //removeEntry(yyyyMMdd: "2018-01-16", ticker: "EFA", debug: true)
        
    }
    
    //this func is not adding entry risk intrade
    func makePastEntry(yyyyMMdd: String, ticker: String, entry:Double, stop:Double, target:Double, shares:Int, risk:Double, account:String) {
        let myTaskID = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
        if myTaskID == "noTaskID" {
            print("no TaskID found, cancel entry")
            return
        }
        print("Found TaskID: \(myTaskID) for \(ticker)")
        let tickerInQuestion = Prices().getOneDateFrom(taskID: myTaskID)
        print("\nThis is \(ticker) on \(yyyyMMdd)")
        print(tickerInQuestion)
        print("")
        let capitol = entry * Double(shares)
        RealmHelpers().makeEntry(taskID: myTaskID, entry: entry, stop: stop, target: target, shares: shares, risk: risk, debug: false, account: account, capital: capitol)
        print("\nProve it:")
        let tickerModified = Prices().getOneDateFrom(taskID: myTaskID)
        debugPrint(tickerModified)
        print("")
    }
    
    func makePastExit(yyyyMMdd: String,exityyyyMMdd:String,  ticker: String, debug:Bool) {
        let tradeEntryID = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
        print("Found Entry TaskID: \(tradeEntryID) for \(ticker)")
        let entryToExit = Prices().getOneDateFrom(taskID: tradeEntryID)
        print("\nThis is \(ticker) on \(yyyyMMdd)")
        debugPrint(entryToExit)
        print("")
        
        // get exit price
        let tradeExitID = RealmHelpers().getTaskIDfor(yyyyMMdd: exityyyyMMdd, ticker: ticker)
        print("Found Entry TaskID: \(tradeEntryID) for \(ticker)")
        let exit = Prices().getOneDateFrom(taskID: tradeExitID)
        print("\nThis is \(ticker) on \(exityyyyMMdd)")
        debugPrint(exit)
        print("")
        
//        //let closed = Prices().getOnePriceFrom(taskID: taskID)
//        if debug { print("Changing \(entryToExit.ticker) to exitedTrade = true") }
//
//        let realm = try! Realm()
//        try! realm.write {
//            entryToExit.inTrade = false
//            entryToExit.exitedTrade = true
//            //tickerInQuestion.
//            entryToExit.exitDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: true)
//        }
//        let closedCheck = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
//        if debug { print("\nProve it!")
//            debugPrint(closedCheck) }
    }
    
    func removeEntry(yyyyMMdd: String, ticker: String, debug:Bool) {
        
        let myTaskID = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
        print("Found TaskID: \(myTaskID) for \(ticker)")
        let tickerInQuestion = Prices().getOneDateFrom(taskID: myTaskID)
        print("\nThis is \(ticker) on \(yyyyMMdd)")
        debugPrint(tickerInQuestion)
        print("")
        
        //let closed = Prices().getOnePriceFrom(taskID: taskID)
        if debug { print("Changing \(tickerInQuestion.ticker) to inTrade = false") }
        
        let realm = try! Realm()
        try! realm.write {
            tickerInQuestion.inTrade = false
//            tickerInQuestion.exitedTrade = true
//            tickerInQuestion.exitDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: true)
        }
        let closedCheck = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }
}



























