//
//  4.0 Portfolio FIlters.swift
//  Channel System
//
//  Created by Warren Hansen on 1/12/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PortfolioFilters {
    
    struct StatsData {
        var date: Date
        var dailyCumProfit:Double
        var dailyCost:Double
        var winPct:Double
    }
    
    struct StatsSummary {
        var totalProfit:Double
        var annualProfit:Double
        var totalRoi:Double
        var annualRoi:Double
        var winPct:Double
        var maxCost:Double
        var largestWin:Double
        var largestLoss:Double
        var numDays:Int
        var numYears:Double
        
        var longestDDperiod:Int
        var longestDDdate:Date
        var largestDD:Double
        var largestDDdate:Date
        var ddAsPctOfProfit:Double
    }
    
    //var statsArray:[StatsData] = []
    var portfolio:[StatsData] = []
    var cumulatveSum:Double = 0.0
    var cumulativeCost:Double = 0.0
    var positionCount:Int = 0
    var lastDate:Date = Date()
    var winCount:Int = 0
    var tradeCount:Int = 0
    var winPct:Double = 0.0
    var largestWin:Double = 0.0
    var largestLoss = 0.0
    
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
    
    
    var lastprofitPeak:Double = 0.0
    var profitPeakDates:[(Date,Double)] = []
    var drawDown:Double = 0.0
    var maxDrawDown:Double = 0.0
    var maxDrawDownDate:Date = Date()

    
    func createStats() {
        sumProfit = totalProfit.reduce(0, +)
        sumCost = totalCost.max()!
        let fistDayofProfit = Utilities().convertToDateFrom(string: "2016/02/01", debug: false)
        let numDays = Utilities().calcuateDaysBetweenTwoDates(start: fistDayofProfit, end: Date(), debug: false)
        let numYears = Double(numDays) / 365.00
        let annualProfit = sumProfit / numYears
        let totalRoi = (sumProfit / sumCost) * 100.0
        let annualRoi = totalRoi / numYears
        let largestDD = self.findMaxDrawDown(debug: false)
        let longDD = self.findLongestDrawdown(debug: false)
        
        let allStats = StatsSummary(totalProfit: sumProfit, annualProfit: annualProfit, totalRoi: totalRoi, annualRoi: annualRoi, winPct: winPct, maxCost: sumCost, largestWin: largestWin, largestLoss: largestLoss, numDays: numDays, numYears: numYears, longestDDperiod: longDD.maxDays, longestDDdate: longDD.endDate, largestDD: largestDD.maxDD, largestDDdate: largestDD.date, ddAsPctOfProfit: largestDD.pctProfit)
        
        print("\nall stats\ntotal profit \(allStats.totalProfit)\nannual profit \(allStats.annualProfit)\ntotalRoi \(allStats.totalRoi)\nannual roi \(allStats.annualRoi)\nwin pct \(allStats.winPct)\nmax cost \(allStats.maxCost)\nlargest winner \(allStats.largestWin)\nlargest loss \(allStats.largestLoss)\nnum days \(numDays)\nnum years \(numYears)\nlonget DD \(longDD.maxDays) days on \(Utilities().convertToStringNoTimeFrom(date: longDD.endDate))\nlargest DD \(Utilities().dollarStr(largeNumber: largestDD.maxDD)) on \(Utilities().convertToStringNoTimeFrom(date: largestDD.date))\nDD as % of profit \(String(format: "%.1f", largestDD.pctProfit))%")
        // save to realm
        Stats().updateFinalTotal(data: allStats)
    }
    
    func using(mc:Bool, stars:Bool, numPositions:Int, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
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
            }

            if done {
                Performance().updateFinalTotal(data: self.portfolio)
                self.createStats()
                
                
                completion(true)
            }
        }
    }
    
    func findMaxDrawDown(debug:Bool)-> (maxDD:Double,date:Date, pctProfit:Double) {
        for each in portfolio {
            if each.dailyCumProfit > lastprofitPeak {
                lastprofitPeak = each.dailyCumProfit
                profitPeakDates.append((each.date, lastprofitPeak))
            }
            
            drawDown = lastprofitPeak - each.dailyCumProfit
            if drawDown > maxDrawDown {
                maxDrawDown = drawDown
                maxDrawDownDate = each.date
            }
        }
        let ddAsPctOfProfit = (portfolio.last?.dailyCumProfit)! / maxDrawDown
        if debug {
            print("/nHere is the peak profit date array")
            for each in self.profitPeakDates {
                print(Utilities().convertToStringNoTimeFrom(date: each.0), each.1)
            }
        
            print("\nLargest DD was \(Utilities().dollarStr(largeNumber: maxDrawDown)) on \(Utilities().convertToStringNoTimeFrom(date: maxDrawDownDate))")
            print("Drawdown as % of Profit is \(String(format: "%.2f", ddAsPctOfProfit))")
        }
        
        return (maxDrawDown, maxDrawDownDate, ddAsPctOfProfit)
    }
    
    func findLongestDrawdown(debug:Bool)-> (maxDays:Int,endDate:Date) {
        var longestDD:Int = 0
        var dateOfDD:Date = Date()
        for (index, thisDate) in profitPeakDates.enumerated() {
            
            // ignore dates befor 11/12/2015
            let startDate = Utilities().convertToDateFrom(string: "2016/03/12", debug: false)
            if index >= 2 && thisDate.0 > startDate{
                let date1 = profitPeakDates[index - 1].0
                let date2 = profitPeakDates[index].0
                let days = Utilities().calcuateDaysBetweenTwoDates(start: date1, end: date2, debug: false)
                if days > longestDD {
                    longestDD = days
                    dateOfDD = thisDate.0
                }
            }
        }
        if debug {print("\nLongest period before new equity high was \(longestDD) days and ended on \(Utilities().convertToStringNoTimeFrom(date: dateOfDD))\n") }
        return (longestDD, dateOfDD)
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
            if ( profitHere - commissions ) > largestWin { largestWin = profitHere }
            if ( profitHere - commissions ) < largestLoss { largestLoss = profitHere}
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




















