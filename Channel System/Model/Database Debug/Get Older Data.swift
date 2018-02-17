//
//  Get Older Data.swift
//  Channel System
//
//  Created by Warren Hansen on 2/8/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PriorData {
    
    //var arrayOfPages:[(String,Int,String,String)]
    
    func findPagesFor(start:String, end:String, ticker: String,  debug: Bool,  completion: @escaping ([Int]) -> Void) {
        
        var pagesWeNeed:[Int] = []
        var haveStart:Bool = false
        var haveEnd:Bool = false
        
        for i in 0...13 {
            print("Requesting page \(i) for \(ticker)") //}
            let request = "https://api.intrinio.com/prices?ticker=\(ticker)&page_number=\(i)"
            let user = Utilities().getUser().user
            let password = Utilities().getUser().password
            var dateArray:[String] = []
 
            Alamofire.request("\(request)")
                .authenticate(user: user, password: password)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print("Here is the Json from \(ticker)")
                        debugPrint(json)
                        for data in json["data"].arrayValue {
                            if let date = data["date"].string {
                                dateArray.append(date)
                            }
                        }  // JSON loop ends
                        if ( debug ) {
                            
                            guard let firstDate = dateArray.last else {
                                print("Warning firstDate does not exist")
                                break
                            }
                            guard let lastDate = dateArray.first else {
                                print("Warning lastDate does not exist")
                                break
                            }
               
                            print("\(ticker) request complete for page \(i) \(firstDate) -> \(lastDate)")
                            if  dateArray.contains(start)  {
                                print("\nPage \(i) holds the start date we need!\n")
                                haveStart = true
                                pagesWeNeed.append(i)
                            }
                            
                            if  dateArray.contains(end) {
                                print("\nPage \(i) holds the end date we need!\n")
                                haveEnd = true
                                pagesWeNeed.append(i)
                            }
   
                        }
                        if haveStart && haveEnd {
                            print("\nThis search satisfied our needs from pages \(pagesWeNeed)\n")
                        } else {
                            print("\nWe need to expand the search\n")
                        }
                        pagesWeNeed.sort()
                        completion(pagesWeNeed)
                    case .failure(let error):
                        print("\n---------------------------------\n\tIntrinio Error getting \(ticker)\n-----------------------------------")
                        debugPrint(error)
                    }  // result ends
            }
        }
    }
    
    //MARK: - load only a collection of pages
    func loadfromCollection(ticker:String ,array:[Int], saveToRealm:Bool, debug:Bool) {
        
        var countCalls:Int = 0
        let galaxie = [ticker]
        
        print("Looping though pages \(String(describing: array.first)) to \(String(describing: array.last))")
        for i in array {
            getLastPrice(ticker: ticker, debug: true, page: i, saveToRealm: saveToRealm, completion: { (finished) in
                if finished {
                    countCalls += 1
                    print("got page \(i) countCall = \(countCalls)")
                    if countCalls == 4 {
                        print("\n------> Now Calc Indicators <-----")
                        print("Finished all \(countCalls)")
                        // need 2014/11/25  got 2014-11-05
                        //run indicators ect
                        SMA().getData(galaxie: galaxie, debug: debug, period: 10, redoAll: true) { ( finished1 ) in // 2.0
                            if finished1 {
                                print("sma(10) done")
                                SMA().getData(galaxie: galaxie, debug: debug, period: 200, redoAll: true) { ( finished2 ) in // 2.0
                                    if finished2 {
                                        print("sma(200) done")
                                        PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished3) in
                                            if finished3 {
                                                print("oscilator done")
                                                // MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                // if finished  {
                                                //    print("mc done")
                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished4) in
                                                    if finished4  {
                                                        print("Entry done")
                                                        CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                            //if finished  {
                                                            print("\ncalc Stars done!\n")
                                                            print("\n-------------------------------------\n\t\tChecking DataBase\n--------------------------------------\n")
                                                            //_ = MarketCondition().overview(galaxie: SymbolLists().uniqueElementsFrom(testSet: false, of: 100), debug: true)
                                                            Utilities().playAlertSound()
                                                            if i == 14 {
                                                                let _ = CheckDatabase().showMissingDatesFor(ticker: ticker, debug: false)
                                                                Recalculate().allIndicators(ticker: ticker, debug: true, redoAll: true)
                                                            }
                                                        })
                                                    }
                                                })
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    //MARK: - load 7 - 13
    func addMissing(ticker:String ,start:Int, end:Int, saveToRealm:Bool, debug:Bool) {
        DispatchQueue.global(qos: .background).async {
            var countCalls:Int = 0
            print("Looping though pages \(start) to \(end)")
            for i in start...end {
                self.getLastPrice(ticker: ticker, debug: true, page: i, saveToRealm: saveToRealm, completion: { (finished) in
                    if finished {
                        countCalls += 1
                        print("got page \(i) countCall = \(countCalls)")
                        
                        if i == end {
                            Recalculate().allIndicators(ticker: ticker, debug: true, redoAll: true)
                            Utilities().playAlertSound()
                        }
                    }
                })
            }
        }
    }
    
    // redo this func to only write to realm the dates that are missing
    func getLastPrice(ticker: String,  debug: Bool, page:Int, saveToRealm:Bool, completion: @escaping (Bool) -> Void) {
        
        print("Requesting page \(page) for \(ticker)") //}
        let request = "https://api.intrinio.com/prices?ticker=\(ticker)&page_number=\(page)"
        let user = Utilities().getUser().user
        let password = Utilities().getUser().password
        var dateIsToday:Bool = false
        var lastHigh:Double = 0.0
        var lastLow:Double = 0.0
        Alamofire.request("\(request)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if ( debug ) { print("JSON: \(json)") }
                    for data in json["data"].arrayValue {
                        let prices = Prices()
                        prices.ticker = ticker
                        if let date = data["date"].string {
                            prices.dateString = date
                            if page == 8 { print(date) }
                            prices.date = Utilities().convertToDateFrom(string: date, debug: false)
                            dateIsToday = Utilities().thisDateIsToday(date: prices.date!, debug: false)
                        }
                        if let close = data["close"].double { prices.close = close }
                        if let volume = data["volume"].double { prices.volume = volume }
                        if let open = data["open"].double { prices.open = open }
                        if let high = data["high"].double { prices.high = high } else {
                            prices.high = lastHigh
                        }
                        if let low = data["low"].double { prices.low = low } else {
                            prices.low = lastLow
                        }
                        // the next section is complicated becuase the intrio feed will only return open and close for today
                        // only save new days not in realm. this is for first run when we just have csv data from 11/30/2017
                        let isNewDate = Prices().isNewDate(ticker: ticker, date: prices.date!, debug: true)
                        if saveToRealm && isNewDate {
                            RealmHelpers().saveSymbolsToRealm(each: prices)
                            print("Yes we added \(Utilities().convertToStringNoTimeFrom(date: prices.date!))")
                        }
                        
                        //debugPrint(prices)
                        // if this is today, simulate a high and low becuase even after the close I only show a open and close from the API
                        if dateIsToday  && isNewDate  {
                            if ( debug ) {  print("replace todays data for \(prices.ticker)") }
                            let simHighLow = self.simulateHighLow(with: prices)
                            if saveToRealm {
                                RealmHelpers().updateTodaysPrice(each: simHighLow)
                                
                            }
                        }
                        lastLow = prices.high
                        lastHigh = prices.low
                        
                    }  // JSON loop ends
                    if ( debug ) { print("\(ticker) request complete") }
                    completion(true)
                case .failure(let error):
                    print("\n---------------------------------\n\tIntrinio Error getting \(ticker)\n-----------------------------------")
                    debugPrint(error)
                    DispatchQueue.main.async {
                        Utilities().playErrorSound()
                    }
                }  // result ends
        }
    }
    
    func simulateHighLow(with:Prices)-> Prices {
        if with.open > with.close {
            with.high = with.open
            with.low = with.close
        } else {
            with.high = with.close
            with.low = with.open
        }
        return with
    }
}
