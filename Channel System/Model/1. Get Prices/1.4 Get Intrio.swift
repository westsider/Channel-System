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
    
//    //MARK: - First Segment the galaxie to throttles the api call to intrinio
//    func getDataSegments(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
//        let segmentGalaxy = galaxie.chunked(by: 14)
//        let total = segmentGalaxy.count
//        print("\nSegment count is \(segmentGalaxy.count)\n")
//        var segmentCounter = 0
//        for segment in segmentGalaxy {
//            print("\n++++++++++++++++++++++++++++++++++++++++\n\tWe are beginning segment \(segmentCounter)\n++++++++++++++++++++++++++++++++++++++++\n")
//            getData(galaxie: segment, debug: true, completion: { (finished) in
//                print("\n++++++++++++++++++++++++++++++++++++++++\n\tWe are finished with segment \(segmentCounter)\n++++++++++++++++++++++++++++++++++++++++\n")
//                if finished {
//                    segmentCounter += 1
//                    if segmentCounter == total {
//                        completion(true)
//                    }
//                }
//            })
//        }
//    }

//    //MARK: - Second loop through segments to make call to intrinio
//    func getData(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
//        var requestCounter = 0
//        let myGroup = DispatchGroup()
//        let _ = DispatchQueue.global(qos: .userInitiated)
//        DispatchQueue.concurrentPerform(iterations: galaxie.count) {
//            i in
//            print("We are in get Data: Intrinio request for \( galaxie[i])")
//            getLastPrice(ticker: galaxie[i], lastInRealm: Prices().getLastDateInRealm(debug: debug), debug: debug) { ( finished ) in
//                myGroup.enter()
//                print("\n\n--------------------------------\n--------------------------------\n\tUpdateing prices for \( galaxie[i])\n--------------------------------\n--------------------------------\n\n")
//                if finished {
//                    requestCounter -= 1; print("\n********************\nRequest Countdown at \(requestCounter)\n********************\n")
//                    DispatchQueue.main.async {
//                        if i == galaxie.count {
//                            completion(true)
//                        }
//                        myGroup.leave()
//                    }
//                }
//            }
//        }
//    }
    
    var downloadErrors: Array<String> = []
    
    func getDataAsync(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        
        //MARK: - Todo - loop through 4 at a time
        var i = 0
        while i < galaxie.count - 1 {
            print("\nWe are in get Data: Intrinio request for \(galaxie[i])")
            standatdNetworkCall(ticker: galaxie[i], lastInRealm: Prices().getLastDateInRealm(debug: debug), debug: debug) { ( finished ) in
                
                if finished {
                    print("\nWe finished getting ticker \(galaxie[i]), \(i) of \(galaxie.count) symbols")
                    //MARK: - Todo - message to main UI
                    i += 1
                }
                if i == galaxie.count {
                    print("\nWe finished getting all \(galaxie.count) symbols")
                    completion(true)
                }
            }
        }
        
        if downloadErrors != [] {
            let errorMessage = "Here are the download errors \(downloadErrors)"
            print("\n------------------------------------\n\(errorMessage)\n--------------------------------\n")
            //Alert.showBasic(title: "Download Errors", message: errorMessage)
        }
    }

    func standatdNetworkCall(ticker: String, lastInRealm: Date, debug: Bool, completion: @escaping (Bool) -> Void) {
        print("Requesting remote data for \(ticker)") //}
        //let request = "https://api.intrinio.com/prices?ticker=\(ticker)" //DWDP
        let user = Utilities().getUser().user
        let password = Utilities().getUser().password
        let loginData = String(format: "%@:%@", user, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var isNewDate:Bool = false
        var inlast10:Bool = false
        var dateIsToday:Bool = false
        var lastHigh:Double = 0.0
        var lastLow:Double = 0.0
        
        // create the request
        let url = URL(string: "https://api.intrinio.com/prices?ticker=\(ticker)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        
        //making the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                
                print("\(error.debugDescription)")
                return
            }
            let json = JSON(data)
            if ( debug ) { print("JSON: \(json)") }
            if let httpStatus = response as? HTTPURLResponse {
                // check status code returned by the http server and process result
                Process.httpStatus(httpStatus: httpStatus.statusCode)
                if httpStatus.statusCode != 200 {
                    self.downloadErrors.append("Error getting \(ticker): Code \(httpStatus.statusCode)")
                }
            }
            
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
        }
        task.resume()
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
                    print("\n\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\tIntrinio Error getting \(ticker)\n\(error.localizedDescription)\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n")
                    Utilities().playErrorSound()
                    //Alert.showBasic(title: "Error for \(ticker)", message: error.localizedDescription)
                    //debugPrint(error)
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
