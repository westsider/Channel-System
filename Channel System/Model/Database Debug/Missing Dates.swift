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
        
        let pagesFromSPY = PageInfo.pagesForSpy() // [(Int, Date, Date)]
        // loop through dates
        var pagesMissing:[Int] = []
        for dateToCheck in dates {
            // if date is bettween a tuble of dates then add the tuple page num
            for tupleToCheck in pagesFromSPY {
                if (tupleToCheck.1 ... tupleToCheck.2 ).contains(dateToCheck) {
                    pagesMissing.append(tupleToCheck.0)
                }
            }
        }
        
        // remove page zero because its duplicated in 1
        let removePageZero = pagesMissing.filter { $0 != 0 }
        // remove duplicate page nums
        let duplicatesRemoved = Array(Set(removePageZero))
        return duplicatesRemoved.sorted()
    }
    
    class func getMissingPagesFor(ticker:String, pages:[Int]) {
    
    }
}
