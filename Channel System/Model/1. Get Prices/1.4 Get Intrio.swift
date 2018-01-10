//
//  1.4 Get Intrio.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class IntrioFeed {

    func getData(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {

        var counter = 0
        let total = galaxie.count
        let lastDateInRealm = Prices().getLastDateInRealm(debug: false)
        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                self.getLastPrice(ticker: symbols, lastInRealm: lastDateInRealm, debug: false) { ( finished ) in // 1.4
                    if finished {
                        DispatchQueue.main.async {
                            counter += 1
                            print("Intrio \(counter) of \(total)")
                            if counter == total {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Get realtime ohlc
    func getLastPrice(ticker: String, lastInRealm: Date, debug: Bool, completion: @escaping (Bool) -> Void) {
        // get last price from intrio
        //if ( debug ) {
            print("Requesting remote data for \(ticker)") //}
        let request = "https://api.intrinio.com/prices?ticker=\(ticker)" //DWDP
        let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
        let password = "e6cf8f921bb621f398240e315ab79068"
        var isNewDate:Bool = false
        var inlast10:Bool = false
        var dateIsToday:Bool = false
        Alamofire.request("\(request)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if ( debug ) { print("JSON: \(json)") }
                    for data in json["data"].arrayValue {
   
                        if ( debug ) { print("\n---------------> starting json loop  <---------------------") }
                        let prices = Prices()
                        prices.ticker = ticker
                        if let date = data["date"].string {
                            if ( debug ) {  print("\nHere is the date to test \(date)") }
                            prices.dateString = date
                            prices.date = Utilities().convertToDateFrom(string: date, debug: false)
                            isNewDate = Prices().checkIfNew(date: prices.date!, realmDate: lastInRealm, debug: false)
                            inlast10 = Prices().checkIfInLastTenDays(date: prices.date!, realmDate: lastInRealm, debug: false)
                            dateIsToday = Utilities().thisDateIsToday(date: prices.date!, debug: false)
                            if ( debug ) { print("This is the date downloaded \(date) isNewDate = \(String(describing: isNewDate))") }
                        }
                        if let close = data["close"].double { prices.close = close }
                        if let volume = data["volume"].double { prices.volume = volume }
                        if let open = data["open"].double { prices.open = open }
                        if let high = data["high"].double { prices.high = high } 
                        if let low = data["low"].double { prices.low = low }
                // the next section is complicated becuase the intrio feed will only return open and close for today
                // only save new days not in realm. this is for first run when we just have csv data from 11/30/2017
                        if ( isNewDate ) {
                            if ( debug ) { print("we are adding \(prices.dateString) to realm\n") }
                            RealmHelpers().saveSymbolsToRealm(each: prices)
                        } else {
                            if ( debug ) { print("we are NOT adding \(prices.dateString) to realm\n") }
                        }
                // for saftey and because today will only return an open and close, update the last 10 days
                        if inlast10 {
                            RealmHelpers().updatePriorPrice(each: prices)
                        }
                // if this is today, simulate a high and low becuase even after the close I only show a open and close from the API
                        if dateIsToday {
                            if ( debug ) {  print("replace todays data for \(prices.ticker)") }
                            let simHighLow = self.simulateHighLow(with: prices)
                            RealmHelpers().updateTodaysPrice(each: simHighLow)
                        }
                        
                    }  // JSON loop ends
                    if ( debug ) { print("\(ticker) request complete") }
                    completion(true)
                case .failure(let error):
                    print("Intrinio Error getting \(ticker)")
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
