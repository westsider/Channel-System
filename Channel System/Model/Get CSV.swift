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
                lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
                
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
                
                prices.append(lastPriceObject)
            }
            return prices
        }
        return getCsvData
    }
    
//    func getCsvData(ticker: String, debug: Bool)-> [LastPrice]  {
//
//        var prices = [LastPrice]()
//
//        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
//        let stream = InputStream(fileAtPath: filleURLProject!)!
//        let csv = try! CSVReader(stream: stream)
//        //"date","close","volume","open","high","low"
//        while let row = csv.next() {
//            if ( debug ) { print("\(row)") }
//            let lastPriceObject = LastPrice()
//
//            lastPriceObject.ticker = ticker
//
//            let date = row[0]
//            lastPriceObject.dateString = date
//            lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
//
//            if let open = Double(row[3]) {
//                lastPriceObject.open = open }
//
//            if let high = Double(row[4]){
//                lastPriceObject.high = high }
//
//            if let low = Double(row[4]){
//                lastPriceObject.low = low }
//
//            if let close = Double(row[1]){
//                lastPriceObject.close = close }
//
//            if let volume = Double(row[2]){
//                lastPriceObject.volume = volume }
//
//            prices.append(lastPriceObject)
//        }
//        return prices
//    }
}