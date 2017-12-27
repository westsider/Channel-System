//
//  Past Trades.swift
//  Channel System
//
//  Created by Warren Hansen on 12/13/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

class MyPrice {
    
    func profit(ticker: String, date: String, entry:Double, exit:Double, shares: Double)-> (String, Double, Double) {
        var profit:Double = 0.00
        if exit != 0.00 {
            profit = (exit - entry) * shares - 1.05 // comm
        }
        let cost = shares * entry
        let profitString = String(format: "%.2f", profit)
        let answer = "\(ticker)\t\(date)\t\(profitString)"
        return (answer, profit, cost)
    }
}

class ManualTrades {
    
    func showProfit() {
        var trades = [(String, Double, Double)]()
        var cumProfit = [Double]()
        var cumCost = [Double]()
        var winCount:Int = 0
        trades.append( MyPrice().profit(ticker: "DBB", date: "11/28", entry: 18.21, exit: 17.8, shares: 90.00) )
        trades.append( MyPrice().profit(ticker: "KO", date: "11/28", entry: 45.57, exit: 46.19, shares: 36.00) )
        trades.append( MyPrice().profit(ticker: "DJP", date: "12/01", entry: 23.91, exit: 23.05, shares: 100.00) )
        trades.append( MyPrice().profit(ticker: "EWH", date: "12/01", entry: 25.57, exit: 25.35, shares: 65.00) )
        trades.append( MyPrice().profit(ticker: "V", date: "12/05", entry: 108.64, exit: 111.99, shares: 15.00) )
        trades.append( MyPrice().profit(ticker: "SMH", date: "12/05", entry: 97.4, exit: 97.8, shares: 17.00) )
        trades.append( MyPrice().profit(ticker: "EWT", date: "12/06", entry: 35.98, exit: 36.6, shares: 46.00) )
        trades.append( MyPrice().profit(ticker: "EFA", date: "12/06", entry: 69.28, exit: 70.28, shares: 14.00) )
        trades.append( MyPrice().profit(ticker: "SOXX", date: "12/06", entry: 167.38, exit: 167.87, shares: 5.00) )
        trades.append( MyPrice().profit(ticker: "EEM", date: "12/07", entry: 45.92, exit: 46.45, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWA", date: "12/07", entry: 22.6, exit: 23.17, shares: 73.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "12/07", entry: 74.25, exit: 0.00, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "12/08", entry: 74.38, exit: 75.54, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWT", date: "12/08", entry: 36.28, exit: 36.6, shares: 45.00) )
        trades.append( MyPrice().profit(ticker: "EWY", date: "12/08", entry: 74.38, exit: 75.55, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "EWI", date: "12/14", entry: 30.84, exit: 30.70, shares: 53.00) )
        trades.append( MyPrice().profit(ticker: "EWI", date: "12/15", entry: 30.38, exit: 30.70, shares: 54.00) )
        
        trades.append( MyPrice().profit(ticker: "EWY", date: "12/19", entry: 73.00, exit: 0.00, shares: 22.00) )
        trades.append( MyPrice().profit(ticker: "RSX", date: "12/19", entry: 20.82, exit: 0.00, shares: 80.00) )
    trades.append( MyPrice().profit(ticker: "TLT", date: "12/19", entry: 125.64, exit: 0.00, shares: 7.00) )
        trades.append( MyPrice().profit(ticker: "EFA", date: "12/20", entry: 69.74, exit: 0.00, shares: 14.00) )
        trades.append( MyPrice().profit(ticker: "MCD", date: "12/20", entry: 172.21, exit: 0.00, shares: 9.00) )
        trades.append( MyPrice().profit(ticker: "MMM", date: "12/20", entry: 237.05, exit: 0.00, shares: 7.00) )
        trades.append( MyPrice().profit(ticker: "UNH", date: "12/22", entry: 220.07, exit: 0.00, shares: 7.00) )
        trades.append( MyPrice().profit(ticker: "VEA", date: "12/22", entry: 44.58, exit: 0.00, shares: 37.00) )
        trades.append( MyPrice().profit(ticker: "AAPL", date: "12/27", entry: 170.27, exit: 0.00, shares: 5.00) )
        
        
        
        for each in trades {
            print(each.0)
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
        print("Total\t$\(profitSumStr)\t\(winPctStr)% win\n\n$\(avgCost) avg cost\t\t$\(meanCost) mean cost\n\(approxRoiStr)% roi\t\t\t\(annumRoiStr)% annual return\n$\(annumReturnStr) annual gain\n\n")
        
        //makePastEntry()
    }
    
    func makePastEntry(){
        let myTaskID = RealmHelpers().getTaskIDfor(yyyyMMdd: "2017-12-19", ticker: "TLT")
        print(myTaskID)
        let tickerInQuestion = Prices().getOneDateFrom(taskID: myTaskID)
        print("\nThis is TLT on 12/19")
        print(tickerInQuestion)
        print("")
        RealmHelpers().makeEntry(taskID: myTaskID, entry: 125.64, stop: 118.97, target: 131.49, shares: 7, risk: 50.00, debug: false, account: "IB", capital: 876.61)
        
        print("\nProve it:")
        let tickerModified = Prices().getOneDateFrom(taskID: myTaskID)
        debugPrint(tickerModified)
        print("")
    }
}



