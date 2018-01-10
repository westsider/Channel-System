//
//  Weekly Stats.swift
//  Channel System
//
//  Created by Warren Hansen on 12/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class WklyStats: Object {
    
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var cost    = 0.00
    @objc dynamic var maxCost    = 0.00
    @objc dynamic var taskID     = NSUUID().uuidString
    
    func updateCumulativeProfit(date: Date, profit: Double, cost:Double, maxCost:Double) {
        print("today \(Date()) date to save \(date)")
        if date <= Date() {
            let realm = try! Realm()
            let thisWeek = WklyStats()
            thisWeek.date = date
            thisWeek.profit = profit
            thisWeek.cost = cost
            thisWeek.maxCost = maxCost
            try! realm.write {
                realm.add(thisWeek)
            }
        }
    }
    
    func showCumProfitFromRealm() {
        print("\nchecking weekly stats from realm\n")
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "date", ascending: true)
        if sortedByDate.count >  1 {
            let results = sortedByDate
            print("We have  have weekly stats count > 1")
            print("now reading from realm count: \(sortedByDate.count)")
            for each in results {
                print("\(each.date!)\t\(Utilities().dollarStr(largeNumber: each.profit))\t\(Utilities().dollarStr(largeNumber: each.cost))")
            }
            print("---------> Done Checking realm <--------\n")
        } else {
            print("No stats in Realm")
        }
    }
}

