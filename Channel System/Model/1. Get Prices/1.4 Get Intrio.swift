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
    
    //MARK: - First Segment the galaxie to throttles the api call to intrinio
    func getDataSegments(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        let segmentGalaxy = galaxie.chunked(by: 14)
        let total = segmentGalaxy.count
        print("\nSegment count is \(segmentGalaxy.count)\n")
        var segmentCounter = 0
        for segment in segmentGalaxy {
            print("\n++++++++++++++++++++++++++++++++++++++++\n\tWe are beginning segment \(segmentCounter)\n++++++++++++++++++++++++++++++++++++++++\n")
            getData(galaxie: segment, debug: true, completion: { (finished) in
                print("\n++++++++++++++++++++++++++++++++++++++++\n\tWe are finished with segment \(segmentCounter)\n++++++++++++++++++++++++++++++++++++++++\n")
                if finished {
                    segmentCounter += 1
                    if segmentCounter == total {
                        completion(true)
                    }
                }
            })
        }
    }

    //MARK: - Second loop through segments to make call to intrinio
    func getData(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        print("We are in get Data")
        var counter = 0
        let total = galaxie.count
        let lastDateInRealm = Prices().getLastDateInRealm(debug: debug)
        var requestCounter = 0

        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                print("Intrinio request for \(symbols)")
                self.getLastPrice(ticker: symbols, lastInRealm: lastDateInRealm, debug: debug) { ( finished ) in // 1.4
                    print("\n\n--------------------------------\n--------------------------------\n\tUpdateing prices for \(symbols)\n--------------------------------\n--------------------------------\n\n")
                    if finished {
                        requestCounter -= 1
                        DispatchQueue.main.async {
                            counter += 1
                            print("Intrio finished \(symbols) \(counter) of \(total)")
                            //MARK: - TODO - if error getting data return
                            if counter == total {
                                completion(true)
                            }
                        }
                    }
                } //
            }
        }
    }

    //MARK: - Third call to intrinio for lcurrent and historical data
    func getLastPrice(ticker: String, lastInRealm: Date, debug: Bool, completion: @escaping (Bool) -> Void) {
        // get last price from intrio
        //if ( debug ) {
            print("Requesting remote data for \(ticker)") //}
        let request = "https://api.intrinio.com/prices?ticker=\(ticker)" //DWDP
        let user = Utilities().getUser().user
        let password = Utilities().getUser().password
        var isNewDate:Bool = false
        var inlast10:Bool = false
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
                        if let high = data["high"].double { prices.high = high } else {
                            prices.high = lastHigh
                        }
                        if let low = data["low"].double { prices.low = low } else {
                            prices.low = lastLow
                        }
                        // only save new days not in realm. this is for first run when we just have csv data from 11/30/2017
                        if ( isNewDate ) {
                             print("we are adding a new object for \(prices.ticker) on \(prices.dateString) to realm")
                            RealmHelpers().saveSymbolsToRealm(each: prices)
                        }
                        // this section caused the last 100 days to be written over
                        //else {
                        //     print("we are updating an old object for \(prices.ticker) on \(prices.dateString) to realm\n")
                        //}
                        // for saftey and because today will only return an open and close, update the last 10 days
                        if inlast10 {
                            print("we are only updating the last 10 object for \(prices.ticker) on \(prices.dateString) to realm")
                            RealmHelpers().updatePriorPrice(each: prices)
                        }
                        // if this is today, simulate a high and low becuase even after the close I only show a open and close from the API
                        if dateIsToday {
                            if ( debug ) {  print("replace todays data for \(prices.ticker)") }
                            let simHighLow = self.simulateHighLow(with: prices)
                            RealmHelpers().updateTodaysPrice(each: simHighLow)
                        }
                        lastLow = prices.high
                        lastHigh = prices.low
                    }
                    if ( debug ) { print("\(ticker) request complete") }
                    completion(true)
                case .failure(let error):
                print("\n\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\tIntrinio Error getting \(ticker)\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n")
                    Utilities().playErrorSound()
                    Alert.showBasic(title: "Error for \(ticker)", message: error.localizedDescription)
                    debugPrint(error)
                    return
                }
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
