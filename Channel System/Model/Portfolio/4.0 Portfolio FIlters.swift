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
    [ ] apply mc
    [ ] apply stars
    [X] chart
    [ ] limit num pos
    [ ] find big dip
    */
class PortfolioFilters {
    
    struct OneTrade {
        var ticker:String
        var date: Date
        var profit:Double
        var capitalRequired:Double
        var cumulative:Double
        var cumulativeCost:Double
    }
    
    // what does this return for the chart?
    func of(mc:Bool, stars:Bool, numPositions:Int)-> [OneTrade] {

        var portfolio:[OneTrade] = []
        //WklyStats().getWeeklyStatsFromRealm()
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "date", ascending: true)
        var cumulatveSum:Double = 0.0
        var cumulativeCost:Double = 0.0
        if sortedByDate.count >  1 {
            let results = sortedByDate
            for each in results {
                cumulatveSum += each.profit
                let date = Utilities().convertToStringNoTimeFrom(date: each.date!)
                let profit = Utilities().dollarStr(largeNumber: each.profit)
                let capReq = Utilities().dollarStr(largeNumber: each.cost)
                let cumulative = Utilities().dollarStr(largeNumber: cumulatveSum)
                print("\(date)\t\(each.ticker)\t\(profit)\t\(capReq)\t\t\(cumulative)")
                
                let oneTrade = OneTrade(ticker: each.ticker, date: each.date!, profit: each.profit, capitalRequired: each.cost, cumulative: cumulatveSum, cumulativeCost: 0.0)
                portfolio.append(oneTrade)
                
            }
        }
        return portfolio
    }
    
    
    
    
}
