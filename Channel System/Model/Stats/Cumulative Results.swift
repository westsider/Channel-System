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
    
    var master: [(date: Date, profit: Double)] = []
    
    var cumProfit: [(date: Date, profit: Double)] = []
    
    var cumProfitWeelky: [(date: Date, profit: Double)] = []
    
    var finishedWeekly:Bool = false
    
    func getdataforChart( completion: @escaping () -> ()) {
        
        makeMaster(debug:false)
        
        DispatchQueue.main.async {
            if self.finishedWeekly  {
                for each in self.cumProfitWeelky {
                    print(each.date)
                }
                completion()
            }
        }
    }
    
    func makeMaster(debug:Bool) {
        
        let realm = try! Realm()
        let dateArray = realm.objects(Prices.self).sorted(byKeyPath: "date", ascending: true)
        var counter = 0
        var lastDate = Date()
        var todaysProfit = [Double]()
        var sumOfToday:Double?
        for today in dateArray {
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
        dailyProfit(debug: false)
    }
    
    func dailyProfit(debug: Bool) {
        cumProfit = master
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
        _ = weeklyProfit(debug: true)
    }
    
     func weeklyProfit(debug: Bool)-> [(date: Date, profit: Double)]  {
        for today in cumProfit.enumerated() {
            // if today is friday
            if isFriday(date: today.element.date) {
                //print("Hello Friday")
                cumProfitWeelky.append((date: today.element.date, profit: today.element.profit))
            }
            if debug {
                for today in cumProfitWeelky {
                    print(today.date, String(format: "%.2f", today.profit))
                }
            }
        }
        finishedWeekly = true
        return cumProfitWeelky
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




