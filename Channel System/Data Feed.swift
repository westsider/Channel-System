//
//  Data Feed.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class LastPrice {
    var ticker: String?
    var date: String?
    var open: Double?
    var high: Double?
    var low: Double?
    var close: Double?
    var volume: Double?
}

class DataFeed {
    
    var lastPrice = [LastPrice]()
    
    /// Get realtime ohlc
    func getLastPrice(ticker: String, saveIt: Bool, debug: Bool, enterDoStuff: @escaping (Bool) -> Void ) {
        
        if ( debug ) {  print("looking for \(ticker)...") }
        enterDoStuff(false)
        // get last price from intrio
        let prices = "https://api.intrinio.com/prices?identifier=\(ticker)"
        let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
        let password = "e6cf8f921bb621f398240e315ab79068"
        
        
        Alamofire.request("\(prices)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if ( debug ) { print("JSON: \(json)") }
                    
                    self.lastPrice.removeAll()
                    
                    for data in json["data"].arrayValue {
                        
                        let lastPriceObject = LastPrice()
                        
                        lastPriceObject.ticker = ticker
                        
                        if let date = data["date"].string {
                            lastPriceObject.date = date
                        }
                        
                        if let open = data["open"].double {
                            lastPriceObject.open = open
                        }
                        
                        if let high = data["high"].double {
                            lastPriceObject.high = high
                        }
                        if let low = data["low"].double {
                            lastPriceObject.low = low
                        }
                        
                        if let close = data["close"].double {
                            lastPriceObject.close = close
                        }
                        self.lastPrice.append(lastPriceObject)
                    }
                    
                    let item = self.lastPrice.first
                    
                    if (saveIt && item?.ticker != nil) { RealmHelpers().saveToRealm(ticker: (item?.ticker)!, last: (item?.close)!, date: (item?.date)!) }
                    
                    enterDoStuff(true)
                    
                case .failure(let error):
                    debugPrint(error)
                }
        }
    }
}
