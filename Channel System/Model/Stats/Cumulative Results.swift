//
//  Cumulative Results.swift
//  Channel System
//
//  Created by Warren Hansen on 12/4/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class CumulativeProfit {
    
    
    func dailyProcess(debug:Bool)-> [(date: Date, profit: Double, cost: Double, positions: Int)]  {

        var dailyPortfolioRecord: [(date: Date, profit: Double, cost: Double, positions: Int)] = []
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var lastDate = Date()
        var todaysProfit:Double = 0.00
        var portfolioDict: [String: Double] = [:]
        var maxCost:Double = 0.00
        var totalGain:Double = 0.00
        for (fileIndex, today) in dateArray.enumerated() {
            if fileIndex < 25306 { continue }
            // daily process
            // if buy then buy and record ticker and cost
            if portfolioDict.count < 20 {
                if today.capitalReq != 0.00 {
                    // only buy if I dont own it
                    if portfolioDict[today.ticker] == nil {
                    portfolioDict[today.ticker] = today.capitalReq
                    print("\(fileIndex) Found a buy on \(today.dateString), adding to portfolio \(today.ticker) cost \(DateHelper().dollarStr(largeNumber: today.capitalReq)) positions: \(portfolioDict.count)")
                    }
                }
            }
            // if sell then reord profitToday and remove ticker
            if today.backTestProfit != 0.00 {
                // if this sell matches one of my tickers
                if portfolioDict[today.ticker] != nil {
                    todaysProfit += today.backTestProfit
                    portfolioDict.removeValue(forKey: today.ticker)
                    print("\(fileIndex) Found a sell on \(today.dateString), removing from  portfolio \(today.ticker) adding profit \(DateHelper().dollarStr(largeNumber:today.backTestProfit)) positions now: \(portfolioDict.count)")
                }
            }
            //on a new day
            if today.date != lastDate {
                // sum all of todays cost
                var dailyCostSum:Double = 0.00
                for each in portfolioDict {
                    dailyCostSum += each.value
                }
                // record date profit, cost, numPositions
                dailyPortfolioRecord.append((date: lastDate , profit: todaysProfit, cost: dailyCostSum, positions: portfolioDict.count))
                // check max cost and gain
                if dailyCostSum > maxCost {
                    maxCost = dailyCostSum
                }
                totalGain += todaysProfit
                // print the record
                print("\(fileIndex) New day, summing daily cost and adding a portfolio daily record")
                print("\(fileIndex) Todays Record: ", lastDate, "Profit: ", DateHelper().dollarStr(largeNumber:todaysProfit), "Cost: ",DateHelper().dollarStr(largeNumber:dailyCostSum), "Positions: ", portfolioDict.count)
                // clear todays profit
                todaysProfit = 0
                // incrementDate
                lastDate = today.date!
                print("\(fileIndex) clearing todays profit, new date is \(lastDate)")
                // repeat daily process
                // daily process
                // if buy then buy and record ticker and cost
                if portfolioDict.count < 20 {
                    if today.capitalReq != 0.00 {
                        // only buy if I dont own it
                        if portfolioDict[today.ticker] == nil {
                            portfolioDict[today.ticker] = today.capitalReq
                            print("\(fileIndex) Found a buy on \(today.dateString), adding to portfolio \(today.ticker) cost \(DateHelper().dollarStr(largeNumber: today.capitalReq)) positions: \(portfolioDict.count)")
                        }
                    }
                }
                // if sell then reord profitToday and remove ticker
                if today.backTestProfit != 0.00 {
                    // if this sell matches one of my tickers
                    if portfolioDict[today.ticker] != nil {
                        todaysProfit += today.backTestProfit
                        portfolioDict.removeValue(forKey: today.ticker)
                        print("\(fileIndex) Found a sell on \(today.dateString), removing from  portfolio \(today.ticker) adding profit \(DateHelper().dollarStr(largeNumber:today.backTestProfit)) positions now: \(portfolioDict.count)")
                    }
                }
            }
        }
        let roi = totalGain / maxCost
        let roiString = String(format: "%.2f", roi)
        print("Max cost: \(DateHelper().dollarStr(largeNumber: maxCost) ) Total gain: \(DateHelper().dollarStr(largeNumber: totalGain)) ROI: \(roiString)")
        let totalPortfolio = 850000.00
        let endGame = totalPortfolio * roi
        let annual = endGame / 2
        print("Big Portfolio \(DateHelper().dollarStr(largeNumber: endGame)) annual: \(DateHelper().dollarStr(largeNumber: annual))")
        return dailyPortfolioRecord
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var maxCost:Double = 0.00

    // get every date in Prices. if backTestProfit -> master: [(date: Date, profit: Double)]
    func calcAllTickers(debug:Bool)-> [(date: Date, profit: Double, cost: Double, positions: Int)]  {
        
        print("inside makeMaster()")
        var allDatesAllTickers: [(date: Date, profit: Double, cost: Double, positions: Int)] = []
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var counter = 0
        var lastDate = Date()
        var todaysProfit = [Double]()
        var todaysCost = [Double]()
        var sumOfToday:Double = 0.00
        var sumOfCost:Double = 0.00
        var positionsToday:Int = 0
        print("we have a dateArray of \(dateArray.count)")
  
        for today in dateArray {
            
            if debug { print(today.backTestProfit) }
           
            if today.date == lastDate  {
                 if positionsToday < 21 {
                    
                    if today.capitalReq != 0.00 {
                        todaysCost.append(today.capitalReq)
                        sumOfCost = todaysCost.reduce(0, +)
                        if today.capitalReq > 2000.00 {
                            let capStr = DateHelper().dollarStr(largeNumber: today.capitalReq)
                            print("Cap Req: \(capStr)")
                        }
                    }
                    
                    if today.backTestProfit != 0.00 {
                        positionsToday += 1
                        todaysProfit.append(today.backTestProfit)
                        sumOfToday = todaysProfit.reduce(0, +)
                    }
                }

                
                if debug { print(today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday)) }
            } else {
                // new date so save last date and total for the day
                //if sumOfToday != nil {
                allDatesAllTickers.append((date: lastDate, profit: sumOfToday, cost: sumOfCost, positions: positionsToday))
                todaysProfit.removeAll()
                todaysCost.removeAll()
                positionsToday = 0
                // start adding new date
                todaysProfit.append(today.backTestProfit)
                sumOfToday = todaysProfit.reduce(0, +)
                todaysCost.append(today.capitalReq)
                sumOfCost = todaysCost.reduce(0, +)
                if debug { print("new date!\n", today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday)) }
                //}
            }
            counter += 1
            lastDate = today.date!
            //}
        }
        return allDatesAllTickers
    }
    
    // get master: [(date: Date, profit: Double)] ->  cumulative daily profit
    func dailyProfit(debug: Bool)-> [(date: Date, profit: Double, cost:Double, positions: Int)]  {
    
        let master = calcAllTickers(debug: debug)
        var cumProfit = master
        var runOfProfit:Double = 0.00
        //var runOfCost:Double = 0.00
        
        for (index, today) in master.enumerated() {
            runOfProfit += today.profit
            cumProfit[index].profit = runOfProfit
            cumProfit[index].cost = today.cost
            if today.cost > maxCost {
                maxCost = today.cost
            }
        }
        /*
            trying to get a look at how many positions are open at once
            if > 20 limit new positions, limit only 3***
        */
        
        if debug {
            for today in cumProfit {
                print(today.date, "profit ", DateHelper().dollarStr(largeNumber: today.profit),"\tcost ", DateHelper().dollarStr(largeNumber: today.cost),"\tmax ", DateHelper().dollarStr(largeNumber: maxCost), "\tPositions: ", today.positions)
            }
        }
        
        return cumProfit
    }
    
    // get cumulative daily profit save weekly cumulative profit to realm
    func weeklyProfit(debug: Bool, completion:  (_ result:Bool) ->Void) {
        let cumProfit = dailyProfit(debug: debug)
        var cumProfitWeelky: [(date: Date, profit: Double, cost:Double)] = []
        // delete old stas in realm
        let realm = try! Realm()
        let oldData = realm.objects(WklyStats.self)
        try! realm.write {
            realm.delete(oldData)
        }
        
        var counter = 0
        let maxCount = cumProfit.count
        
        for today in cumProfit.enumerated() {
            // if today is friday
            if isFriday(date: today.element.date) {
                //print("Hello Friday")
                cumProfitWeelky.append((date: today.element.date, profit: today.element.profit, cost: today.element.cost))
                WklyStats().updateCumulativeProfit(date: today.element.date, profit: today.element.profit, cost: today.element.cost, maxCost: maxCost)
            }
            
            counter += 1
            if counter == maxCount {
                completion(true)
            }
        }
        
        for today in cumProfitWeelky {
            
            if debug {print(today.date, String(format: "%.2f", today.profit)) }
        }
    }
    
    func isFriday(date:Date) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: date as Date)
        
        if components.weekday == 6 {
            return true
        } else {
            return false
        }
    }
}
