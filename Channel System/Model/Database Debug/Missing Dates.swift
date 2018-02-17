//
//  Missing Dates.swift
//  Channel System
//
//  Created by Warren Hansen on 2/16/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class MissingDates {
    
    class func inThis(ticker:String)-> Set<Date> {
        // get all dates in SPY
        let spyTicker = Prices().sortOneTicker(ticker: "SPY", debug: false)
        var spyDateArray:[Date] = []
        for each in spyTicker {
            spyDateArray.append(each.date!)
        }
        // get all dates in ticker
        let oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false)
        var tickerDateArray:[Date] = []
        for each in oneTicker {
            tickerDateArray.append(each.date!)
        }
        // make an array of dates ticker is missing
        //var difference = spyDateArray
        
        let filtered = Set(spyDateArray).subtracting(tickerDateArray)
        // IJH is missing 298 dates
        return filtered
    }
    
    class func whatPagesFor(dates:Set<Date> )-> [Int] {
        return [0,1]
    }
    
    class func getMissingPagesFor(ticker:String, pages:[Int]) {
    
    }
}
