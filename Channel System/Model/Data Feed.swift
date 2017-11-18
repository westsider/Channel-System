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
    
    var lastPrice = [LastPrice]()
    
    var sortedPrices = [LastPrice]()
    
    var allSortedPrices = [[LastPrice]]()
    
    var symbolArray = [String]()
    
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
    func getLastPrice(ticker: String, saveIt: Bool, debug: Bool, doneWork: @escaping (Bool) -> Void ) {
        var counter = 0
        var rowCounter = 0
        for page in 1...3 {
            print("requesting JSON for \(ticker) page \(page)")
            if ( debug ) {  print("looking for \(ticker)...") }
            doneWork(false)
            // get last price from intrio
            var request = "https://api.intrinio.com/prices?ticker=\(ticker)"
            if (page > 1) {
                request = "https://api.intrinio.com/prices?identifier=\(ticker)&page_number=\(page)"
                // https://api.intrinio.com/prices?identifier=AAPL&page_number=1
            }
            let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
            let password = "e6cf8f921bb621f398240e315ab79068"
        
            Alamofire.request("\(request)")
                .authenticate(user: user, password: password)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if ( debug ) { print("JSON: \(json)") }
                        
                        for data in json["data"].arrayValue {
                            rowCounter += 1
                            if ( rowCounter == 1 ) { print("Parsing page \(page) row 1 for \(ticker)")}
                            let lastPriceObject = LastPrice()
                            
                            lastPriceObject.ticker = ticker
                            
                            if let date = data["date"].string {
                                lastPriceObject.dateString = date
                                lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
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
                        
                        counter += 1
                        if ( counter == 3 ) {
                            
                            print("\(ticker) request complete")
                            //self.sortPrices(arrayToSort: self.lastPrice)
                            
                            doneWork(true)
                        }
                        rowCounter = 0
                    case .failure(let error):
                        debugPrint(error)
                    }
            }
         }
        
      }
    
    
//    func returnSortedSymbol()-> [LastPrice]{
//        print("returnSortedSymbol")
//        return self.sortedPrices
//    }
//
//    func printThis(priceSeries: [LastPrice]) {
//        print("\nprintThis")
//        for item in priceSeries {
//            print("\(item.ticker!) \(item.date!)")
//        }
//    }
//
//    func sortPrices(arrayToSort: [LastPrice]) {
//        sortedPrices = arrayToSort.sorted(by: { $0.date?.compare($1.date!) == .orderedAscending })
//    }
}
