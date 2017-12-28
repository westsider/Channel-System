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
        price.inTrade   = false
        price.exitedTrade = false
        price.taskID = NSUUID().uuidString
        price.account = each.account
        
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

    func getTaskIDfor(yyyyMMdd:String, ticker:String)->String {
        // 2017-12-27 AAPL
        if let oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false).filter("dateString == %@", yyyyMMdd).last {
            return (oneTicker.taskID)
        } else {
            return "noTaskID"
        }

    }
    //MARK: - Make Entry
    func makeEntry(taskID:String, entry:Double, stop:Double, target:Double, shares:Int, risk:Double, debug:Bool, account:String, capital: Double) {
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
            ticker.account   = account
            ticker.capitalReq = capital
        }
        
        if ( debug ) { _ = self.getOpenTrades() }
    }
    
    
    //MARK: - Sort Entries
    func getOpenTrades()-> Results<Prices> {
        let realm = try! Realm()
        let allEntries = realm.objects(Prices.self).filter("inTrade = true AND exitedTrade = false")
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        return sortedByDate
    }
    
    func getClosedTrades()-> Results<Prices> {
        let realm = try! Realm()
        let allEntries = realm.objects(Prices.self).filter("inTrade = false AND exitedTrade = true")
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        return sortedByDate
    }
    
    func deleteClosedTrade(taskID:String, debug:Bool) {
        
        let closed = Prices().getOnePriceFrom(taskID: taskID)
        if debug { print("Changing \(closed.ticker) to exitedTrade = false") }
        debugPrint(closed)
        let realm = try! Realm()
        try! realm.write {
            closed.exitedTrade = false
        }
        let closedCheck = Prices().getFrom(taskID: taskID).last!
        if debug { print("\nProve it!")
            debugPrint(closedCheck) }
    }
    
    func printOpenTrades(){
        let openTrades = getOpenTrades()
        for each in openTrades {
            print("\(each.dateString) \(each.ticker)")
        }
    }
    
    func getCandidates()-> Results<Prices> {
        let realm = try! Realm()
        let allEntries = realm.objects(Prices.self).filter("inTrade == %@", true)
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        
        return sortedByDate
    }
    
    func getEntryFor(taskID:String)-> Results<Prices> {
        let realm = try! Realm()
        return realm.objects(Prices.self).filter("inTrade = true AND exitedTrade = false AND taskID == %@", taskID)
    }
    
    func checkExitedTrade(taskID:String)-> Results<Prices> {
        let realm = try! Realm()
        return realm.objects(Prices.self).filter("inTrade = false AND exitedTrade = true AND taskID == %@", taskID)
    }
}
