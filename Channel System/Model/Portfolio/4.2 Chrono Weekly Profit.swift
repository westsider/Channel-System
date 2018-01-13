//
//  4.2 Chrono Weekly Profit.swift
//  Channel System
//
//  Created by Warren Hansen on 1/6/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PortfolioWeekly {
    // get cumulative daily profit save weekly cumulative profit to realm
    func weeklyProfit(debug: Bool, completion:  (_ result:Bool) ->Void) {
        
        //let portfolioDaily = PortfolioDaily()
        let cumProfit = PortfolioDaily().dailyProfit(debug: debug)
        print("inside weeklyProfit() here is cum profit")
        //debugPrint(cumProfit)
        //var cumProfitWeelky: [(date: Date, profit: Double, cost:Double)] = []
        // delete old stas in realm
        let realm = try! Realm()
        let oldData = realm.objects(WklyStats.self)
        try! realm.write {
            realm.delete(oldData)
        }
        print("deleted weelky profit")
        var counter = 0
        let maxCount = cumProfit.count
        
        for today in cumProfit.enumerated() {
            print("Looping through cumProfit \(today.element.date) \(today.element.profit)")
            // if today is friday
            if isFriday(date: today.element.date, debug: true) && today.element.date <= Date() { // not finding any fridays
                print("Hello Friday")
                WklyStats().updateCumulativeProfit(date: today.element.date, ticker: "N/A", profit: today.element.profit, cost: today.element.cost, maxCost: 1.0 ) //portfolioDaily.maxCosts
                print("Adding \(today.element.date) $\(today.element.profit) to realm")
            }
            
            counter += 1
            if counter == maxCount {
                completion(true)
            }
        }
    }
    

    func isFriday(date:Date, debug:Bool) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: date as Date)
        if debug { print("checking date \(date) for weekday num \(String(describing: components.weekday!))") }
        if components.weekday! == 5 {
            if debug { print("found a friday!") }
            return true
        } else {
            return false
        }
    }
}
