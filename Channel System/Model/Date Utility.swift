//
//  Date Utility.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    let formatter = DateFormatter()
    let today = Date()
    
    func convertToDateFrom(string: String, debug: Bool)-> Date {
        if ( debug ) { print("\n0. date from server as string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "yyyy/MM/dd"
        let date:Date = formatter.date(from: dateS)!
        if ( debug ) { print("Convertion to Date: \(date)\n") }
        return date
    }
    
    func convertToStringFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    func convertToStringNoTimeFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    // convert UTC to local
    func convertUTCtoLocal(debug: Bool, UTC: Date)-> Date {
        if ( debug ) { print("convertUTCtoLocal\nUTC:       \(today)") }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        let todayString = formatter.string(from: Date())
        if ( debug ) { print("Local str: \(todayString)") }
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let local = formatter.date(from: todayString)
        if ( debug ) { print("local date \(local!)") }
        return local!
    }
    
    func closeTradeIn(days: Int)-> Date {
        let daysFromNow: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: days, to: Date(), options: [])!
        return daysFromNow
    }
    
    func lastUpdateWasToday(debug: Bool)-> (Bool, Date ) {
        let calendar = NSCalendar.current
        let lastUpdate = Prices().getLastDateInRealm(debug: false)
        if ( debug) { print("The last update was \(lastUpdate)") }
        if ( debug ) { print("today \(today) lastUpdate \(lastUpdate)") }
        if (calendar.isDateInToday(lastUpdate)) {
            return ( true, lastUpdate )
        } else { return ( false, lastUpdate )}
    }

    func wasLastPrint(close: [Int], lastUpdate: Date, debug: Bool ) -> Bool {
        let calendar = Calendar.current
        var isMakretHours:Bool
        let end_today = calendar.date(
            bySettingHour: close[0],
            minute: close[1],
            second: 0,
            of: today)!
        if ( debug ) { print("End Today: \(end_today)") }
        if ( lastUpdate >= end_today ) {
            if ( debug ) { print("The time is after \(close[0]):\(close[1])") }
            isMakretHours = true
            if ( debug ) { isMakretHours = true }
        } else {
            if ( debug ) { print("The time is before  \(close[0]):\(close[1])") }
            isMakretHours = false
        }
        return isMakretHours
    }
    
    func calcuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func realmNotCurrent(debug: Bool)-> Bool {
        let lastUpdateToday = lastUpdateWasToday(debug: debug)
        let yesLastPrint = wasLastPrint(close: [0,0], lastUpdate: lastUpdateToday.1, debug: debug)
        if ( debug ) { print("lastUpdateToday: \(lastUpdateToday.0) \(lastUpdateToday.1) yesLastPrint: \(yesLastPrint)") }
        if(lastUpdateToday.0 && yesLastPrint) {
            print("\nrealm is current!\n")
            return false
        } else {
            print("\nrealm is NOT current!\n")
            return true
        }
    }
    
    func isMarketHours(begin: [Int], end: [Int] ) -> Bool  {
        var isMakretHours: Bool
        let calendar = Calendar.current
        
        let start_today = calendar.date(
            bySettingHour: begin[0],
            minute: begin[1],
            second: 0,
            of: today)!
        
        let end_today = calendar.date(
            bySettingHour: end[0],
            minute: end[1],
            second: 0,
            of: today)!
        
        if (today >= start_today && today <= end_today ) {
            print("The time is between \(begin[0]):\(begin[1]) and \(end[0]):\(end[1])")
            isMakretHours = true
        } else {
            print("The time is outside of \(begin[0]):\(begin[1]) and \(end[0]):\(end[1])")
            isMakretHours = false
        }
        return isMakretHours
    }
    
    func dollarStr(largeNumber:Double )->String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:Int(largeNumber)))!
    }

    func decimalStr(input:Double, Decimals:Int)->String {
        return String(format: "%.\(Decimals)f", input)
    }
}
