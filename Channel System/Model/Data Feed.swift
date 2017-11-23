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
import CSV

class DataFeed {
    
    func getPricesFromCSV(count: Int, ticker: String,debug: Bool, completion: @escaping () -> ()) {
        
        // the call to csv
        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
        let stream = InputStream(fileAtPath: filleURLProject!)!
        let csv = try! CSVReader(stream: stream)
        //"date","close","volume","open","high","low"
        while let row = csv.next() {
            if ( debug ) { print("\(row)") }
            let prices = Prices()
            prices.ticker = ticker
            let date = row[0]
            prices.dateString = date
            prices.date = DateHelper().convertToDateFrom(string: date, debug: false)
            if let close = Double(row[1]){
                prices.close = close }
            if let volume = Double(row[2]){
                prices.volume = volume }
            if let open = Double(row[3]) {
                prices.open = open }
            if let high = Double(row[4]){
                prices.high = high }
            if let low = Double(row[5]){
                prices.low = low }
            RealmHelpers().saveSymbolsToRealm(each: prices)
        }
        // update  UI on completion
        DispatchQueue.main.async {
            completion()
        }
    }
    
    /// Get realtime ohlc
    func getLastPrice(ticker: String, debug: Bool, completion: @escaping () -> ()) {
        // get last price from intrio
        if ( debug ) { print("Requesting remote data for \(ticker)") }
        let request = "https://api.intrinio.com/prices?ticker=\(ticker)"
        let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
        let password = "e6cf8f921bb621f398240e315ab79068"
        var isNewDate = false
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
                            if ( debug ) {  print("\nHere is the date to test \(date)") }
                            prices.dateString = date
                            prices.date = DateHelper().convertToDateFrom(string: date, debug: false)
                            isNewDate = Prices().checkIfNew(date: prices.date!, debug: false)
                            if ( debug ) { print("This is the date downloaded \(date) isNewDate = \(String(describing: isNewDate))") }
                        }
                        if let close = data["close"].double { prices.close = close }
                        if let volume = data["volume"].double { prices.volume = volume }
                        if let open = data["open"].double { prices.open = open }
                        if let high = data["high"].double { prices.high = high }
                        if let low = data["low"].double { prices.low = low }
                        if ( isNewDate ) {
                            if ( debug ) { print("we are adding \(prices.dateString) to realm\n") }
                            RealmHelpers().saveSymbolsToRealm(each: prices)
                        } else {
                            if ( debug ) { print("we are NOT adding \(prices.dateString) to realm\n") }
                        }
                    }
                    DispatchQueue.main.async { completion() }
                    if ( debug ) { print("\(ticker) request complete") }
                    
                case .failure(let error):
                    debugPrint(error)
                }
         }
      }
}
