//
//  Maintenence.swift
//  Channel System
//
//  Created by Warren Hansen on 12/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class Mainenence {

    func missingDates(ticker:String) {
        let weekDateArray = Mainenence().allWeekDays(debug: false)
        let startDate = Utilities().convertToDateFrom(string: "2017/10/01", debug: false)
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        var counter:Int = 0
        var noMatchArray = [ticker]
        for each in prices {
            if each.date! >= startDate {
                if counter < weekDateArray.count && weekDateArray[counter] != each.date {
                    noMatchArray.append(each.dateString)
                }
                counter += 1
            }
        }
        print(noMatchArray)
    }
    
    func allWeekDays(debug:Bool)-> [Date] {
        var dateArray = [Date]()
        let startDate = Utilities().convertToDateFrom(string: "2017/10/01", debug: false)  //"yyyy/MM/dd"
        var date = startDate // first date
        let endDate = Date() // last date
        let calendar = NSCalendar.current
        // Formatter for printing the date, adjust it according to your needs:
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        while date <= endDate {
            let isWeekend = isWeekday(date: date)
            let isHoliday = isHolliday(date: date)
            if !isWeekend && !isHoliday{
                if debug { print(fmt.string(from: date), isWeekend) }
                dateArray.append(date)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return dateArray
    }
    
    func isWeekday(date:Date)->Bool {
        let calendar = NSCalendar.current
        return calendar.isDateInWeekend(date)
    }
    
    func isHolliday(date:Date)->Bool {
        let hollidayArray = ["2017/7/04","2017/09/04","2017/11/23","2017/12/25"]
        var answer:Bool = false
        for each in hollidayArray {
            let dateToCheck = Utilities().convertToDateFrom(string: each, debug: false)
            if date == dateToCheck {
                answer = true
                break
            }
        }
        return answer
    }
}












