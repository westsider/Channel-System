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
        trades.append( MyPrice().profit(ticker: "IYF", date: "2017-01-3", entry: 119.41, exit: 120.69, shares: 13.00) )
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

        // trades.append( MyPrice().profit(ticker: "KO", date: "2017-11-28", entry: 45.57, exit: 46.19, shares: 36.00) )
        // makePastEntry(yyyyMMdd: "2017-11-28", ticker: "KO", entry: 45.57, stop: 44.13, target: 46.99, shares: 36, risk: 50.00, account: "IB")
        // makePastExit(yyyyMMdd: "2017-11-28", exityyyyMMdd: "2017-12-5", ticker: "KO", exitPrice: 46.19, debug: true)
        
        // trades.append( MyPrice().profit(ticker: "DJP", date: "2017-12-01", entry: 23.91, exit: 23.05, shares: 100.00) )
        // makePastEntry(yyyyMMdd: "2017-12-01", ticker: "DJP", entry: 23.91, stop: 22.98, target: 24.40, shares: 100, risk: 50.00, account: "IB")
        // makePastExit(yyyyMMdd: "2017-12-01", exityyyyMMdd: "2017-12-7", ticker: "DJP", exitPrice: 23.05, debug: true)
        
        // trades.append( MyPrice().profit(ticker: "EWH", date: "2017-12-01", entry: 25.57, exit: 25.35, shares: 65.00) )
        //pastEntryAndExit(ticker: "EWH", entryDate: "2017-12-01", exitDate: "2017-12-12", entry: 25.57, stop: 24.78, target: 26.32, shares: 65, exitPrice: 25.35)
        
        // trades.append( MyPrice().profit(ticker: "V", date: "2017-12-05", entry: 108.64, exit: 111.99, shares: 15.00) )
        // pastEntryAndExit(ticker: "V", entryDate: "2017-12-05", exitDate: "2017-12-08", entry: 108.64, stop: 105.45, target: 111.99, shares: 15, exitPrice: 111.99)
        
        // trades.append( MyPrice().profit(ticker: "SMH", date: "2017-12-05", entry: 97.4, exit: 97.8, shares: 17.00) )
        // pastEntryAndExit(ticker: "SMH", entryDate: "2017-12-05", exitDate: "2017-12-08", entry: 97.4, stop: 94.53, target: 100.38, shares: 17, exitPrice: 97.8)
        
        // trades.append( MyPrice().profit(ticker: "EWT", date: "2017-12-06", entry: 35.98, exit: 36.6, shares: 46.00) )
        // pastEntryAndExit(ticker: "EWT", entryDate: "2017-12-06", exitDate: "2017-12-08", entry: 35.98, stop: 35.1, target: 37.35, shares: 46, exitPrice: 36.6)
        // pastEntryAndExit(ticker: "EWT", entryDate: "2017-12-08", exitDate: "2017-12-08", entry: 36.26, stop: 35.1, target: 37.35, shares: 45, exitPrice: 36.6)
        
        // trades.append( MyPrice().profit(ticker: "SOXX", date: "2017-12-06", entry: 167.38, exit: 167.87, shares: 5.00) )
        // pastEntryAndExit(ticker: "SOXX", entryDate: "2017-12-06", exitDate: "2017-12-08", entry: 167.38, stop: 158.62, target: 175.3, shares: 5, exitPrice: 167.87)
        
        // trades.append( MyPrice().profit(ticker: "EEM", date: "2017-12-07", entry: 45.92, exit: 46.45, shares: 22.00) )
        // pastEntryAndExit(ticker: "EEM", entryDate: "2017-12-07", exitDate: "2017-12-13", entry: 45.92, stop: 43.12, target: 47.66, shares: 22, exitPrice: 46.45)
        
        // trades.append( MyPrice().profit(ticker: "EWA", date: "2017-12-07", entry: 22.6, exit: 23.17, shares: 73.00) )
        // pastEntryAndExit(ticker: "EWA", entryDate: "2017-12-07", exitDate: "2017-12-13", entry: 22.6, stop: 21.91, target: 23.27, shares: 73, exitPrice: 23.17)
        
        // trades.append( MyPrice().profit(ticker: "EWY", date: "2017-12-08", entry: 74.38, exit: 75.54, shares: 22.00) )
        // pastEntryAndExit(ticker: "EWY", entryDate: "2017-12-08", exitDate: "2017-12-13", entry: 74.38, stop: 71.99, target: 76.45, shares: 22, exitPrice: 75.54)
        
        // trades.append( MyPrice().profit(ticker: "EWY", date: "2017-12-08", entry: 74.38, exit: 75.55, shares: 22.00) )
        // pastEntryAndExit(ticker: "EWY", entryDate: "2017-12-07", exitDate: "2017-12-13", entry: 74.38, stop: 71.99, target: 76.45, shares: 22, exitPrice: 75.55)
        
        // trades.append( MyPrice().profit(ticker: "EWI", date: "2017-12-14", entry: 30.84, exit: 30.70, shares: 53.00) )
        // pastEntryAndExit(ticker: "EWI", entryDate: "2017-12-14", exitDate: "2017-12-20", entry: 30.84, stop: 29.84, target: 31.84, shares: 53, exitPrice: 30.70)
        
        // trades.append( MyPrice().profit(ticker: "EWI", date: "2017-12-15", entry: 30.38, exit: 30.70, shares: 54.00) )
        // pastEntryAndExit(ticker: "EWI", entryDate: "2017-12-15", exitDate: "2017-12-20", entry: 30.38, stop: 29.84, target: 31.84, shares: 53, exitPrice: 30.70)
        
        // trades.append( MyPrice().profit(ticker: "RSX", date: "2017-12-19", entry: 20.82, exit: 21.71, shares: 80.00) )
        // pastEntryAndExit(ticker: "RSX", entryDate: "2017-12-19", exitDate: "2017-12-24", entry: 20.82, stop: 20.18, target: 21.43, shares: 80, exitPrice: 21.71)
        
        // trades.append( MyPrice().profit(ticker: "EWY", date: "12017-12-19", entry: 73.00, exit: 74.84, shares: 22.00) )
        // pastEntryAndExit(ticker: "EWY", entryDate: "2017-12-19", exitDate: "2017-12-24", entry: 72.96, stop: 70.67, target: 75.03, shares: 22, exitPrice: 74.84)
        
        // trades.append( MyPrice().profit(ticker: "TLT", date: "2017-12-19", entry: 125.64, exit: 126.94, shares: 7.00) )
        // pastEntryAndExit(ticker: "TLT", entryDate: "2017-12-19", exitDate: "2017-12-24", entry: 125.64, stop: 118.98, target: 131.49, shares: 7, exitPrice: 126.94)
        
        // trades.append( MyPrice().profit(ticker: "EFA", date: "2017-12-20", entry: 69.74, exit: 70.73, shares: 14.00) )
        // pastEntryAndExit(ticker: "EFA", entryDate: "2017-12-20", exitDate: "2017-12-24", entry: 69.74, stop: 66.23, target: 73.2, shares: 14, exitPrice: 70.73)
        
        // trades.append( MyPrice().profit(ticker: "MCD", date: "12017-12-20", entry: 172.21, exit: 173.33, shares: 9.00) )
        // pastEntryAndExit(ticker: "MCD", entryDate: "2017-12-20", exitDate: "2017-12-24", entry: 172.21, stop: 166.83, target: 177.15, shares: 9, exitPrice: 173.33)
        
        // trades.append( MyPrice().profit(ticker: "MMM", date: "12017-12-20", entry: 237.05, exit: 235.11, shares: 7.00) )
        // pastEntryAndExit(ticker: "MMM", entryDate: "2017-12-20", exitDate: "2017-12-24", entry: 237.05, stop: 230.11, target: 244.33, shares: 7, exitPrice: 235.11)
        
        // trades.append( MyPrice().profit(ticker: "VEA", date: "2017-12-22", entry: 44.58, exit: 45.19, shares: 37.00) )
        // pastEntryAndExit(ticker: "VEA", entryDate: "2017-12-22", exitDate: "2017-12-28", entry: 44.58, stop: 43.15, target: 45.81, shares: 37, exitPrice: 45.19)
        
        // trades.append( MyPrice().profit(ticker: "UNH", date: "2017-12-22", entry: 220.07, exit: 225.65, shares: 7.00) )
        // pastEntryAndExit(ticker: "UNH", entryDate: "2017-12-22", exitDate: "2017-12-28", entry: 220.07, stop: 212.52, target: 225.65, shares: 7, exitPrice: 225.65)
        
        // trades.append( MyPrice().profit(ticker: "AAPL", date: "2017-12-27", entry: 170.27, exit: 174.9, shares: 5.00) )
        // pastEntryAndExit(ticker: "AAPL", entryDate: "2017-12-27", exitDate: "2017-01-08", entry: 170.27, stop: 165.0, target: 180.0, shares: 5, exitPrice: 174.9)
        
        // trades.append( MyPrice().profit(ticker: "IFY", date: "2017-01-3", entry: 119.41, exit: 120.69, shares: 13.00) )
        // pastEntryAndExit(ticker: "IYF", entryDate: "2017-01-03", exitDate: "2017-01-08", entry: 119.41, stop: 115.66, target: 122.82, shares: 13, exitPrice: 120.69)
        
        // trades.append( MyPrice().profit(ticker: "FXO", date: "2017-01-3", entry: 31.28, exit: 31.68, shares: 53.00) )
        // pastEntryAndExit(ticker: "FXO", entryDate: "2017-01-03", exitDate: "2017-01-08", entry: 31.28, stop: 30.32, target: 32.2, shares: 53, exitPrice: 31.68)
        
        // trades.append( MyPrice().profit(ticker: "PG", date: "2017-01-3", entry: 90.80, exit: 90.87, shares: 18.00) )
        // pastEntryAndExit(ticker: "PG", entryDate: "2017-01-03", exitDate: "2017-01-08", entry: 90.80, stop: 87.6, target: 92.5, shares: 18, exitPrice: 90.87)
        
        
        //removeEntry(yyyyMMdd: "2018-01-17", ticker: "EFA", debug: true)
        //showOneTrade(yyyyMMdd: "2017-12-06", ticker: "EFA", debug: true)
        
        // 1 past entry for testing
        oneEntryForTesting()
    }
    
    func oneEntryForTesting() {
//        let entry = 89.86
//        let ticker = "PG"
//        let stopTarget = TradeHelpers().calcStopTarget(ticker: ticker, close: entry, debug: false)
//        let shares = TradeHelpers().calcShares(stopDist: stopTarget.stopDistance, risk: 100)
//        let cost = TradeHelpers().capitalRequired(close: entry, shares: shares)
//        makePastEntry(yyyyMMdd: "2018/01/23", ticker: ticker, entry: entry, stop: stopTarget.stop, target: stopTarget.target, shares: shares, risk: 100, account: "IB", cost: cost)
        
        let entry = 163.52
        let ticker = "IBM"
        let stopTarget = TradeHelpers().calcStopTarget(ticker: ticker, close: entry, debug: false)
        let shares = TradeHelpers().calcShares(stopDist: stopTarget.stopDistance, risk: 100)
        let cost = TradeHelpers().capitalRequired(close: entry, shares: shares)
        makePastEntry(yyyyMMdd: "2018/01/22", ticker: ticker, entry: entry, stop: stopTarget.stop, target: stopTarget.target, shares: shares, risk: 100, account: "IB", cost: cost)
    }
    
    func pastEntryAndExit(ticker: String, entryDate: String, exitDate: String,  entry: Double, stop: Double, target: Double, shares: Int, exitPrice: Double) {
        let risk = 50.00; let account = "IB"
        let cost = TradeHelpers().capitalRequired(close: entry, shares: shares)
        makePastEntry(yyyyMMdd: entryDate, ticker: ticker, entry: entry, stop: stop, target: target, shares: shares, risk: risk, account: account, cost: cost)
        makePastExit(yyyyMMdd: entryDate, exityyyyMMdd: exitDate, ticker: ticker, exitPrice: exitPrice, debug: true)
    }
    
    //this func is not adding entry risk intrade
    func makePastEntry(yyyyMMdd: String, ticker: String, entry:Double, stop:Double, target:Double, shares:Int, risk:Double, account:String, cost:Double) {

        // get ticker - date
        let tickerDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: false)
        let oneDay = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        // save realm
        let realm = try! Realm()
        try! realm.write {
            oneDay.entry     = entry
            oneDay.stop      = stop
            oneDay.target    = target
            oneDay.shares    = shares
            oneDay.risk      = risk
            oneDay.inTrade   = true
            oneDay.account   = account
            oneDay.capitalReq = cost
        }
        
        print("\nProve it:")
        let tickerModified = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        debugPrint(tickerModified)
        print("")
    }
    
    func makePastExit(yyyyMMdd: String,exityyyyMMdd:String,  ticker: String, exitPrice:Double, debug:Bool) {
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
            entryToExit.exitDate = Utilities().convertToDateFrom(string: exityyyyMMdd, debug: true)
        }

        let closedCheck = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }
    
    func removeEntry(yyyyMMdd: String, ticker: String, debug:Bool) {
        let tickerDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: debug)
        let oneDay = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        // save realm
        let realm = try! Realm()
        try! realm.write {
            oneDay.inTrade   = false
        }

        let closedCheck = RealmHelpers().getTaskIDfor(yyyyMMdd: yyyyMMdd, ticker: ticker)
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }
    
    func removeExitFrom(yyyyMMdd: String,exityyyyMMdd:String, ticker: String, exitPrice:Double, debug:Bool) {
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
            entryToExit.inTrade = true
            entryToExit.exitedTrade = false
            entryToExit.profit = 0.0
            entryToExit.exitPrice = 0.0
            //entryToExit.exitDate = Utilities().convertToDateFrom(string: exityyyyMMdd, debug: true)
        }
        
        let closedCheck = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }
    
    func showOneTrade(yyyyMMdd: String, ticker: String, debug:Bool) {
        let tickerDate = Utilities().convertToDateFrom(string: yyyyMMdd, debug: debug)
        let oneDay = RealmHelpers().getOneDay(ticker: ticker, date: tickerDate)
        if debug { print("\nshow One Trade")
            debugPrint(oneDay) }
    }
}



























