//
//  Realm Price Data.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Prices: Object {
    
    @objc dynamic var ticker  = ""
    @objc dynamic var last    = 0.0
    @objc dynamic var time    = ""
    @objc dynamic var taskID  = NSUUID().uuidString
}

class RealmHelpers: Object {
    
    func saveToRealm(ticker: String, last: Double, date: String) {
        // populate realm with last
        print("ready for realm")
        let realm = try! Realm()
        
        let prices = Prices()
        
        prices.time = date
        
        prices.last = last
        
        prices.ticker = ticker
        
        print("Begin Realm Save \(prices.ticker) \(prices.time) \(prices.last)")
        
        try! realm.write({ // [2]
            realm.add(prices)
        })
    }
    
    func deleteAll() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        print("\nRealm\tClearer!\n")
    }
}

class Entries: Object{
    
    @objc dynamic var ticker    = ""
    @objc dynamic var entry     = 0.00
    @objc dynamic var stop      = 0.00
    @objc dynamic var target    = 0.00
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var shares    = 0.00
    @objc dynamic var risk      = 0.00
    @objc dynamic var inTrade   = false
    @objc dynamic var taskID = NSUUID().uuidString

    
    func calcShares(stopDist:Double, risk:Int)-> Int {
        let shares = Double(risk) / stopDist
        return Int( shares )
    }
    
    func makeEntry(ticker:String, entryString:String, shares:Int, target:Double, stop:Double, debug:Bool) {
        print("You entered \(entryString)")
        let entries = Entries()
        let entry = Double(entryString)
        entries.ticker = ticker
        entries.entry = entry!
        entries.stop = stop
        entries.target = target
        entries.shares = Double(shares)
        entries.risk = 50
        entries.date = Date()
        entries.inTrade = true
        
        let realm = try! Realm()

        try! realm.write {
            realm.add(entries)
        }
        
        if ( debug ) { _ = self.getOpenTrades() }
    }
    
    func getOpenTrades()-> Results<Entries> {
        
        //MARK: - TODO - Filter for open trades
        let realm = try! Realm()
        let allEntries = realm.objects((Entries).self)
        let numEntries = allEntries.count
        for items in allEntries {
            print("\nshowOpenTrades() count is \(numEntries)")
            print("\(items.date!) \(String(describing: items.ticker)) shares:\(String(describing: items.shares)) entry:\(String(describing: items.entry)) stop:\(String(describing: items.stop)) target:\(String(describing: items.target))")
        }
        return allEntries
    }
}
