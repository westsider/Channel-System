//
//  4.0 Portfolio FIlters.swift
//  Channel System
//
//  Created by Warren Hansen on 1/12/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

    /*
    [X] chart
    [X] cumulative cost
    [ ] calc stats
    [ ] limit num pos
    [ ] apply mc
    [ ] apply stars
    [ ] find big dip
    [ ] remove commisions
    */
class PortfolioFilters {
    
    struct OneTrade {
        var ticker:String
        var date: Date
        var profit:Double
        var capitalRequired:Double
        var cumulative:Double
        var cumulativeCost:Double
        var winPct:Double = 0.0
    }
    
    // what does this return for the chart?
    func of(mc:Bool, stars:Bool, numPositions:Int)-> [OneTrade] {

        var portfolio:[OneTrade] = []
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "entryDate", ascending: true)
        var cumulatveSum:Double = 0.0
        var cumulativeCost:Double = 0.0
        var positionCount:Int = 0
        var lastDate:Date = Date()
        var winCount:Int = 0
        var tradeCount:Int = 0
        var winPct:Double = 0.0
        
        if sortedByDate.count >  1 {
            let results = sortedByDate
            for each in results {
                // num positions sold / day to estimate holding cost. needs to be more accurate
                if each.date == lastDate {
                    positionCount += 1
                    cumulativeCost = Double( positionCount ) * each.cost
                } else {
                    positionCount  = 0
                }
                
                tradeCount += 1
                cumulatveSum += each.profit
                let date = Utilities().convertToStringNoTimeFrom(date: each.date!)
                let profit = Utilities().dollarStr(largeNumber: each.profit)
                if each.profit >= 0 {
                    winCount += 1
                }
                winPct = ( Double( winCount ) / Double( tradeCount ) ) * 100.0
                let capReq = Utilities().dollarStr(largeNumber: each.cost)
                let cumulative = Utilities().dollarStr(largeNumber: cumulatveSum)
                print("\(date)\t\(each.ticker)\t\(profit)\t\(capReq)\t\t\(cumulative)")
                
                let oneTrade = OneTrade(ticker: each.ticker, date: each.date!, profit: each.profit, capitalRequired: each.cost, cumulative: cumulatveSum, cumulativeCost: cumulativeCost, winPct: winPct)
                portfolio.append(oneTrade)
                lastDate = each.date!
            }
        }
        print("\n\(String(format: "%.2f", winPct))% Win\n")
        
        return portfolio
    }
    
    
    
    
}
