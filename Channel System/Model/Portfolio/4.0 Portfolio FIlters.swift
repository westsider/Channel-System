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
    [X] chart
    [X] cumulative cost
    [ ] calc stats
    [X] limit num pos
    [ ] apply mc
    [ ] apply stars
    [ ] find big dip
    [ ] remove commisions
        33,601  63.82% Win
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
    
    let commissions:Double = 1.05 * 2.0
    
    func of(mc:Bool, stars:Bool, numPositions:Int)-> [StatsData] {

        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "entryDate", ascending: true)
 
        if sortedByDate.count >  1 {
            let results = sortedByDate
            for each in results {
                
                // Sum for this date OR start ned day and append the array for sciChart
                if each.entryDate == lastDate {
                    //print("\tSame date sum profit and cost")
                    sumProfitAndCost(profit: each.profit, Cost: each.cost, numPos: numPositions, ticker: each.ticker, date: each.entryDate!)
                } else {
                    //print("\tNew date return Sums, zero Sums, sum profit and cost")
                    returnSumAndProfit()
                    printEachDay(date:  each.entryDate!)
                    zeroProfitCostCount()
                    sumProfitAndCost(profit: each.profit, Cost: each.cost, numPos: numPositions, ticker: each.ticker, date: each.entryDate!)
                }
                lastDate = each.entryDate!
            }
        }
        return portfolio
    }
    
    func sumProfitAndCost(profit:Double,Cost:Double, numPos:Int, ticker:String, date:Date) {
        let starsOK = checkStars(ticker: ticker)
        let matrix = EntryUtil().checkMatrix(date: date)
        if positionCount < numPos && starsOK && matrix {
            positionCount += 1
            tradeCount += 1
            sumProfit += profit - commissions
            sumCost += Cost
            if profit >= 0 {
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
}




















