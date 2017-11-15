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
    var longEntry:Bool?
}

class DataFeed {
    
    var lastPrice = [LastPrice]()
    
    var sortedPrices = [LastPrice]()
    
    var allSortedPrices = [[LastPrice]]()
    
    var symbolArray = [String]()
    
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
                            self.sortPrices(arrayToSort: self.lastPrice)
                            
                            doneWork(true)
                        }
                        rowCounter = 0
                    case .failure(let error):
                        debugPrint(error)
                    }
            }
         }
        
      }
    
    func getCsvData(ticker: String, debug: Bool, doneWork: @escaping (Bool) -> Void ) {
        
        doneWork(false)
        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
        let stream = InputStream(fileAtPath: filleURLProject!)!
        let csv = try! CSVReader(stream: stream)
        //"date","close","volume","open","high","low"
        while let row = csv.next() {
            if ( debug ) { print("\(row)") }
            let lastPriceObject = LastPrice()
            
            lastPriceObject.ticker = ticker
            
            let date = row[0]
                lastPriceObject.dateString = date
                lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
            
            if let open = Double(row[3]) {
                lastPriceObject.open = open }
            
            if let high = Double(row[4]){
                lastPriceObject.high = high }
            
            if let low = Double(row[4]){
                lastPriceObject.low = low }
            
            if let close = Double(row[1]){
                lastPriceObject.close = close }
            
            self.lastPrice.append(lastPriceObject)
        }
        self.sortPrices(arrayToSort: self.lastPrice)
        doneWork(true)
        
        // need to separate symbols
    }
    
    func separateSymbols(debug: Bool) {
 
        var fullSymbolDataSet = [LastPrice]()
        
        for each in sortedPrices {
            if ( !symbolArray.contains(each.ticker!)) {
                symbolArray.append(each.ticker!)
            }
        }
        
        for symbol in symbolArray {
            if ( debug ) {print("\nFound \(symbol) in array!") }
            let foundItems = sortedPrices.filter { $0.ticker == symbol }
            for each in foundItems {
                if ( debug ) { print("\(each.ticker!) \(each.dateString!)") }
                fullSymbolDataSet.append(each)
            }
            allSortedPrices.append(fullSymbolDataSet)
            fullSymbolDataSet.removeAll()
        }
    }
    
    func calcIndicators() {
            self.averageOf(period: 10, debug: true)
            self.averageOf(period: 200, debug: false)
            self.williamsPctR(debug: false)
            self.checkForLongEntry(debug: true)
    }
    
    func returnSortedSymbol()-> [LastPrice]{
        print("returnSortedSymbol")
        return self.sortedPrices
    }
    
    func printThis(priceSeries: [LastPrice]) {
        print("\nprintThis")
        for item in priceSeries {
            print("\(item.ticker!) \(item.date!)")
        }
    }
    func sortPrices(arrayToSort: [LastPrice]) {
        sortedPrices = arrayToSort.sorted(by: { $0.date?.compare($1.date!) == .orderedAscending })
    }
    
    func checkForLongEntry(debug: Bool) {
        
        for (mainindex, symbolFile) in allSortedPrices.enumerated() {
            for (index, each) in symbolFile.enumerated() {
                if ( each.close! < each.movAvg10! && each.close! > each.movAvg200! && each.wPctR! < -80 ) {
                    allSortedPrices[mainindex][index].longEntry = true
                    if ( debug ) { print("LE on \(allSortedPrices[mainindex][index].date!)") }
                }
            }
        }
    }
    
    func averageOf(period:Int, debug: Bool){
        
        var closes = [Double]()
        
        for (mainindex, symbolFile) in allSortedPrices.enumerated() {
            closes.removeAll()
            for eachClose in symbolFile {
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
                    
                    print("index is \(index) count is \(averages.count)")
                    allSortedPrices[mainindex][index].movAvg10 = eachAverage
                    if ( debug ) {print("\(allSortedPrices[mainindex][index].close!) \(eachAverage)") }
                }
            } else {
                if ( debug ) { print("200 SMA--------------------------------------") }
                for (index, eachAverage) in averages.enumerated() {
                    allSortedPrices[mainindex][index].movAvg200 = eachAverage
                    if ( debug ) { print("\(allSortedPrices[mainindex][index].close!) \(eachAverage)") }
                }
            }
        }
    }
    
    func williamsPctR(debug: Bool) {
        // %R = (Highest High – Closing Price) / (Highest High – Lowest Low) x -100
        for (mainindex, symbolFile) in allSortedPrices.enumerated() {
            
            var highs = [Double]()
            var lows = [Double]()
            var highestHigh = [Double]()
            var lowestLow = [Double]()
            var wPctR = [Double]()
            highs.removeAll()
            lows.removeAll()
            highestHigh.removeAll()
            lowestLow.removeAll()
            wPctR.removeAll()
            // need to find HH + LL of last N periods
            for each in symbolFile {
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
            for ( index, each ) in symbolFile.enumerated() {
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
            for (index, _) in symbolFile.enumerated() {
                var answer = leftSideEquation[index] / rightSideEquation[index]
                answer = answer * -100
                wPctR.append(answer)
                if ( debug ) { print("%R \(answer) = (Highest High – Closing Price) \(leftSideEquation[index]) / (Highest High – Lowest Low) \( rightSideEquation[index]) x -100") }
            }
            
            // add values to main price object
            for ( index, eachWpctR ) in wPctR.enumerated() {
                allSortedPrices[mainindex][index].wPctR = eachWpctR
            }
        }
    }
    
    func debugAllSortedPrices(on: Bool) {
        if ( !on ) { return }
        print("All Sorted prices loaded from Scan VC. Total symbols: \(allSortedPrices.count)\n")
        for symbols in allSortedPrices {

            let ticker = symbols.first?.ticker

            print("Currently listing prices for \(ticker!) Sorted prices loaded from Scan VC. Total days: \(symbols.count)\n")
            for prices in symbols {
                print("\(prices.dateString!) \t\(prices.ticker!)\to:\(String(format: "%.2f", prices.open!))\th:\(String(format: "%.2f", prices.high!))\tl:\(String(format: "%.2f", prices.low!))\tc:\(String(format: "%.2f", prices.close!)) 10:\(String(format: "%.2f", prices.movAvg10!))")
            }
        }
    }
}
