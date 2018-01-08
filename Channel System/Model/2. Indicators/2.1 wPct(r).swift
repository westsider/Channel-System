//
//  2.1 wPct(r).swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PctR {
    
    func getwPctR(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {
//        var galaxie = SymbolLists().allSymbols
//        if tenOnly {
//            galaxie = SymbolLists().uniqueElementsFrom(testSet: tenOnly, of: 20); print("1.0 Galaxie Complete")
//        } 
        var counter = 0
        let total = galaxie.count
        var done:Bool = false
        for  symbols in galaxie {
            DispatchQueue.global(qos: .background).async {
                done = false
                let oneTicker = Prices().sortOneTicker(ticker: symbols, debug: false)
                done = self.williamsPctR(debug: false, prices: oneTicker, redoAll: false)
                if done {
                    DispatchQueue.main.async {
                        counter += 1
                        print("oscilator \(counter) of \(total)")
                        if counter == total {
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func williamsPctR(debug: Bool, prices: Results<Prices>, redoAll: Bool)->Bool {
        // %R = (Highest High – Closing Price) / (Highest High – Lowest Low) x -100
        let sortedPrices = prices
        // need to find HH + LL of last N periods
        var highs = [Double]()
        var lows = [Double]()
        var highestHigh = [Double]()
        var lowestLow = [Double]()
        for each in sortedPrices {
            highs.append(each.high)
            lows.append(each.low)
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
            let answer = highestHigh[index] - each.close
            leftSideEquation.append(answer)
        }
        
        //(Highest High – Lowest Low)
        var rightSideEquation = [Double]()
        for ( index, eachLow ) in lowestLow.enumerated() {
            let answer = highestHigh[index] - eachLow
            rightSideEquation.append(answer)
        }
        
        // divide then multiply answer
        for ( index, _ ) in sortedPrices.enumerated() {
            var answer = leftSideEquation[index] / rightSideEquation[index]
            answer = answer * -100
            
            if ( answer > 300 || answer < -300) {
                print("\n----------> \(answer) is suspicious!\n")
                answer = 0.01
            }
            if ( redoAll) {
                if ( debug ) { print("adding wPctR  \(answer) to \(sortedPrices[index].ticker)") }
                let realm = try! Realm()
                try! realm.write {
                    sortedPrices[index].wPctR = answer
                }
            } else if ( sortedPrices[index].wPctR == 0.0 ) {
                if ( debug ) { print("adding wPctR  \(answer) to \(sortedPrices[index].ticker)") }
                let realm = try! Realm()
                try! realm.write {
                    sortedPrices[index].wPctR = answer
                }
            }
            //print("%R \(answer) = (Highest High – Closing Price) \(leftSideEquation[index]) / (Highest High – Lowest Low) \( rightSideEquation[index]) x -100")
        }
        if ( debug ) { print("\nFinished calc for wPctR for \(String(describing: prices.last!.ticker))\n") }
        return true
    }
}

