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
        ManualTrades().oneEntryForTesting(ticker: "EWT", yyyyMMddSlash: "2018/02/06", price: 37.22, shares: 88)
        //  ManualTrades().makePastExit(yyyyMMdd: "2018/02/07", exityyyyMMdd: "2018/02/08", ticker: "RSX", exitPrice: 21.64, debug: true)
        //  ManualTrades().removeEntry(yyyyMMdd: "2017/01/03", ticker: "IYF", debug: true)
        //  ManualTrades().removeExitFrom(yyyyMMdd: "2017/01/03", exityyyyMMdd: "2017/01/08", ticker: "IYF", exitPrice: 0.0, debug: true)
    }
    
    func replaceThe(missingDays:[String]) {
        //DispatchQueue.global(qos: .userInitiated).async {
        let myGroup = DispatchGroup()
        var groupCounter = 0
        let _ = DispatchQueue.global(qos: .userInitiated)
        print("\n---------------------------")
        DispatchQueue.concurrentPerform(iterations: missingDays.count) {
            i in
            print("Checking \(missingDays[i]) for missing days...")
            MissingDates.findAndGetMissingDatesFor(ticker: missingDays[i], completion: { (finished) in
                myGroup.enter()
                if finished {
                    groupCounter += 1
                    let message = "\(missingDays[i]) \(groupCounter) of \(missingDays.count) complete"
                    print("\n\n+++++++++++++++> \(message) \t<+++++++++++++++\n\n")
                    Utilities().playAlertSound()
                    myGroup.leave()
                }
            })
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            print("We might have finiahed all of the download groups \(groupCounter) of \(missingDays.count) complete")
        }
//            for ticker in missingDays {
//                myGroup.enter()
//                // run func
//                MissingDates.findAndGetMissingDatesFor(ticker: ticker) { (finished) in
//                    if finished {
//                        groupCounter += 1
//
//                        let message = "\(ticker) \(groupCounter) of \(missingDays.count) complete"
//                        print("\n\n+++++++++++++++> \(message) \t<+++++++++++++++\n\n")
//                        Utilities().playAlertSound()
//                        myGroup.leave()
//                    }
//                }
//                if groupCounter == missingDays.count {
//                    //let _ = CheckDatabase().report(debug: true, galaxie: SymbolLists().allSymbols)
//                    Utilities().playErrorSound()
//                }
//            }//
//        myGroup.notify(queue: DispatchQueue.main) { // 2
//            print("we Finiahed all of the download groups")
//        }
        //}
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
        //var missingEnries:[String] = []
        if debug {
            answer = "\n\n-------------------------------------------------------\n"
            answer +=  "Checking database integrity. \(numRecords) records found"
        }
        
        for ticker in galaxie {
            DispatchQueue.global(qos: .background).async {
                missingPriceRecords += self.checkForMissingPrices(ticker: ticker)       // test 1
                zeroValues += self.checkForZeroVal(ticker: ticker)             // test 2
                doublePrints += self.findDuplicates(ticker: ticker, debug: true) // test 3
                notUpdatedCounter += Utilities().lastDateMatchesRealm(ticker: ticker, lastUpdate: lastUpdate, debug: false) // test 4
                counter += 1
//                if self.numberOfEntries(ticker: ticker) < 1 {
//                    missingEnries.append(ticker)
//                }
            }
        }
        
        DispatchQueue.main.async {
            if counter != total {
                answer += "\n***WARNING *** \n missing tickers in realm\nCount of tickers was \(counter) and Num of symbols was \(total)"
            } else {
                answer += "\nNo missing tickers in realm\n\(counter) records found out of \(total) total symbols"
            }
            
//            print("\nHere are tickers with Missing entries\n")
//            debugPrint(missingEnries)
            print("\nHere are tickers with missing days\n")
            var missingDaysArray:[String] = []
            for each in self.portfolio {
                missingDaysArray.append(each.key)
            }
            debugPrint(missingDaysArray)
            //MARK: - Todo Uncomment this func to auto fix missing days
            // self.replaceThe(missingDays: missingDaysArray)
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
        print("\tif you see errors call\n\tMissingDates.findAndGetMissingDatesFor(ticker:\n\tto clean the ticker")
        print("-------------------------------------------------------\n")
        //completion(true)
        //}
        Utilities().playAlertSound()
        return answer
    }
    
    func checkForMissingPrices(ticker:String)-> Int {

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
    
    func showMissingDatesFor(ticker:String, debug:Bool)->(String,String) {
        
        print("\n--------------------\n\tShowing Missing Dates for \(ticker)\n--------------------\n")
        var spyDates:[String] = []
        var tickerDates:[String] = []
        var missingDates:[String] = []
        // get dates from SPY, ticker
        let spy = Prices().sortOneTicker(ticker: "SPY", debug: false)
        for each in spy {
            spyDates.append(each.dateString)
        }
        let oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false)
        for each in oneTicker {
            tickerDates.append(each.dateString)
        }
        for each in spyDates {
            if tickerDates.contains(each) {
                if debug { print("found \(each) in \(ticker) date") }
            } else {
                if debug { print("didn't find  \(ticker) in SPY data") }
                missingDates.append(each)
            }
        }
        let matchingDates = spy.count - missingDates.count
        print("found \(missingDates.count) dates missing in \(ticker) and \(matchingDates) dates match\n\n")
        let sortedDates = missingDates.sorted()
        print("\(ticker) first missing date is \(String(describing: sortedDates.first)), last \(String(describing: sortedDates.last))")
        debugPrint(missingDates)
        return (sortedDates.first!, sortedDates.last!)
    }
    

    
    func datesForOneTicker(ticker:String) {
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        for each in prices {
            print(each.dateString)
        }
    }
    func numberOfEntries(ticker:String)-> Int {
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        var tradeCount = 0
        for each in prices {
            if each.longEntry {
                tradeCount += 1
            }
        }
        return tradeCount
    }
    
    func checkIndicators(ticker:String)-> Int {
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        var sma10 = 0
        var sma200 = 0
        var wPtcR = 0
        for each in prices {
            if each.movAvg10 == 0.0 {
                sma10 += 1
            }
            if each.movAvg200 == 0.0 {
                sma200 += 1
            }
            if each.wPctR == 0.0 {
                wPtcR += 1
            }
        }
        print("Found zero values for \(ticker) SMA(10)\(sma10), SMA(200) \(sma200), wPct(R) \(wPtcR)")
        let allZeroData = sma10 + sma200 + wPtcR
        return allZeroData
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
