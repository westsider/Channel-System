//
//  4.0 Allow 20 Positions.swift
//  Channel System
//
//  Created by Warren Hansen on 1/6/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PortfolioEntries {
    
    var firstTradeDate = Date()
    var tradeCount:Int = 0
    var portfolioDict: [String: Double] = [:]
    var totalStars:Int = 0
    var todaysProfit = Double()
    var winCount:Int = 0
    var largestWinner:Double = 0.00
    var largestLooser:Double = 0.00
    var dailyCostSum:Double = 0.00
    var totalGain:Double = 0.00
    var lastDate = Date()
    var maxCost:Double = 0.00
    
    var testSumOfProfit = [Double]()
    
    //////////////////////////////////////////////////////////////////
    //                    Limit Portfolio Positions                 //
    //////////////////////////////////////////////////////////////////
    
    /**
     - Author: Warren Hansen
     - Step 1 of 3 weekly cumulative backtest process
     -      allTickerBacktestWithCost()
     -      dailyProfit()
     -      weeklyProfit()
     - loop all prices calc profit with no 2nd entry
     - filter with portfolioDict.count < 20, market condition and min stars
     - produce a master: [(date: Date, profit: Double)] of  cumulative daily profit
     ### Declare As:
     let master = allTickerBacktestWithCost(debug: debug, saveToRealm: true)
     */
    func allTickerBacktestWithCost(debug:Bool, saveToRealm:Bool)-> [(date: Date, profit: Double, cost: Double, positions: Int)]  {

        var allTradesPortfolioRecord: [(date: Date, profit: Double, cost: Double, positions: Int)] = []
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        let minStars:Int = Stats().getStars()
        
        for (fileIndex, today) in dateArray.enumerated() {
            
            if fileIndex < 24100 { continue }
            // daily process on the same day
            let bc = EntryUtil().buyConfirmation(ticker: today.ticker, portfolio: portfolioDict, tStars: today.stars, mStars: minStars, date:today.date!, capReq: today.capitalReq)
            
            buyIfConfirmed(buyConfirm:bc, todayDate:today.date!, dateStr:today.dateString, capRequired:today.capitalReq, ticker:today.ticker, stars:today.stars, debug:debug)
            
            sellIfInPortfolio(profit: today.backTestProfit, ticker: today.ticker, debug: debug, dateStr: today.dateString)
            
            // daily process on a new day
            if today.date != lastDate {
                sumDailyCost()
                // record date profit, cost, numPositions
                allTradesPortfolioRecord.append((date: lastDate , profit: todaysProfit, cost: dailyCostSum, positions: portfolioDict.count))
                calcDailyCost()
                totalGain += todaysProfit
                debugDailyProfit(profit: todaysProfit, debug: debug)
                todaysProfit = 0
                lastDate = today.date! // incrementDate
                buyIfConfirmed(buyConfirm:bc, todayDate:today.date!, dateStr:today.dateString, capRequired:today.capitalReq, ticker:today.ticker, stars:today.stars, debug:debug)
                
                sellIfInPortfolio(profit: today.backTestProfit, ticker: today.ticker, debug: debug, dateStr: today.dateString)
            }
        }
        
        updateDatabase(saveToRealm: saveToRealm, debug: debug)
        reduceTestSum()
        return allTradesPortfolioRecord
    }
    
    //////////////////////////////////////////////////////////////////
    //                 Limit Portfolio Position Helpers             //
    //////////////////////////////////////////////////////////////////
    func updateTradeCount(today:Date) {
        if tradeCount == 0 { firstTradeDate = today } // reset on first trade of day
        tradeCount += 1
    }
    
    func updatePortfolio(capRequired:Double, ticker:String) {
        portfolioDict[ticker] = capRequired
    }
    
    func updateStars(stars:Int) {
        totalStars += stars // to get us avg stars
    }
    
    func debugBuy(debug:Bool, dateStr:String, stars:Int, ticker:String, cap:Double) {
        if debug { print("Buy on \(dateStr) with \(stars) stars, adding to portfolio \(ticker) cost \(Utilities().dollarStr(largeNumber: cap)) positions: \(portfolioDict.count)") }
    }
    /** if buy and I dont own it then buy and record ticker and cost */
    func buyIfConfirmed(buyConfirm:Bool, todayDate:Date, dateStr:String, capRequired: Double, ticker: String, stars:Int, debug:Bool) {
        if buyConfirm {
            updateTradeCount(today: todayDate) // if tradeCount == 0 { firstTradeDate = today.date! }
            updatePortfolio(capRequired: capRequired, ticker: ticker) // portfolioDict[today.ticker] = today.capitalReq
            updateStars(stars: stars) //  totalStars += today.stars // to get us avg stars
            debugBuy(debug: debug, dateStr: dateStr, stars: stars, ticker: ticker, cap: capRequired)
        }
    }
    
    /** sell if its in portfolio, record win count, todays profit, lw ll  */
    func sellIfInPortfolio(profit:Double, ticker:String, debug:Bool, dateStr:String) {
        if profit != 0.00 && portfolioDict[ticker] != nil {
            todaysProfit += profit
            portfolioDict.removeValue(forKey: ticker)
            if profit >= 0 { winCount += 1 }
            if profit > largestWinner { largestWinner = profit }
            if profit < largestLooser { largestLooser = profit }
            debugSell(debug: debug , profit: profit, dateStr: dateStr, ticker: ticker)
            testSumOfProfit.append(profit)
        }
    }
    
    func debugSell(debug:Bool, profit:Double, dateStr:String, ticker:String) {
        if debug { print("\(Utilities().happySad(num: profit)) Sell on \(dateStr), removing from  portfolio \(ticker) adding profit \(Utilities().dollarStr(largeNumber: profit)) positions now: \(portfolioDict.count)")}
    }
    
    func debugDailyProfit(profit:Double, debug:Bool) {
        if debug && todaysProfit != 0 {
            print("\(Utilities().happySad(num: profit)) Todays Record: ", lastDate, "  Profit: ", Utilities().dollarStr(largeNumber:profit), "  Cost: ",Utilities().dollarStr(largeNumber:dailyCostSum), "  Positions: \(portfolioDict.count) ----> Cumulative Gain: \(Utilities().dollarStr(largeNumber: totalGain))\n" )
        }
    }
    
    func calcDailyCost() {
        if dailyCostSum > maxCost {
            maxCost = dailyCostSum
        }
    }
    
    func updateDatabase(saveToRealm:Bool, debug:Bool) {
        let roi = totalGain / maxCost
        let roiString = String(format: "%.2f", roi)
        let winPct = ( Double( winCount ) / Double(tradeCount) ) * 100
        let totalPortfolio = 850000.00
        let endGame = totalPortfolio * roi
        let annual = endGame / 2
        let avgStars:Double = Double(totalStars) / Double(tradeCount)
        
        if saveToRealm {
            Stats().updateFinalTotal(grossProfit: totalGain, avgPctWin: winPct, avgROI: roi, grossROI: roi, avgStars: avgStars, maxCost: maxCost, largestWin: largestWinner, largestLoss: largestLooser, firstDate: firstTradeDate) }
        
        if debug { print("\n--------------- Cumulative Backtest Results ---------------\nMax cost: \(Utilities().dollarStr(largeNumber: maxCost) ), Total gain: \(Utilities().dollarStr(largeNumber: totalGain)), Roi: \(roiString), \(Utilities().decimalStr(input: winPct, Decimals: 2))% Win\nFull Portfolio Return \(Utilities().dollarStr(largeNumber: endGame)), Annual Return: \(Utilities().dollarStr(largeNumber: annual))\n-----------------------------------------------------------\n") }
    }
    
    func sumDailyCost() {
        dailyCostSum = 0.00
        for each in portfolioDict {
            dailyCostSum += each.value
        }
    }
    
    func reduceTestSum() {
        let total = testSumOfProfit.reduce(0,+)
        var answerString = "\n--------------------------------------------------\n"
        answerString += "\tTest array to sum all sells \(Utilities().dollarStr(largeNumber: total))\n"
        answerString += "--------------------------------------------------\n"
        print(answerString)
    }

}
