//
//  Cumulative Results.swift
//  Channel System
//
//  Created by Warren Hansen on 12/4/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class CumBackTest {
    
    // get every date in Prices. if backTestProfit -> master: [(date: Date, profit: Double)]
    func makeMaster(debug:Bool)-> [(date: Date, profit: Double)]  {
        
        print("inside makeMaster()")
        var master: [(date: Date, profit: Double)] = []
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var counter = 0
        var lastDate = Date()
        var todaysProfit = [Double]()
        var sumOfToday:Double?
        
        print("we have a dateArray of \(dateArray.count)")
        
        for today in dateArray {
            if debug { print(today.backTestProfit) }
            if today.backTestProfit != 0.00 {
                if today.date == lastDate  {
                    todaysProfit.append(today.backTestProfit)
                    sumOfToday = todaysProfit.reduce(0, +)
                    if debug { print(today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday!)) }
                } else {
                    // new date so save last date and total for the day
                    if sumOfToday != nil {
                        master.append((date: lastDate, profit: sumOfToday!))
                        todaysProfit.removeAll()
                        // start adding new date
                        todaysProfit.append(today.backTestProfit)
                        sumOfToday = todaysProfit.reduce(0, +)
                        if debug { print("new date!\n", today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday!)) }
                    }
                }
                counter += 1
                lastDate = today.date!
            }
        }
        return master
    }
    // get master: [(date: Date, profit: Double)] ->  cumulative daily profit
    func dailyProfit(debug: Bool)-> [(date: Date, profit: Double)]  {
        let master = makeMaster(debug: debug)
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
     func weeklyProfit(debug: Bool)  {
        let cumProfit = dailyProfit(debug: debug)
        var cumProfitWeelky: [(date: Date, profit: Double)] = []
        // delete old stas in realm
        let realm = try! Realm()
        let oldData = realm.objects(WklyStats.self)
        try! realm.write {
            realm.delete(oldData)
        }
        //let thisWeek = WklyStats()
        for today in cumProfit.enumerated() {
            // if today is friday
            if isFriday(date: today.element.date) {
                //print("Hello Friday")
                cumProfitWeelky.append((date: today.element.date, profit: today.element.profit))
                WklyStats().updateStats(date: today.element.date, profit: today.element.profit)
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




