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
    var dateString: String?
    var date: Date?
    var open: Double?
    var high: Double?
    var low: Double?
    var close: Double?
    var volume: Double?
    var movAvg10: Double?
    var movAvg200:Double?
    var wPctR:Double?
}

class DataFeed {
    
    var lastPrice = [LastPrice]()
    
    var sortedPrices = [LastPrice]()
    
    /// Get realtime ohlc
    func getLastPrice(ticker: String, page: Int, saveIt: Bool, debug: Bool, enterDoStuff: @escaping (Bool) -> Void ) {
        
        if ( debug ) {  print("looking for \(ticker)...") }
        enterDoStuff(false)
        // get last price from intrio
        var request = "https://api.intrinio.com/prices?ticker=\(ticker)"
        if (page > 1) {
            request = "https://api.intrinio.com/prices?identifier=\(ticker)&page_number=\(page)"
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
                    
                    let item = self.lastPrice.first
                    
                    if (saveIt && item?.ticker != nil) { RealmHelpers().saveToRealm(ticker: (item?.ticker)!, last: (item?.close)!, date: (item?.dateString)!) }
                    
                    enterDoStuff(true)
                    
                    // sort and calc indicators
                    self.sortedPrices = self.sortPrices(arrayToSort: self.lastPrice)
                    self.averageOf(period: 10, debug: false)
                    self.averageOf(period: 200, debug: false)
                    self.williamsPctR()
                    
                case .failure(let error):
                    debugPrint(error)
                }
        }
    }
    
    func sortPrices(arrayToSort: [LastPrice])-> [LastPrice] {
        
        return arrayToSort.sorted(by: { $0.date?.compare($1.date!) == .orderedAscending })
    }
    
    func averageOf(period:Int, debug: Bool){
        
        var closes = [Double]()
        
        for eachClose in sortedPrices {
            closes.append(eachClose.close!)
        }
        
        var sum:Double
        var tenPeriodArray = [Double]()
        var averages = [Double]()
        for close in closes {
            tenPeriodArray.append(close)
            if tenPeriodArray.count > period {
                tenPeriodArray.remove(at: 0)
                sum = tenPeriodArray.reduce(0, +)
                let average = sum / Double(period)
                averages.append(average)
            } else {
                averages.append(close)
            }
        }
        
        if ( period == 10 ) {
            if ( debug ) { print("10 SMA--------------------------------------") }
            for (index, eachAverage) in averages.enumerated() {
                sortedPrices[index].movAvg10 = eachAverage
                if ( debug ) {print("\(sortedPrices[index].close!) \(eachAverage)") }
            }
        } else {
            if ( debug ) { print("200 SMA--------------------------------------") }
            for (index, eachAverage) in averages.enumerated() {
                sortedPrices[index].movAvg200 = eachAverage
                if ( debug ) { print("\(sortedPrices[index].close!) \(eachAverage)") }
            }
        }
    }
    
    func williamsPctR() {
        // %R = (Highest High – Closing Price) / (Highest High – Lowest Low) x -100
        
        // need to find HH + LL of last N periods
        var highs = [Double]()
        var lows = [Double]()
        var highestHigh = [Double]()
        var lowestLow = [Double]()
        for each in sortedPrices {
            highs.append(each.high!)
            lows.append(each.low!)
        }
        
        // max high of last 10
        var highArray = [Double]()
        for high in highs {
            highArray.append(high)
            if highArray.count > 10 {
                highArray.remove(at: 0)
            }
            highestHigh.append(highArray.max()!)
        }
        
        // min low of last 10
        var lowArray = [Double]()
        for low in lows {
            lowArray.append(low)
            if lowArray.count > 10 {
                lowArray.remove(at: 0)
            }
            lowestLow.append(lowArray.min()!)
        }
        
        //(Highest High – Closing Price)
        var leftSideEquation = [Double]()
        for ( index, each ) in sortedPrices.enumerated() {
            let answer = highestHigh[index] - each.close!
            leftSideEquation.append(answer)
        }
        
        //(Highest High – Lowest Low)
        var rightSideEquation = [Double]()
        for ( index, eachLow ) in lowestLow.enumerated() {
            let answer = highestHigh[index] - eachLow
            rightSideEquation.append(answer)
        }
        
        // divide then multiply answer
        for ( index, each ) in sortedPrices.enumerated() {
            var answer = leftSideEquation[index] / rightSideEquation[index]
            answer = answer * -100
            each.wPctR = answer
            
            print("%R \(answer) = (Highest High – Closing Price) \(leftSideEquation[index]) / (Highest High – Lowest Low) \( rightSideEquation[index]) x -100")
        }
        
    }
}
































