//
//  4.1 Chrono Daily Profit.swift
//  Channel System
//
//  Created by Warren Hansen on 1/6/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class PortfolioDaily {
    var maxCosts = Double()
    // get master: [(date: Date, profit: Double)] ->  cumulative daily profit
    func dailyProfit(debug: Bool)-> [(date: Date, profit: Double, cost:Double, positions: Int)]  {
        print("inside dailyProfit()")
        let master = PortfolioEntries().allTickerBacktestWithCost(debug: debug, saveToRealm: true)
        
        //print("--> debugPrint of master from allTickerBacktestWithCost <--"); debugPrint(master)
        var cumProfit = master
        var runOfProfit = Double()
        
        
        for (index, today) in master.enumerated() {
            runOfProfit += today.profit
            cumProfit[index].profit = runOfProfit
            cumProfit[index].cost = today.cost
            if today.cost > maxCosts {
                maxCosts = today.cost
            }
        }
        
        if debug {
            for today in cumProfit {
                if today.profit != 0.00 {
                    print(today.date, "profit ", Utilities().dollarStr(largeNumber: today.profit),"\tcost ", Utilities().dollarStr(largeNumber: today.cost),"\tmax ", Utilities().dollarStr(largeNumber: maxCosts), "\tPositions: ", today.positions)
                }
            }
        }
        
        return cumProfit
    }
}
