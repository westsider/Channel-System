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
    func anyLoss() {
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        for today in dateArray {
            if today.backTestProfit < 0 {
                print("\n\n******************************Loss of \(today.backTestProfit)\n****************************\n")
            }
        }
    }
    
    func confirmExitOn(ticker:String) {

        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
            var buyCount = 0
            var sellCount = 0
            for today in prices {
                if today.longEntry {
                    buyCount += 1
                    print("Bought \(ticker) Buy \(buyCount) Sell \(sellCount) \(today.dateString)")
                }
                if today.backTestProfit != 0.00 {
                    sellCount += 1
                    print("Sold \(ticker) Buy \(buyCount) Sell \(sellCount) \(today.dateString)")
                }
            }
        print("Confirm Exit has completed")
    }
    
    // print the next 8 days
    // look for exit
    // if n exit alert
    func getDaysFor(ticker: String, start:Date, days:Int) {
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        var counter = 0
        var haveExit:Bool = false
        for today in prices {
            if today.date == start {
                counter = 0
                print(today.ticker, today.dateString, "entry ", today.longEntry)
                haveExit = false
            }
            counter += 1
            
            if today.backTestProfit != 0.00 && !haveExit {
                print("At \(counter) on \(today.dateString) - exit for \(today.ticker)")
                haveExit = true
            }

            if today.backTestProfit != 0.00 && haveExit {
                print("Already exited - delete this ---> At \(counter) on \(today.dateString) - exit for \(today.ticker)")
            }
            
            /*
 BIL 2016/5/12 entry  true
 BIL 2016/5/13 entry  true
 BIL 2016/5/16 entry  true
 BIL 2016/5/17 entry  true
 BIL 2016/5/19 entry  true*/
            
            // this shows me I have 5 entries for this ticker, need to fix this first
//            if counter == 8 {
//                print("\nWARNING - no exit date found for \(today.ticker)!\n")
//                return
//            }
        }
    }
    
    func portfolioCapital() {
        
        let galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)

        var galaxieDict = [String:Bool]()
        
        for each in galaxie {
            galaxieDict.updateValue(true, forKey: each)
        }
        
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var cumCapUsed = [Double]()
        var profit = [Double]()
        var average:Double = 0.00
        var maxCap:Double = 0.00
        var buyCount = 0
        var sellCount = 0
        var winCount = 0
        //var curPos = [String]()
        var tickerDate = [String:Date]()
        
        
        // found the problem, not selling all of the ticker BIL is one boight on  2016-11-28
        // solution
        // 1. add entry price to tickerDate
        // 2. Loop through tickerDate and exit any trades over 7 days
        // 3. how do I find profit? new func to find close on ticker + Date
        // 4. print error when close not found
        // 5. at end of backtest loop through tickerDate and alert any old positions
        
        //          -- OR ---
        // or just check realm for positions older than 7 days... ?
        // on each ticker sorted by date loop through and if no exit by 7 days... exit and save to realm
        
        //          -- NOW I BELIEVE --
        // just look for each.capitalReq & backTestProfit to get a running total P&L and rolling capital used
        
    
        
        for today in dateArray {

            if today.longEntry && galaxieDict[today.ticker]! {
                galaxieDict.updateValue(false, forKey: today.ticker)
                buyCount += 1
                let positions = buyCount - sellCount
                //curPos.append(today.ticker)
                tickerDate.updateValue(today.date!, forKey: today.ticker)
                print("\nBuying \(today.ticker)\nPositions held: \(positions) \(tickerDate)\n")
                
                cumCapUsed.append(today.capitalReq)
                
                let sum = cumCapUsed.reduce(0, +)
                average = sum / Double(cumCapUsed.count)
                if sum > maxCap {
                    maxCap = sum
                }
                print(buyCount," buys ", sellCount, " sells")
                print(today.dateString, today.ticker, "using cash:", dollarStr(largeNumber: today.capitalReq), "Avg Cash: ", dollarStr(largeNumber: average), "max cash:",dollarStr(largeNumber: maxCap))
                //flat = false
                galaxieDict.updateValue(false, forKey: today.ticker)
            }
            // remove average entry cost
            if  today.backTestProfit != 0.00 {
                sellCount += 1
                let positions = buyCount - sellCount
                tickerDate.removeValue(forKey: today.ticker)
                print("Selling \(today.ticker)\nPositions held: \(positions)\n")
                if today.backTestProfit >= 0 {
                    winCount += 1
                }
                profit.append(today.backTestProfit)
                let cumProfitNow = profit.reduce(0, +)
                let cumProfitStr = String(format: "%.2f", cumProfitNow)
                print("Cumulative Profit ",cumProfitStr)
                if today.backTestProfit <= 0 {
                    print("\nLoss of \(today.backTestProfit)\n")
                }
                //flat = true
                galaxieDict.updateValue(true, forKey: today.ticker)
                
                if let i = cumCapUsed.index(of: average) {
                    print(today.dateString, today.ticker, "***** Removing matching amount:", dollarStr(largeNumber: cumCapUsed[i]))
                    cumCapUsed.remove(at: i)
                } else {
                    print(buyCount," buys ", sellCount, " sells")
                    print(today.dateString, today.ticker, "***** No matching amount so remove last")
                    if cumCapUsed.count > 0 {
                        cumCapUsed.removeLast()
                    }
                }
            }
        }
        let winPct = (Double(winCount) / Double(sellCount)) * 100
        let winPctStr = String(format: "%.2f", winPct)
        let roi = (profit.reduce(0,+) / maxCap) * 100
        let roiStr = String(format: "%.2f", roi)
        print("\n\t\t\tFinal Results")
        print("Win Count \(winCount) sell count \(sellCount)")
        print("\(winPctStr)% Wins \tRoi \(roiStr)%")
        print("\n---> \(dollarStr(largeNumber: profit.reduce(0,+))) <---\n")
    }
    
    func dollarStr(largeNumber:Double )->String {
        var formattedNumber:String = "nil"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        formattedNumber = numberFormatter.string(from: NSNumber(value:Int(largeNumber)))!
        //print("total Profit ", formattedNumber!)
        return formattedNumber
    }

    
    // get every date in Prices. if backTestProfit -> master: [(date: Date, profit: Double)]
    func calcAllTickers(debug:Bool)-> [(date: Date, profit: Double)]  {
        
        print("inside makeMaster()")
        var allDatesAllTickers: [(date: Date, profit: Double)] = []
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var counter = 0
        var lastDate = Date()
        var todaysProfit = [Double]()
        var sumOfToday:Double = 0.00
        print("we have a dateArray of \(dateArray.count)")
        
        
        
        for today in dateArray {
            
            if debug { print(today.backTestProfit) }
            //if today.backTestProfit != 0.00 {
            if today.date == lastDate  {
                todaysProfit.append(today.backTestProfit)
                sumOfToday = todaysProfit.reduce(0, +)
                if debug { print(today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday)) }
            } else {
                // new date so save last date and total for the day
                //if sumOfToday != nil {
                allDatesAllTickers.append((date: lastDate, profit: sumOfToday))
                todaysProfit.removeAll()
                // start adding new date
                todaysProfit.append(today.backTestProfit)
                sumOfToday = todaysProfit.reduce(0, +)
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
    func dailyProfit(debug: Bool)-> [(date: Date, profit: Double)]  {
        let master = calcAllTickers(debug: debug)
        var cumProfit = master
        var runOfProfit:Double = 0.00
        
        for (index, today) in master.enumerated() {
            runOfProfit += today.profit
            cumProfit[index].profit = runOfProfit
        }
        
        if debug {
            for today in cumProfit {
                print(today.date, String(format: "%.2f", today.profit))
            }
        }
        
        return cumProfit
    }
    
    // get cumulative daily profit save weekly cumulative profit to realm
    func weeklyProfit(debug: Bool, completion:  (_ result:Bool) ->Void) {
        let cumProfit = dailyProfit(debug: debug)
        var cumProfitWeelky: [(date: Date, profit: Double)] = []
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
                cumProfitWeelky.append((date: today.element.date, profit: today.element.profit))
                WklyStats().updateCumulativeProfit(date: today.element.date, profit: today.element.profit)
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
