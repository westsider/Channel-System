//
//  Realm Helpers.swift
//  Channel System
//
//  Created by Warren Hansen on 11/7/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelpers: Object {
    
    func saveSymbolsToRealm(each: Prices) {
        let realm = try! Realm()
        let price = Prices()
        price.ticker = each.ticker
        price.date = each.date
        price.dateString = each.dateString
        price.open = each.open
        price.high = each.high
        price.low = each.low
        price.close = each.close
        price.volume = each.volume
        price.movAvg10 = 0.00
        price.movAvg200 = 0.00
        price.wPctR = 0.00
        price.longEntry = false
        price.taskID = NSUUID().uuidString
        
        try! realm.write({
            realm.add(price)
        })
    }
    //MARK: - Clear Realm
    func deleteAll() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        print("\nRealm \tCleared!\n")
    }
    //MARK: - Calc Shares
    func calcShares(stopDist:Double, risk:Int)-> Int {
        let shares = Double(risk) / stopDist
        return Int( shares )
    }
    //MARK: - Make Entry
    func makeEntry(taskID:String, entry:Double, stop:Double, target:Double, shares:Int, risk:Double, debug:Bool) {
        //print("You entered \(entryString)")
        let realm = try! Realm()
        let ticker = Prices().getFrom(taskID: taskID).last!

        try! realm.write {
            ticker.entry     = entry
            ticker.stop      = stop
            ticker.target    = target
            ticker.shares    = shares
            ticker.risk      = risk
            ticker.inTrade   = true
        }
        
        if ( debug ) { _ = self.getOpenTrades() }
    }
    //MARK: - Sort Entries
    func getOpenTrades()-> Results<Prices> {
        let realm = try! Realm()
        let allEntries = realm.objects(Prices.self).filter("inTrade == %@", true)
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        
        return sortedByDate
    }
    //MARK: - Get Open Trades
//    func getOpenTrades()-> Results<Prices> {
//        //MARK: - TODO - Filter for open trades
//        let realm = try! Realm()
//        let allEntries = realm.objects((Entries).self)
//        let numEntries = allEntries.count
//        for items in allEntries {
//            print("\nshowOpenTrades() count is \(numEntries)")
//            print("\(items.date!) \(String(describing: items.ticker)) shares:\(String(describing: items.shares)) entry:\(String(describing: items.entry)) stop:\(String(describing: items.stop)) target:\(String(describing: items.target))")
//        }
//        return allEntries
//    }
}
