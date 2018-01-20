//
//  2.1 SMA 10, 200.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class SMA {

    func getData(galaxie: [String], debug:Bool, period:Int, completion: @escaping (Bool) -> Void) {
        var counter = 0
        let total = galaxie.count
        var done:Bool = false
        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                done = false
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                done = self.averageOf(period: period, debug: debug, prices: oneTicker, redoAll: false)
                if done {
                    DispatchQueue.main.async {
                        counter += 1
                        print("sma\(period) \(counter) of \(total)") 
                        if counter == total {
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func averageOf(period:Int, debug: Bool, prices: Results<Prices>, redoAll: Bool)->Bool {
        let sortedPrices = prices
        var closes = [Double]()
        for eachClose in sortedPrices {
            closes.append(eachClose.close)
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
        if ( debug ) { print("\nFinished calc for\(period) SMA for \(String(describing: sortedPrices.last!.ticker))\n") }
        if ( period == 10 ) {
            if ( debug ) { print("\n---> num of 10 SMA \(averages.count) closes = \(closes.count) <---\n") }
            let realm = try! Realm()
            try! realm.write {
                for (index, eachAverage) in averages.enumerated() {
                    // add indicator if none exists
                    
                    if ( redoAll ) {
                        if ( debug ) { print("adding SMA 10 \(eachAverage) to \(sortedPrices[index].ticker)") }
    //                    let realm = try! Realm()
    //                    try! realm.write {
                            sortedPrices[index].movAvg10 = eachAverage
                        //}
                    } else if ( sortedPrices[index].movAvg10 == 0.0 ) {
                        if ( debug ) { print("adding SMA 10 \(eachAverage) to \(sortedPrices[index].ticker)") }
                        //let realm = try! Realm()
                        //try! realm.write {
                            sortedPrices[index].movAvg10 = eachAverage
                            if ( debug ) { print("SAVE \(sortedPrices[index].ticker) \(sortedPrices[index].dateString) \(sortedPrices[index].movAvg10)") }
                        //}
                    }
                    
                }
            }
            return true
        } else {
            
            let realm = try! Realm()
            try! realm.write {
                for (index, eachAverage) in averages.enumerated() {
                    
                    if ( redoAll ) {
                        if ( debug ) { print("adding SMA 200 \(eachAverage) to \(sortedPrices[index].ticker)") }
    //                    let realm = try! Realm()
    //                    try! realm.write {
                            sortedPrices[index].movAvg200 = eachAverage
                        //}
                    } else if ( sortedPrices[index].movAvg200 == 0.0 ) {
                        if ( debug ) { print("adding SMA 200 \(eachAverage) to \(sortedPrices[index].ticker)") }
                        //let realm = try! Realm()
                        //try! realm.write {
                            sortedPrices[index].movAvg200 = eachAverage
                        //}
                    }
                }
            }
            return true
        }
    }
}
    


