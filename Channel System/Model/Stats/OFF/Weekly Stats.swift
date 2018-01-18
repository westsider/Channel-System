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
    
    @objc dynamic var entryDate:Date?
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var cost      = 0.00
    @objc dynamic var maxCost   = 0.00
    @objc dynamic var taskID    = NSUUID().uuidString
    @objc dynamic var ticker    = ""
    
    
    func updateCumulativeProfit(date: Date, entryDate:Date, ticker:String, profit: Double, cost:Double, maxCost:Double) {
        print("today \(Date()) date to save \(date)")
        if date <= Date() {
            let realm = try! Realm()
            let thisWeek = WklyStats()
            thisWeek.date = date
            thisWeek.ticker = ticker
            thisWeek.profit = profit
            thisWeek.cost = cost
            thisWeek.maxCost = maxCost
            thisWeek.entryDate = entryDate
            try! realm.write {
                realm.add(thisWeek)
            }
        }
    }
    
    func getWeeklyStatsFromRealm() {
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "date", ascending: true)
        var cumulatveSum:Double = 0.0
        
        if sortedByDate.count >  1 {
            let results = sortedByDate
            for each in results {
                cumulatveSum += each.profit
                let date = Utilities().convertToStringNoTimeFrom(date: each.date!)
                let profit = Utilities().dollarStr(largeNumber: each.profit)
                let capReq = Utilities().dollarStr(largeNumber: each.cost)
                let cumulative = Utilities().dollarStr(largeNumber: cumulatveSum)
                print("\(date)\t\(each.ticker)\t\(profit)\t\(capReq)\t\t\(cumulative)")
            }
        }
    }

    // loop ad print print("\(date)\t\(each.ticker)\t\(profit)\t\(capReq)\t\t\(cumulative)")
    //print("\n-----> here is the sorted struct sum \(Utilities().dollarStr(largeNumber: portFolioSum))\n")
    
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
                print("\(each.date!)\t\(each.ticker)\t\(Utilities().dollarStr(largeNumber: each.profit))\t\(Utilities().dollarStr(largeNumber: each.cost))")
            }
            print("---------> Done Checking realm <--------\n")
        } else {
            print("No stats in Realm")
        }
    }
    
    func clearWeekly() {
        let realm = try! Realm()
        let weekly = realm.objects(WklyStats.self)
        try! realm.write {
            realm.delete(weekly)
        }
        print("\nRealm \tMarketCondition \tCleared!\n")
    }
}

