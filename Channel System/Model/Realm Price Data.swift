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

    @objc dynamic var ticker     = ""
    @objc dynamic var dateString = ""
    @objc dynamic var date:Date?
    @objc dynamic var open       = 0.00
    @objc dynamic var high       = 0.00
    @objc dynamic var low        = 0.00
    @objc dynamic var close      = 0.00
    @objc dynamic var volume     = 0.00
    @objc dynamic var movAvg10   = 0.00
    @objc dynamic var movAvg200  = 0.00
    @objc dynamic var wPctR      = 0.00
    @objc dynamic var longEntry  = false
    @objc dynamic var taskID     = NSUUID().uuidString
    
    func allPricesCount()-> Int {
        let realm = try! Realm()
        let allPrices = realm.objects(Prices.self)
        return allPrices.count
    }
    
    func sortOneTicker(ticker:String, debug:Bool)-> Results<Prices> {
        let realm = try! Realm()
        //let allPrices = realm.objects(Prices.self)
        let id = ticker
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", id)
        let sortedByDate = oneSymbol.sorted(byKeyPath: "date", ascending: true)
        if ( debug ) {
            for each in sortedByDate {
                print("\(each.ticker) \(each.dateString)")
            }
        }
        return sortedByDate
    }
}

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
    
    func deleteAll() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        print("\nRealm \tCleared!\n")
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
