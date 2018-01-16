//
//  4.0 Portfolio FIlters.swift
//  Channel System
//
//  Created by Warren Hansen on 1/12/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

/*
 

 33,601  63.82% Win
 [ ] roi, ll, lw,
 [ ] cost, annual gain
 [ ] activity for stats
 [ ] clean up stats functions
 */

class PortfolioFilters {
    
    struct StatsData {
        var date: Date
        var dailyCumProfit:Double
        var dailyCost:Double
        var winPct:Double
    }
    
    var statsArray:[StatsData] = []
    var portfolio:[StatsData] = []
    var cumulatveSum:Double = 0.0
    var cumulativeCost:Double = 0.0
    var positionCount:Int = 0
    var lastDate:Date = Date()
    var winCount:Int = 0
    var tradeCount:Int = 0
    var winPct:Double = 0.0
    var strWinPct:String = ""
    var sumProfit:Double = 0.0
    var sumCost:Double = 0.0
    var totalProfit:[Double] = []
    var totalCost:[Double] = []
    var profitArray:[Double] = []
    var outlierArray:[String] = []
    var mainLoopCounter:Int = 0
    var mainLoopSize:Int = 0
    let commissions:Double = 1.05 * 2.0
    
    func using(mc:Bool, stars:Bool, numPositions:Int, completion: @escaping (Bool) -> Void) {
        //DispatchQueue.global(qos: .background).async {
            var done:Bool = false
            let realm = try! Realm()
            let weeklyStats = realm.objects(WklyStats.self)
            let sortedByDate = weeklyStats.sorted(byKeyPath: "entryDate", ascending: true)
            self.mainLoopSize = sortedByDate.count
            if sortedByDate.count >  1 {
                let results = sortedByDate
                for each in results {
                    self.mainLoopCounter += 1
                    // Sum for this date OR start ned day and append the array for sciChart
                    if each.entryDate == self.lastDate {
                        // Same date sum profit and cost
                        self.printEachTrade(isOn: false, ticker: each.ticker, date: each.entryDate!, profit: each.profit, cost: each.cost)
                        self.sumProfitAndCost(profit: each.profit, Cost: each.cost, numPos: numPositions, ticker: each.ticker, date: each.entryDate!, mc: mc)
                    } else {
                        // New date return Sums, zero Sums, sum profit and cost
                        self.returnSumAndProfit()
                        self.printEachDay(date:  each.entryDate!)
                        self.zeroProfitCostCount()
                        self.sumProfitAndCost(profit: each.profit, Cost: each.cost, numPos: numPositions, ticker: each.ticker, date: each.entryDate!, mc: mc)
                    }
                    self.lastDate = each.entryDate!
                }
                print("ml \(self.mainLoopCounter) = \(self.mainLoopSize)")
                if self.mainLoopCounter == self.mainLoopSize {
                    print("\nHere are the outliers")
                    for each in self.outlierArray {
                        print("\(each)")
                    }
                    done = true
                }
            //}
            
        }
        if done {
            Performance().updateFinalTotal(data: portfolio)
            completion(true)
        }
        
    }
    
    func createStats() {
        // total profit
        // win pct
        // roi
        // cost
        // largest win, loss
        // annual return
        // annual roi
        // remove buttons
        // save to realm
    }
    
    func sumProfitAndCost(profit:Double,Cost:Double, numPos:Int, ticker:String, date:Date, mc:Bool) {
        var profitHere = profit
        var matrix:Bool = true
        let starsOK = checkStars(ticker: ticker)
        if mc { matrix = EntryUtil().checkMatrix(date: date) }
        if positionCount < numPos && starsOK && matrix {
            positionCount += 1
            tradeCount += 1
            profitHere = checkOutliers(date: date, ticker: ticker, profit: profit)
            sumProfit += profitHere - commissions
            sumCost += Cost
            if profitHere >= 0 {
                winCount += 1
            }
        }
    }
    
    func checkStars(ticker:String)->Bool {
        let stars = Prices().getStarsFor(ticker: ticker, debug: false)
        let minStars:Int = Stats().getStars()
        if stars >= minStars {
            return true
        } else {
            return false
        }
    }
    
    func returnSumAndProfit() {
        totalProfit.append(sumProfit)
        totalCost.append(sumCost)
    }
    
    func zeroProfitCostCount() {
        sumProfit = 0.0 ; sumCost = 0.0; positionCount  = 0
    }
    
    func printEachDay(date:Date) {
        let sumOfAllProfit = totalProfit.reduce(0, +)
        let strDate = Utilities().convertToStringNoTimeFrom(date: date)
        let cp = Utilities().dollarStr(largeNumber: sumOfAllProfit)
        let strSumCost = Utilities().dollarStr(largeNumber: sumCost)
        winPct = Double( winCount ) / Double( tradeCount ) * 100.0
        strWinPct = String(format: "%.2f",winPct)
        print("\(strDate)\tCumulative Profit \(cp)\t\t\tpositions \(positionCount)\tCost \(strSumCost)\t\t\(String(strWinPct))% Win")
        let thisDay = StatsData(date: date, dailyCumProfit: sumOfAllProfit, dailyCost: sumCost, winPct: winPct)
        portfolio.append(thisDay)
    }
    
    func printEachTrade(isOn:Bool, ticker:String, date:Date, profit:Double, cost:Double) {
        if !isOn { return }
        let strDate = Utilities().convertToStringNoTimeFrom(date: date)
        let strProfit = Utilities().dollarStr(largeNumber: profit)
        let strCost = Utilities().dollarStr(largeNumber: cost)
        let dot = Utilities().happySad(num: profit)
        print("\(dot)\t\(ticker)\t\(strDate)\tProfit \(strProfit)\t\tcost \(strCost)")
    }
    
    func checkOutliers(date:Date, ticker:String, profit:Double)-> Double {
        var answer = profit
        profitArray.append(profit)
        let average = profitArray.reduce(0, + ) / Double( profitArray.count )
        let outlier = average * 10
        let superOutlier = outlier * 4
        let strProfit = Utilities().dollarStr(largeNumber: profit)
        let strAvg = Utilities().dollarStr(largeNumber: average)
        let strDate = Utilities().convertToStringNoTimeFrom(date: date)
        let strOutlier = Utilities().dollarStr(largeNumber: outlier)
        
        if profit > outlier && tradeCount > 750 {
            print("\n\n--------> WARNING Outlier Alert <--------\n\(strDate)\t\(ticker)\t\(strProfit)\tavg is \(strAvg)\tlimit is \(strOutlier)\n-----------------------------------------------------\n\n")
            outlierArray.append("\(strDate)\t\(ticker)\t\(strProfit)")
            if profit > superOutlier {
                print("***** This was a super anomily. reduce profit of \(strProfit) to \(strOutlier) *****\n")
                answer = outlier
            }
        }
        return answer
    }
}




















