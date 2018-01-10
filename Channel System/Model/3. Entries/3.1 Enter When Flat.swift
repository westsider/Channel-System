//
//  3.1 Enter When Flat.swift
//  Channel System
//
//  Created by Warren Hansen on 12/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

// 3.1 BackTest().bruteForceTradesForEach - entries only with exits

import Foundation
import RealmSwift

class BackTest {

    func testbruteForce(galaxie: [String]){
        var totalTickers:Int = 0
        var totals:[Double] = [0.0] //[(grossProfit:Double, largestWin:Double, largestLoser:Double, annualRoi:Double, winPct:Double) ] = [(0.0,0.0,0.0,0.0,0.0)]
        for ticker in galaxie {
            let master = enterWhenFlat(ticker: ticker, debug: true, updateRealm: true) // ( grossProfit,largestWin, largestLoser, annualRoi, winPct )
            totalTickers += 1
            totals.append(master.grossProfit)
        }
        let sum = totals.reduce(0, +)
        print("\n---------------------------------------\n\t\tSummary of Entry test\nTotal Tickers \(totalTickers)\nSum of all trades \(Utilities().dollarStr(largeNumber: sum))\n---------------------------------------\n")
        
    }
    /**
     - Author: Warren Hansen
     - Step 2 of 3 Complete backtest process
     -      Entry().getEntry()
     -      CalcStars().backTest() calls BackTest().bruteForceTradesForEach()
     -      weeklyProfit()  # the mess
     - loop though each Prices sorted by ticker
     - only enter when flat, record profit from each trade based on risk
     - return tuple aka master (grossProfit, largestWin, largestLoser, annualRoi, winPct)
     ### Declare As:
        let master = bruteForceTradesForEach(ticker: ticker, debug: true, updateRealm: true)
     */
    func enterWhenFlat(ticker: String, debug:Bool, updateRealm: Bool)->(grossProfit:Double, largestWin:Double, largestLoser:Double, annualRoi:Double, winPct:Double) {
    
        let prices = Prices().sortOneTicker(ticker: ticker, debug: false)
        
        var flat = true
        var entryPrice = 0.00
        var tradeGain = 0.00
        var grossProfit = 0.00
        var daysInTrade = 0
        var tradeCount = 0
        var winCount = 0
        var shares = 100.0
        var stop = 0.00
        var winPct = 0.00
        var cost = 0.00
        var largestWin = 0.0
        var largestLoser = 0.0
        var allTrades = [Double]()
        var currentRisk:Int = 0
        for each in prices {
            //MARK: - Entry
            if flat && each.longEntry {
                flat = false
                entryPrice = each.close
                daysInTrade = 0
                tradeCount += 1
                
                let stopDist = TradeHelpers().calcStopTarget(ticker: each.ticker, close: entryPrice, debug: false).2
                currentRisk = Account().currentRisk()
                shares = Double( TradeHelpers().calcShares(stopDist: stopDist, risk: currentRisk))
                stop = TradeHelpers().calcStopTarget(ticker: each.ticker, close: entryPrice, debug: false).0
                cost = TradeHelpers().capitalRequired(close: entryPrice, shares: Int(shares))
                if debug {
                    print("\(each.dateString)\tbought \(Int(shares)) shares of \(each.ticker) costing \(Utilities().dollarStr(largeNumber: cost)) Trade count \(tradeCount)")
                }
            }

            //MARK: - manage trade
            if !flat {
                daysInTrade += 1
                //MARK: - target
                if each.wPctR > -30 {
                    flat = true
                    tradeGain = (each.close - entryPrice) * shares
                    
                    if updateRealm {
                        let realm = try! Realm()
                        try! realm.write {
                            each.backTestProfit = tradeGain
                        }
                    }

                    if  tradeGain > largestWin { largestWin = tradeGain }
                    if debug {
                        print("\(each.dateString)\twPct(r) exit on \(each.ticker) with gain of \(String(format: "%.1f", tradeGain))") }
                    allTrades.append(tradeGain)

                }
                //MARK: - time stop
                if daysInTrade >= 7 {
                    flat = true
                    tradeGain = (each.close - entryPrice) * shares
                    //if debug { print("\nTime exit for \(each.ticker) with gain of \(tradeGain)") }
                    if updateRealm {
                        let realm = try! Realm()
                        try! realm.write {
                            each.backTestProfit = tradeGain
                        }
                    }

                    allTrades.append(tradeGain)
                    if (( each.close - entryPrice ) >=  0 ) {
                        if  tradeGain > largestWin { largestWin = tradeGain }
                        if debug { print("\(each.dateString)\tTime stop \(each.ticker) after \(daysInTrade) days with gain of \(String(format: "%.0f", tradeGain))") }
                    } else {
                       if debug { print("\(each.dateString)\tTime stop \(each.ticker) after \(daysInTrade) days with loss of \(String(format: "%.0f", tradeGain))") }
                    }
                }
                //MARK: - stop
                if !flat && each.low <= stop {
                    flat = true
                    let thisLoss = ( each.low - entryPrice ) * shares
                    allTrades.append(thisLoss)
                    if  thisLoss < largestLoser { largestLoser = thisLoss }
                    if debug { print("\(each.dateString)\tStop hit on \(each.ticker) Loss is \(String(format: "%.1f", thisLoss)) ") }
                    tradeGain = tradeGain + thisLoss
                    
                    if updateRealm {
                        let realm = try! Realm()
                        try! realm.write {
                            each.backTestProfit = tradeGain
                        }
                    }
                    if debug { print("\ttradeGain \(String(format: "%.1f", tradeGain)) = tradeGain \(String(format: "%.1f", tradeGain)) + thisLoss \(String(format: "%.1f", thisLoss))") }
                }
                UserDefaults.standard.set(each.date, forKey: "StatsUpdate")
            }
        }
        //if debug {  print("All Trades: \(allTrades)") }
        grossProfit = allTrades.reduce(0, +)
        //if debug { print("----------------------------------------------------------------------------\n\tSum \(String(format: "%.1f", grossProfit))") }
        
        tradeCount = allTrades.count
        //if debug { print("\tTotal Trades \(tradeCount)") }
        
        for each in allTrades {
            if each >= 0 {
                winCount += 1
            }
        }
 
        winPct =   Double( winCount ) / Double( tradeCount ) * 100.00
        let totalROI = (grossProfit / cost) * 100
        let annualRoi = totalROI / 3
        //if debug { print("\tTotal ROI \(totalROI)% Annual ROI \(annualRoi)%") }
        //if debug { print("winPct \(String(format: "%.1f", winPct)) = winCount \(winCount) / tradeCount \(tradeCount)")}
            
        if debug {   print("\n------------------------------> \(ticker) <--------------------------------------\n$\(String(format: "%.0f", grossProfit)) Profit, LW/LL \(String(format: "%.0f", largestWin))/\(String(format: "%.0f", largestLoser)), \(String(format: "%.2f", annualRoi))% ROI, \(String(format: "%.2f", winPct))% Win, $\(currentRisk) risk, \(tradeCount) trades\n--------------------------------------------------------------------------\n") }
       
        return ( grossProfit,largestWin, largestLoser, annualRoi, winPct )
    }

    
    func performanceString(ticker:String, updateRealm:Bool, debug: Bool)->String {
        let result = BackTest().enterWhenFlat(ticker: ticker, debug: debug, updateRealm: updateRealm)
        let profit = String(format: "%.0f", result.0)
        let LW = String(format: "%.0f", result.1)
        let LL = String(format: "%.0f", result.2)
        let roi = String(format: "%.2f", result.3)
        let winPct = String(format: "%.2f", result.4)
        let star = CalcStars().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        let answer = "\(ticker)\tProfit \t$\(profit),  LW/LL \(LW)/\(LL), \tROI \(roi)%, \t\(winPct)% Win, \t\(star) stars"
        return answer
    }
    
    func tableViewString(ticker:String)->String {
        let result = BackTest().enterWhenFlat(ticker: ticker, debug: false, updateRealm: false)
        let profit = String(format: "%.0f", result.0)
        let roi = String(format: "%.1f", result.3)
        let winPct = String(format: "%.1f", result.4)
        let star = CalcStars().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        return "\(ticker) $\(profit) \(roi)% \(winPct)% \t\(star.1)"
    }
    
    func chartString(ticker:String)->String {
        let result = BackTest().enterWhenFlat(ticker: ticker, debug: false, updateRealm: false)
        let profit = String(format: "%.2f", result.0)
        let roi = String(format: "%.1f", result.3)
        let winPct = String(format: "%.1f", result.4)
        let star = CalcStars().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        return "$\(profit)\n\(roi)%  ROI\n\(winPct)%  Win\n\(star.1)"
    }
}
