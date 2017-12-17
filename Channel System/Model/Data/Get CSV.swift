//
//  Get CSV.swift
//  Channel System
//
//  Created by Warren Hansen on 11/15/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import CSV

class GetCSV {
    
    func load(fromCSV ticker: String, debug: Bool) -> () -> [LastPrice]  {
        
        if ( debug ) { print("\nLoading \(ticker) From CSV\n")}
        func getCsvData()-> [LastPrice]  {
            
            var prices = [LastPrice]()
            let test  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false)
            let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
            let stream = InputStream(fileAtPath: filleURLProject!)!
            let csv = try! CSVReader(stream: stream)
            //"date","close","volume","open","high","low"
            while let row = csv.next() {
                //if ( debug ) { print("\(row)") }
                let lastPriceObject = LastPrice()
                
                lastPriceObject.ticker = ticker
                
                let date = row[0]
                lastPriceObject.dateString = date
                lastPriceObject.date = Utilities().convertToDateFrom(string: date, debug: false)
                
                if let open = Double(row[3]) {
                    lastPriceObject.open = open }
                
                if let high = Double(row[4]){
                    lastPriceObject.high = high }
                
                if let low = Double(row[4]){
                    lastPriceObject.low = low }
                
                if let close = Double(row[1]){
                    lastPriceObject.close = close }
                
                if let volume = Double(row[2]){
                    lastPriceObject.volume = volume }
                // save only days after 2014/11/25
                if (test < lastPriceObject.date!) {
                    prices.append(lastPriceObject)
                }
            }
            return prices
        }
        return getCsvData
    }
    
    func areTickersValid(megaSymbols: [String]) {
        var counter = 0
        let bundle = Bundle(for: ScanViewController.self)
        let fileManager : FileManager   = FileManager.default
        
        for symbol in megaSymbols {
            //print("\(symbol)")
            if let filePath = bundle.path(forResource: symbol, ofType: "csv") {
                if fileManager.fileExists(atPath: filePath) {
                    // print("\(symbol) found")
                }
            } else {
                counter += 1
                print("\(symbol) not found #\(counter)")
            }
        }
        print("All symbols found in csv database.")
    }
    
    func removeEarlyDates(ticker:String) {
        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
        let stream = InputStream(fileAtPath: filleURLProject!)!
        let csv = try! CSVReader(stream: stream)
        //"date","close","volume","open","high","low"
        while let row = csv.next() {
            //if ( debug ) { print("\(row)") }
            let lastPriceObject = LastPrice()
            
            lastPriceObject.ticker = ticker
            print("Loaded ticker \(ticker)")
            let date = row[0]
            lastPriceObject.dateString = date
            let dateInRow  = Utilities().convertToDateFrom(string: date, debug: false)
            let test  = Utilities().convertToDateFrom(string: "2014/11/25", debug: false) // "yyyy/MM/dd" 2014-11-25
            if (test > dateInRow) {
                print("\n-----> Found Early date for \(ticker) on \(date)\n")
                
               // MARK:- TODO - delete this row from csv
            }
        }
    }
}
