////
////  EntryAndExits.swift
////  Channel System
////
////  Created by Warren Hansen on 12/13/17.
////  Copyright © 2017 Warren Hansen. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//class EntryAndExit {
//    
//    /*
//     loop through tickers
//     find and make entry
//     disable entry
//     find and make exit
//     
//     
//     learned I have to make an entry and exit in the same func.. entry needs last exit finished before new entry
//     run the func below and test
//     */
//    
//    func doItAll(ticker:String, debug:Bool, updateRealm:Bool)->(Double, Double, Double, Double, Double) {
//        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
//        let realm = try! Realm()
//        var flat:Bool = true
//        var entryPrice:Double = 0.00
//        var tradeGain:Double = 0.00
//        var grossProfit:Double = 0.00
//        var daysInTrade:Int = 0
//        var tradeCount:Int = 0
//        var winCount:Int = 0
//        var shares:Double = 100.0
//        var stop:Double = 0.00
//        var winPct:Double = 0.00
//        var cost:Double = 0.00
//        var largestWin:Double = 0.0
//        var largestLoser:Double = 0.0
//        var allTrades = [Double]()
//        let currentRisk = Account().currentRisk()
//        for each in prices {
//            //MARK: - Entry
//            if ( flat && each.close < each.movAvg10 && each.close > each.movAvg200 && each.wPctR < -80 ) {
//                
//                try! realm.write {
//                    let stopDist = TradeHelpers().calcStopTarget(ticker: each.ticker, close: each.close, debug: false)
//                    shares = Double(TradeHelpers().calcShares(stopDist: stopDist.2, risk: currentRisk))
//                    each.longEntry = true
//                    each.shares = Int(shares)
//                    each.capitalReq = TradeHelpers().capitalRequired(close: each.close, shares: Int(shares))
//                    cost = each.capitalReq
//                    each.stop = stopDist.0
//                    stop = stopDist.0
//                    each.target = stopDist.1
//                    flat = false
//                    daysInTrade = 0
//                    tradeCount += 1
//                    entryPrice = each.close
//                    print("\nEntry \(tradeCount) found on \(each.dateString)")
//                }
//            }
//            //MARK: - target
//            if !flat {
//                // mark capital used to backtest cum profit
//                try! realm.write {
//                    each.capitalReq = cost
//                }
//                daysInTrade += 1
//                if each.wPctR > -30 {
//                    print("Target hit on \(each.dateString)")
//                    flat = true
//                    tradeGain = (each.close - entryPrice) * shares
//                    if updateRealm {
//                        let realm = try! Realm()
//                        try! realm.write {
//                            each.backTestProfit = tradeGain
//                        }
//                    }
//                    if  tradeGain > largestWin { largestWin = tradeGain }
//                    if debug { print("wPctR \(String(format: "%.1f", each.wPctR)) exit on \(each.dateString) Win \(String(format: "%.1f", tradeGain))")}
//                    allTrades.append(tradeGain)
//                }
//            }
//            //MARK: - time stop
//            if !flat {
//                if daysInTrade >= 7 {
//                    flat = true
//                    tradeGain = (each.close - entryPrice) * shares
//                    if updateRealm {
//                        let realm = try! Realm()
//                        try! realm.write {
//                            each.backTestProfit = tradeGain
//                        }
//                    }
//                    allTrades.append(tradeGain)
//                    if (( each.close - entryPrice ) >=  0 ) {
//                        if  tradeGain > largestWin { largestWin = tradeGain }
//                        if debug { print("Time stop on \(each.dateString) after \(daysInTrade) days with gain of \(String(format: "%.1f", tradeGain))") }
//                    } else {
//                        if debug { print("Time stop on \(each.dateString) after \(daysInTrade) days with loss of \(String(format: "%.1f", tradeGain))") }
//                    }
//                }
//            }
//            //MARK: - stop
//            if !flat && each.low <= stop {
//                flat = true
//                let thisLoss = ( each.low - entryPrice ) * shares
//                allTrades.append(thisLoss)
//                if  thisLoss < largestLoser { largestLoser = thisLoss }
//                if debug { print("Stop hit on \(each.dateString) Loss is \(String(format: "%.1f", thisLoss)) ") }
//                tradeGain = tradeGain + thisLoss
//                if updateRealm {
//                    let realm = try! Realm()
//                    try! realm.write {
//                        each.backTestProfit = tradeGain
//                    }
//                }
//
//            }
//            UserDefaults.standard.set(each.date, forKey: "StatsUpdate")
//        }
//        
//        //MARK: - stats
//        grossProfit = allTrades.reduce(0, +)
//        tradeCount = allTrades.count
//        for each in allTrades {
//            if each >= 0 {
//                winCount += 1
//            }
//        }
//        
//        winPct = (Double(winCount) / Double(tradeCount)) * 100
//        let winPctStr = String(format: "%.2f", winPct)
//        let roi = (grossProfit / cost) * 100
//        let annualRoi = roi / 3
//        let roiStr = String(format: "%.2f", roi)
//        if debug {
//            print("\n-----> Results <-----")
//            print("Wins \(winCount) Trades \(tradeCount)")
//            print("LW/LL \(String(format: "%.0f", largestWin))/\(String(format: "%.0f", largestLoser))")
//            print("\(winPctStr)% Wins \tRoi \(roiStr)%")
//            print("-----> \(grossProfit) <-----\n")
//        }
//        
//        return ( grossProfit,largestWin, largestLoser, annualRoi, winPct )
//    }
//}

