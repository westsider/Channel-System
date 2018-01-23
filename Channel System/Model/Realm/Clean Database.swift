//
//  Clean Database.swift
//  Channel System
//
//  Created by Warren Hansen on 1/9/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import  RealmSwift

class CheckDatabase {
    
    var portfolio: [String: Int] = [:]
    let galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
    
    func checkDuplicates() {
        
        for ticker in galaxie {
            let _ = findDuplicates(ticker: ticker, debug: true)
        }
        print("\nDeleting duplicatre dates from realm...\nmake sure this runs A F T E R csv load!\n")
    }
    
    func canIgetDataFor(ticker:String, isOn:Bool) {
        if isOn {
            ReplacePrices().getLastPrice(ticker: ticker, debug: true, page: 1, saveToRealm: false, completion: { (finished) in
                if finished {
                    print("finished getting prices for \(ticker)")
                }
            })
        }
    }
    
    func initially(deleteAll: Bool, printPrices: Bool, printTrades: Bool){
        if ( deleteAll ) { RealmHelpers().deleteAll() }
        if ( printPrices ) { Prices().printLastPrices(symbols: galaxie, last: 4) }
        if ( printTrades ) { RealmHelpers().printOpenTrades() }
    }
    
    func testPastEntries() {
        //ManualTrades().oneEntryForTesting()
        // ManualTrades().removeExitFrom(yyyyMMdd: "2017/12/29", exityyyyMMdd: "2018/01/22", ticker: "AAPL", exitPrice: 0.0, debug: true)
        ManualTrades().removeEntry(yyyyMMdd: "2018/01/23", ticker: "PG", debug: true)
    }
    
    func report(debug:Bool, galaxie:[String])-> String {
        /*
         1. check num of records in each ticker and alert if less than spy
            -my solution is to wipe and reload manually with CleadDate()
         2. check each ticker for 0 prices
         3. check for double prints
         4. check not last date
         */
        
        let total = galaxie.count
        let numRecords =  Prices().allPricesCount()
        let lastUpdate = Prices().getLastDateInRealm(debug: false)
        var missingPriceRecords:Int = 0
        var zeroValues:Int = 0
        var doublePrints:Int = 0
        var notUpdatedCounter:Int = 0
        var counter:Int = 0
        var answer:String = "nan"
        if debug {
            answer = "\n\n-------------------------------------------------------\n"
            //print()
            answer +=  "Checking database integrity. \(numRecords) records found"
        }
        //DispatchQueue.global(qos: .background).async {
        for ticker in galaxie {
            missingPriceRecords += self.checkForMissingPrices(ticker: ticker)       // test 1
            zeroValues += self.checkForZeroVal(ticker: ticker)             // test 2
            doublePrints += self.findDuplicates(ticker: ticker, debug: true) // test 3
            notUpdatedCounter += Utilities().lastDateMatchesRealm(ticker: ticker, lastUpdate: lastUpdate, debug: false) // test 4
            counter += 1
        }
        //}
        // DispatchQueue.main.async {
        if counter != total {
            answer += "\n***WARNING *** \n missing tickers in realm\nCount of tickers was \(counter) and Num of symbols was \(total)"
        } else {
            answer += "\nNo missing tickers in realm\n\(counter) records found out of \(total) total symbols"
        }
        
        answer = "\n\n-------------------------------------------------------\n"
        answer += "\nDatabase Condition Summary"
        answer += "\nWarning! missing \(missingPriceRecords) days of price data"
        answer += " \(portfolio)"
        answer += "\nWarning! found \(zeroValues) zero values"
        if doublePrints != 0 {
            answer += "\nWarning! found \(doublePrints) duplicate days"
        } else {
            answer += "\nNo duplicate days found"
        }
        
        answer += "\nWarning! found \(notUpdatedCounter) tickers not updated"
        print(answer)
        print("\tif you see errors call\n\tresetThis(ticker: \"EZU\", isOn: true)\n\tto clean the ticker")
        print("-------------------------------------------------------\n")
        //completion(true)
        //}
        return answer
    }
    
    func checkForMissingPrices(ticker:String)-> Int {
        //MARK: - TODO list tickers affected
        
        let realm = try! Realm()
        let numSpyPrices = realm.objects(Prices.self).filter("ticker == %@", "SPY").count
        let count = realm.objects(Prices.self).filter("ticker == %@", ticker).count
        var diff:Int = 0
        if count < numSpyPrices {
            //print("spy count is \(numSpyPrices) \(ticker) count is \(count)")
            diff = numSpyPrices - count
            if diff > 2 {
                print("Warning test # 1 \(ticker) is missisng \(diff) days of data")
                if portfolio[ticker] == nil {
                    portfolio[ticker] = diff }
                }
        }
        
        return diff
    }
    
    func checkForZeroVal(ticker:String)-> Int {
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        var zeroValCounter:Int = 0
        for each in prices {
            let open = each.open
            let high = each.high
            let low = each.low
            let close = each.close
            let sma10 = each.movAvg10
            let sma200 = each.movAvg200
            
            let arrayVals = [open, high, low, close, sma10, sma200]
            let nameVals = ["open", "high", "low", "close", "sma10", "sma200"]
            
            for  (index, vals) in arrayVals.enumerated() {
                if vals == 0.0 {
                    print("\t\t \(ticker) \(nameVals[index]) on \(each.dateString) is \(vals)")
                    zeroValCounter += 1
                }
            }
            
        }
        if zeroValCounter != 0 {
            print("Warning test #2 on \(ticker) we found \(zeroValCounter) with a value of zero")
        }
        return zeroValCounter
    }
    
    func findDuplicates(ticker:String, debug:Bool)-> Int {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", id)
        let sortedByDate = oneSymbol.sorted(byKeyPath: "date", ascending: true)
        var lastDate:Date?
        var lastID:String = ""
        var doublePrintCounter:Int = 0
        for each in sortedByDate {
            //print("\(String(describing: each.date )) \(String(describing: lastDate))")
            if (each.date == lastDate ) {
                print("Warning test #3  double printsfor \(ticker) on \(each.dateString)")
                deletePriceBy(taskID: lastID)
                doublePrintCounter += 1
            }
            lastDate = each.date
            lastID = each.taskID
        }
        return doublePrintCounter
    }
    
    func deletePriceBy(taskID:String) {
        let realm = try! Realm()
        let oneDay = Prices().getOneDateFrom(taskID: taskID)
        try! realm.write {
            realm.delete(oneDay)
        }
    }
    
}
