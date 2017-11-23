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
    // Manage Trade
    @objc dynamic var entry     = 0.00
    @objc dynamic var stop      = 0.00
    @objc dynamic var target    = 0.00
    @objc dynamic var shares    = 0
    @objc dynamic var risk      = 0.00
    @objc dynamic var inTrade   = false
    @objc dynamic var exitedTrade   = false
    @objc dynamic var exitDate:Date = DateHelper().closeTradeIn(days: 7)
    @objc dynamic var profit    = 0.00
    @objc dynamic var loss      = 0.00
    //MARK: - Count Prices
    func allPricesCount()-> Int {
        let realm = try! Realm()
        let allPrices = realm.objects(Prices.self)
        return allPrices.count
    }
    
    func printAllPrices() {
        let realm = try! Realm()
        let allPrices = realm.objects(Prices.self)
        for each in allPrices {
            print("\(each.ticker) \(each.date!) \(each.close)")
        }
    }
    //MARK: - Sort One Ticker
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
    //MARK: - Sort Entries
    func sortEntries()-> Results<Prices> {
        let realm = try! Realm()
        let allEntries = realm.objects(Prices.self).filter("longEntry == %@", true)
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
  
        return sortedByDate
    }
    //MARK: - Get Price From Task ID
    func getFrom(taskID:String)-> Results<Prices> {
        let realm = try! Realm()
        let tickerID = realm.objects(Prices.self).filter("taskID == %@", taskID).first!
        let aTicker = tickerID.ticker
        let theTickerSeries = realm.objects(Prices.self).filter("ticker == %@", aTicker)
        let sortedByDate = theTickerSeries.sorted(byKeyPath: "date", ascending: true)
        return sortedByDate
    }
    
    func getLastTaskID()-> String {
        let realm = try! Realm()
        let lastTicker = realm.objects(Prices.self).filter("taskID == %@", taskID).last!
        return lastTicker.taskID
    }
    func getLastDateInRealm(debug: Bool)-> Date {
        let realm = try! Realm()
        let theTickerSeries = realm.objects(Prices.self)
        let sortedByDate = theTickerSeries.sorted(byKeyPath: "date", ascending: true).last!
        if ( debug ) { print("Last Date In Realm is: \(sortedByDate.dateString)") }
        return sortedByDate.date!
    }
    func checkIfNew(date:Date, realmDate:Date, debug: Bool)-> Bool {
        var isNewer = false
        //let realm = try! Realm()
        // this is not getting the last price.. sort it
        //let lastTicker = sortEntries().first!
        //let realmDate = getLastDateInRealm(debug: false)
        if ( debug ) {print("Last date in realm \(String(describing: realmDate)) vs new date: \(date))")}
        
        if date > realmDate {
            if ( debug ) {
                print("New Date is greater then realm date")
                print("is a new date")
            }
            isNewer =  true
        } else {
            if ( debug ) { print("---->    is not a new date <---- ") }
            isNewer =  false
        }
        return isNewer
    }
}











