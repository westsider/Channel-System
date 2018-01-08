//
//  1.2 Get CSV Data.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import CSV

class CSVFeed {
    
    func getData(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
        //var galaxie = SymbolLists().allSymbols
//        if tenOnly {
//            galaxie = SymbolLists().uniqueElementsFrom(testSet: tenOnly, of: 20) ; print("1.0 Galaxie Complete")
//        } 
        var counter = 0
        let total = galaxie.count
        var done:Bool = false
        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                done = false
                done = self.getPricesFromCSV(ticker: symbols, debug: debug)
                if done {
                    DispatchQueue.main.async {
                        counter += 1
                        print("CSV \(counter) of \(total)")
                        if counter == total {
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func getPricesFromCSV(ticker: String,debug: Bool)->Bool {
        print("Getting CSV for \(ticker)")
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
            prices.date = Utilities().convertToDateFrom(string: date, debug: false)
            if let close = Double(row[1]){
                prices.close = close
                if (close == 0.00 ) { print("\n========================     Close was 0 for \(ticker)     ===========================\n") }
            }
            if let volume = Double(row[2]){
                prices.volume = volume
                if (volume == 0.00 ) { print("\n=======================     volume was 0 for \(ticker)     ===========================\n") }
            }
            if let open = Double(row[3]) {
                prices.open = open
                if (open == 0.00 ) { print("\n========================     open was 0 for \(ticker)     ===========================\n") }
            }
            if let high = Double(row[4]){
                prices.high = high
                if (high == 0.00 ) { print("\n========================     high was 0 for \(ticker)     ===========================\n") }
            }
            if let low = Double(row[5]){
                prices.low = low
                if (low == 0.00 ) { print("\n========================     low was 0 for \(ticker)     ===========================\n") }
            }
            
            if (prices.close != 0.00 && prices.open != 0.00  && prices.high != 0.00 && prices.low != 0.00 ) {
                RealmHelpers().saveSymbolsToRealm(each: prices)
            }
        }
        return true
    }
}
