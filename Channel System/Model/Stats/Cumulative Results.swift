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
    func makeMaster() {
        var master: [(date: Date, profit: Double)] = []
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
                    print(today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday!))
                } else {
                    // new date so save last date and total for the day
                    if sumOfToday != nil {
                        master.append((date: lastDate, profit: sumOfToday!))
                        todaysProfit.removeAll()
                        // start adding new date
                        todaysProfit.append(today.backTestProfit)
                        sumOfToday = todaysProfit.reduce(0, +)
                        print("new date!\n", today.dateString, today.ticker, String(format: "%.2f", today.backTestProfit) , String(format: "%.2f", sumOfToday!))
                    }
                }
                counter += 1
                lastDate = today.date!
            }
        }
    }
}
