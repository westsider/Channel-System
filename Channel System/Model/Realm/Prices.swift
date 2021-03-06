//
//  Prices.swift
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
    @objc dynamic var trailStop = 0.00
    @objc dynamic var target    = 0.00
    @objc dynamic var shares    = 0
    @objc dynamic var risk      = 0.00
    @objc dynamic var inTrade   = false
    @objc dynamic var exitedTrade = false
    @objc dynamic var exitDate:Date = Utilities().closeTradeIn(days: 7)
    @objc dynamic var exitPrice = 0.00
    @objc dynamic var profit    = 0.00
    @objc dynamic var loss      = 0.00
    @objc dynamic var account   = ""
    @objc dynamic var capitalReq = 0.00
    @objc dynamic var backTestProfit:Double = 0.00
    @objc dynamic var stars:Int = 0
    
    //MARK: - Count Prices
    func allPricesCount()-> Int {
        let realm = try! Realm()
        let allPrices = realm.objects(Prices.self)
        if ( allPrices.count == 0 ) {
            return 0
        } else {
           return allPrices.count
        }
    }
    
    func printLastPrices(symbols: [String], last: Int) {
        
        for ticker in symbols {
            let oneTicker = sortOneTicker(ticker: ticker, debug: false)
            let totalCount = oneTicker.count
            for (index, each )  in oneTicker.enumerated() {
                if (index > totalCount-last) {
                    print("\(each.ticker) \(each.dateString) c\(each.close) 10:\(each.movAvg10) 200:\(each.movAvg200)")
                }
            }
        }
    }
    //MARK: - Sort One Ticker
    func sortOneTicker(ticker:String, debug:Bool)-> Results<Prices> {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", id)
        let sortedByDate = oneSymbol.sorted(byKeyPath: "date", ascending: true)
        if ( debug ) {
            for each in sortedByDate {
                print("\(each.ticker) \(each.dateString) o\(each.open) h\(each.high) l\(each.low) c\(each.close)  --> sma(10) \(each.movAvg10) sma(200) \(each.movAvg200) w\(each.wPctR)")
            }
        }
        return sortedByDate
    }
    
    //MARK: - add star rating to each price in a ticker
    func addStarToTicker(ticker:String, stars:Int, debug:Bool) {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", id)
        let sortedByDate = oneSymbol.sorted(byKeyPath: "date", ascending: true)

        try! realm.write {
            for each in sortedByDate {
                    each.stars = stars
            }
        }
    }
    
    func getStarsFor(ticker:String, debug:Bool)->Int {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", id)
        let sortedByDate = oneSymbol.sorted(byKeyPath: "date", ascending: true)
        if let stars = sortedByDate.first?.stars {
            if ( debug ) {
                print("Ticker: \(ticker) Stars: \(stars)")
            }
            return stars
        } else {
            print("\n----> ALERT! No Stars Found For \(ticker) <----\n")
            return 0
        }
    }
    

    
    //MARK: - Sort Entries
    func sortEntriesBy(recent: Bool, days: Int)-> Results<Prices> {
        let realm = try! Realm()
        let minStars:Int = Stats().getStars()
        let allEntries = realm.objects(Prices.self).filter("longEntry = true").filter("stars  >= %@", minStars)
        let sortDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        
        if ( recent ) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -days, to: Date())
            let specificNSDate:NSDate = yesterday! as NSDate
            let predicate = NSPredicate(format: "longEntry = true AND date > %@", specificNSDate)
            let results = realm.objects(Prices.self).filter(predicate).filter("stars  >= %@", minStars)
            let resultsSortDate = results.sorted(byKeyPath: "date", ascending: false)
            return resultsSortDate
        } else {
             return sortDate
        }
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
    
    func getFromTest(taskID:String) {
        let realm = try! Realm()
        let onePrice = realm.objects(Prices.self).filter("taskID == %@", taskID)
        print("Showing all files for taskID: \(taskID)")
        for each in onePrice {
            debugPrint(each)
        }
    }
    
    func getOnePriceFrom(taskID:String)-> Prices {
        let realm = try! Realm()
        let thisItem = realm.objects(Prices.self).filter("taskID == %@", taskID).first!
        return thisItem
    }
    
    func getOneDateFrom(taskID:String)-> Prices {
        let realm = try! Realm()
        let tickerID = realm.objects(Prices.self).filter("taskID == %@", taskID).first!
        return tickerID
    }
    
    func getLastTaskIDfrom(ticker:String)-> String {
        let realm = try! Realm()
        let theIndex = realm.objects(Prices.self).filter("ticker == %@", ticker)
        return theIndex.last!.taskID
    }
    
    func getLastTaskID()-> String {
        let realm = try! Realm()
        let lastTicker = realm.objects(Prices.self).filter("taskID == %@", taskID).last!
        return lastTicker.taskID
    }
    
    func getLastDateInRealm(debug: Bool)-> Date {
        let realm = try! Realm()
        let theTickerSeries = realm.objects(Prices.self)
        if let sortedByDate = theTickerSeries.sorted(byKeyPath: "date", ascending: true).last {
            if ( debug ) { print("Last Date In Realm is: \(sortedByDate.dateString)") }
            return sortedByDate.date!
        } else {
            return Utilities().convertToDateFrom(string: "2018/01/09", debug: false)
        }
        
    }
    
    func getLastDateInMktCond(debug: Bool)-> Date {
        let realm = try! Realm()
        let theTickerSeries = realm.objects(MarketCondition.self)
        let sortedByDate = theTickerSeries.sorted(byKeyPath: "date", ascending: true).last!
        if ( debug ) { print("Last Date In market condition is: \(sortedByDate.dateString)") }
        return sortedByDate.date!
    }
    
    func checkIfNew(date:Date, realmDate:Date, debug: Bool)-> Bool {
        var isNewer = false
        if ( debug ) { print("Last date in realm \(String(describing: realmDate)) vs new date: \(date))")}
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
    
    func checkIfInLastTenDays(date:Date, realmDate:Date, debug: Bool)-> Bool {
        var withinTenDays = false
        if ( debug ) { print("Last date in realm \(String(describing: realmDate)) vs new date: \(date))")}
        
        let tenDaysAgo = subtractTenDays(currentDate: realmDate, debug: false)
        let dateStr = Utilities().convertToStringNoTimeFrom(date: date)
        
        if date > tenDaysAgo {
            if ( debug ) {
                print("\n\(dateStr) is within last 10 days <-------------------------------\n")
            }
            withinTenDays =  true
        } else {
            if ( debug ) { print("\(dateStr) is older than 10 days ago.") }
            withinTenDays =  false
        }
        return withinTenDays
    }
    
    func subtractTenDays(currentDate:Date, debug:Bool)-> Date {
        let daysToRemove = -10
        var dateComponent = DateComponents()
        dateComponent.day = daysToRemove
        //let pastDate = Calendar.current.date
        let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        if debug { print("Date now is \(currentDate), and 10 days ago was \(pastDate!)") }
        return pastDate!
    }
    
    func tickerCount() {
        let galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 0)
        var counter = 0
        for each in galaxie {
            let id = each
            let oneSymbol = realm?.objects(Prices.self).filter("ticker == %@", id)
            if oneSymbol?.last?.ticker != "" {
                counter += 1
            }
        }
        print("Number of tickers in realm is \(counter)\n")
    }
    
    func isNewDate(ticker:String, date:Date, debug:Bool)-> Bool {
        var answer = true
        if sortOneTicker(ticker: ticker, debug: false).filter("date == %@", date).last != nil {
            answer = false
            if debug { print("\nwe found \(Utilities().convertToStringNoTimeFrom(date: date)) in current database\n") }
        } else {
            if debug { print("\nwe didnt find \(Utilities().convertToStringNoTimeFrom(date: date)) in current database\nAdding this Date\n") }
        }
        
        return answer
    }
}











