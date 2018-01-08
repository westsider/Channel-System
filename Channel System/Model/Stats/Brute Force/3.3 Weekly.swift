//
//  3.3 Weekly.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class CumulativeProfit {
    
    //////////////////////////////////////////////////////////////////
    //                            TESTS                             //
    //////////////////////////////////////////////////////////////////
    // allTickerBacktestWithCost -> daily -> weekly

//    func testBacktestWithCost() {
//        let cumProfit = allTickerBacktestWithCost(debug: true, saveToRealm: true)
////        var totals:[Double] = [0.0]
////        if debug {
////            for today in cumProfit {
////                if today.profit != 0.00 {
////                    totals.append(results.grossProfit)
////                    print(today.date, "profit ", Utilities().dollarStr(largeNumber: today.profit),"\tcost ", Utilities().dollarStr(largeNumber: today.cost),"\tmax ", Utilities().dollarStr(largeNumber: maxCosts), "\tPositions: ", today.positions)
////                }
////            }
////        }
//    }
   
    
//    func testSumDailyProfit(debug:Bool) {
//        let cumProfit = PortfolioDaily().dailyProfit(debug: debug)
//        if debug {
//            for today in cumProfit {
//                if today.profit != 0.00 {
//                    print(today.date, "profit ", Utilities().dollarStr(largeNumber: today.profit),"\tcost ", Utilities().dollarStr(largeNumber: today.cost),"\tmax ", Utilities().dollarStr(largeNumber: maxCosts), "\tPositions: ", today.positions)
//                }
//            }
//        }
//    }
//    //MARK: - 1.0 testWeeklyProfit TEST
//    func testWeeklyProfit() {
//        PortfolioWeekly().weeklyProfit(debug: true, completion: { (finished) in
//            if finished {
//                print("completed weekly profit")
//            }
//        })
//    }
    
    //////////////////////////////////////////////////////////////////
    //                          METHODS                             //
    //////////////////////////////////////////////////////////////////
//    var maxCosts:Double = 0.00
//    let backtestBlock = { print( "Backtest Complete" ) }
    
//    //MARK: - Backtest call form Scan VC
//    func backtestDailyWeekly(debug:Bool, completion: @escaping (Bool) -> Void) {
//        print("inside backtestStarsAndWeekly()")
//        var done:Bool = false
//        DispatchQueue.global(qos: .background).async {
//            done = false
//            self.weeklyProfit(debug: true, completion: { (finished) in
//                if finished {
//                done = true
//                }
//            })
//            if done {
//                DispatchQueue.main.async {
//                    completion(true)
//                }
//            }
//        }
//    }
    

    

    
//    // get master: [(date: Date, profit: Double)] ->  cumulative daily profit
//    func dailyProfit(debug: Bool)-> [(date: Date, profit: Double, cost:Double, positions: Int)]  {
//        print("inside dailyProfit()")
//        let master = PortfolioEntries().allTickerBacktestWithCost(debug: debug, saveToRealm: true)
//        
//        print("--> debugPrint of master from allTickerBacktestWithCost <--")
//        //debugPrint(master)
//        var cumProfit = master
//        var runOfProfit = Double()
//        
//        for (index, today) in master.enumerated() {
//            runOfProfit += today.profit
//            cumProfit[index].profit = runOfProfit
//            cumProfit[index].cost = today.cost
//            if today.cost > maxCosts {
//                maxCosts = today.cost
//            }
//        }
//        
//        if debug {
//            for today in cumProfit {
//                if today.profit != 0.00 {
//                    print(today.date, "profit ", Utilities().dollarStr(largeNumber: today.profit),"\tcost ", Utilities().dollarStr(largeNumber: today.cost),"\tmax ", Utilities().dollarStr(largeNumber: maxCosts), "\tPositions: ", today.positions)
//                }
//            }
//        }
//        
//        return cumProfit
//    }
  

}
