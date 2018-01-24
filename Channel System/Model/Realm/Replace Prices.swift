//
//  Replace Prices.swift
//  Channel System
//
//  Created by Warren Hansen on 1/9/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class ReplacePrices {
    
    func writeOverPrblemSymbol(ticker:String) {
        deleteOldSymbol(ticker: ticker)
        saveNewSymbol(ticker: ticker, saveToRealm: true, debug: true)
    }
    
    func deleteOldSymbol(ticker:String) {
        // delete ralm object
        let realm = try! Realm()
        let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", ticker)
        try! realm.write {
            realm.delete(oneSymbol)
        }
    }
    
    func saveNewSymbol(ticker:String, saveToRealm:Bool, debug:Bool) {

        var countCalls:Int = 0
        let galaxie = [ticker]
        
        for i in 1...8 {
            self.getLastPrice(ticker: ticker, debug: true, page: i, saveToRealm: saveToRealm, completion: { (finished) in
                if finished {
                    countCalls += 1
                    print("got page \(i) countCall = \(countCalls)")
                    if countCalls == 8 {
                        print("\n------> Now Calc Indicators <-----")
                        print("Finished all \(countCalls)")
                        // need 2014/11/25  got 2014-11-05
                        //run indicators ect
                        SMA().getData(galaxie: galaxie, debug: debug, period: 10) { ( finished ) in // 2.0
                            if finished {
                                print("sma(10) done")
                                SMA().getData(galaxie: galaxie, debug: debug, period: 200) { ( finished ) in // 2.0
                                    if finished {
                                        print("sma(200) done")
                                        PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                            if finished {
                                                print("oscilator done")
                                                MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                    if finished  {
                                                        print("mc done")
                                                        Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                            if finished  {
                                                                print("Entry done")
                                                                CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                                    print("\ncalc Stars done!\n")
                                                                })
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
   
    
    /// Get realtime ohlc
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
                        if saveToRealm { RealmHelpers().saveSymbolsToRealm(each: prices) }
                       
                        //debugPrint(prices)
                        // if this is today, simulate a high and low becuase even after the close I only show a open and close from the API
                        if dateIsToday {
                            if ( debug ) {  print("replace todays data for \(prices.ticker)") }
                            let simHighLow = self.simulateHighLow(with: prices)
                            if saveToRealm { RealmHelpers().updateTodaysPrice(each: simHighLow) }
                        }
                        lastLow = prices.high
                        lastHigh = prices.low
                        
                    }  // JSON loop ends
                    if ( debug ) { print("\(ticker) request complete") }
                    completion(true)
                case .failure(let error):
                    print("\n---------------------------------\n\tIntrinio Error getting \(ticker)\n-----------------------------------")
                    debugPrint(error)
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
    
    func getSymbolsAvailable(debug: Bool, page:Int, completion: @escaping (Bool) -> Void) {
        // get last price from intrio
        //if ( debug ) {
        print("Requesting remote data for symbols") //}
        let request = "https://api.intrinio.com/companies?page_number=\(page)" //DWDP  page_number=2
        let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
        let password = "e6cf8f921bb621f398240e315ab79068"
        Alamofire.request("\(request)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if ( debug ) { print("JSON: \(json)") }
                   // for data in json["data"].arrayValue {
        
                    //}  // JSON loop ends
                    if ( debug ) { print("Symbol request complete") }
                    completion(true)
                case .failure(let error):
                    print("Intrinio Error getting symbols")
                    debugPrint(error)
                }  // result ends
        }
    }
    
    
}
