//
//  Clean Database.swift
//  Channel System
//
//  Created by Warren Hansen on 1/9/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import  RealmSwift

class CleanData {
    
    var portfolio: [String: Int] = [:]
    
    func report(debug:Bool, galaxie:[String]) {
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
        
        if debug {  print("\nChecking database integrity. \(numRecords) records found")}
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
            print("\n***WARNING *** \n missing tickers in realm\nCount of tickers was \(counter) and Num of symbols was \(total)")
        } else {
            print("\nNo missing tickers in realm\n\(counter) records found out of \(total) total symbols\n")
        }
        
        print("\n-------------------------------------------------------")
        print("----------   Database Condition Summary   -------------")
        print("\tWarning! missing \(missingPriceRecords) days of price data")
        debugPrint(portfolio)
        print("\tWarning! found \(zeroValues) zero values")
        if doublePrints != 0 {
            print("\tWarning! found \(doublePrints) duplicate days")
        } else {
            print("\tNo duplicate days found")
        }
        
        print("\tWarning! found \(notUpdatedCounter) tickers not updated")
        print("-------------------------------------------------------\n")
        //}
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
            print("Warning test # 1 \(ticker) is missisng \(diff) days of data")
            if portfolio[ticker] == nil {
                portfolio[ticker] = diff }
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
            //let nameVals = ["open", "high", "low", "close", "sma10", "sma200"]
            
            for  vals in arrayVals {
                if vals == 0.0 {
                    //print("Warning test #2 on \(ticker) \(nameVals[index]) on \(each.dateString) is \(vals)")
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
