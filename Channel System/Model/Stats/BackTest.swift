//
//  BackTest.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class BackTest {
    /**
     - Author: Warren Hansen
     - ticker: String - a symbol to retrieve a record
     - returns: grossProfit,largestWin, largestLoser, annualRoi, winPct
     ### Declare As:
     let result = BackTest().calcPastTradesForEach(ticker: "INTC")
     */
    func calcPastTradesForEach(ticker: String, debug:Bool, updateRealm: Bool)->(Double, Double, Double, Double, Double) {
    
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
        
       
        
        for each in prices {
            
            //MARK: - Entry
            if flat && each.longEntry {
                flat = false
                entryPrice = each.close
                daysInTrade = 0
                tradeCount += 1
                if debug { print("Entry on \(each.dateString) Trade count \(tradeCount) and wPctR is \(String(format: "%.1f", each.wPctR))") }
                let stopDist = TradeHelpers().calcStopTarget(ticker: each.ticker, close: entryPrice, debug: false).2
                shares = Double( TradeHelpers().calcShares(stopDist: stopDist, risk: 250))
                stop = TradeHelpers().calcStopTarget(ticker: each.ticker, close: entryPrice, debug: false).0
                cost = TradeHelpers().capitalRequired(close: entryPrice, shares: Int(shares))
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
                    if debug { print("wPctR(\(String(format: "%.1f", each.wPctR)) exit on \(each.dateString) Win \(String(format: "%.1f", tradeGain))") }
                    allTrades.append(tradeGain)

                }
                //MARK: - time stop
                if daysInTrade >= 7 {
                    if debug { print("\nTime exit fot \(each.ticker)\n") }
                    flat = true
                    tradeGain = (each.close - entryPrice) * shares
                    
                    if updateRealm {
                        let realm = try! Realm()
                        try! realm.write {
                            each.backTestProfit = tradeGain
                        }
                    }

                    allTrades.append(tradeGain)
                    if (( each.close - entryPrice ) >=  0 ) {
                        if  tradeGain > largestWin { largestWin = tradeGain }
                        if debug { print("Time stop on \(each.dateString) after \(daysInTrade) days with gain of \(String(format: "%.1f", tradeGain))") }
                    } else {
                       if debug { print("Time stop on \(each.dateString) after \(daysInTrade) days with loss of \(String(format: "%.1f", tradeGain))") }
                    }
                }
                //MARK: - stop
                if !flat && each.low <= stop {
                    flat = true
                    let thisLoss = ( each.low - entryPrice ) * shares
                    allTrades.append(thisLoss)
                    if  thisLoss < largestLoser { largestLoser = thisLoss }
                    if debug { print("Stop hit on \(each.dateString) Loss is \(String(format: "%.1f", thisLoss)) ") }
                    tradeGain = tradeGain + thisLoss
                    
                    if updateRealm {
                        let realm = try! Realm()
                        try! realm.write {
                            each.backTestProfit = tradeGain
                        }
                    }

                    if debug { print("tradeGain \(String(format: "%.1f", tradeGain)) = tradeGain \(String(format: "%.1f", tradeGain)) + thisLoss \(String(format: "%.1f", thisLoss)) ") }

                }
                UserDefaults.standard.set(each.date, forKey: "StatsUpdate")
            }
        }
        //if debug {  print("All Trades: \(allTrades)") }
        grossProfit = allTrades.reduce(0, +)
        if debug { print("Sum: \(grossProfit)") }
        
        tradeCount = allTrades.count
        if debug { print("Total Trades \(tradeCount)") }
        
        for each in allTrades {
            if each >= 0 {
                winCount += 1
            }
        }
 
        winPct =   Double( winCount ) / Double( tradeCount ) * 100.00
        let totalROI = (grossProfit / cost) * 100
        let annualRoi = totalROI / 3
        if debug { print("Total ROI \(totalROI)% Annual ROI \(annualRoi)%") }
        
        if debug { print("winPct \(String(format: "%.1f", winPct)) = winCount \(winCount) / tradeCount \(tradeCount)")
            
            print("\n--- inside func ----\nTicker \(ticker), Profit $\(String(format: "%.0f", grossProfit)), LW/LL \(String(format: "%.0f", largestWin))/\(String(format: "%.0f", largestLoser)), ROI \(String(format: "%.2f", annualRoi))%, \(String(format: "%.2f", winPct))% Win\n") }
        
        return ( grossProfit,largestWin, largestLoser, annualRoi, winPct )
    }

    //MARK: - TODO - rank tickers
    // ( score 50% each for  , winPct literal ) = 80% = 4 stars, 100% = 5 stars
    func calcStars(grossProfit:Double, annualRoi: Double, winPct:Double, debug:Bool)-> (Int, String) {
        var totalPercent = 0.0
        var stars = 0
        var starIcon = "★"
        
        if grossProfit <= 0 {
            return (1, starIcon )
        }
    
        switch annualRoi {
        case 0..<2:
            totalPercent = 25.0
        case 2..<3:
            totalPercent = 50.0
        case 3..<5:
            totalPercent = 75.0
        case 5..<100:
            totalPercent = 120.0
        default:
            totalPercent = 100.0
        }
        // sliding scale for winPct
        switch winPct {
        case 0..<55:
            totalPercent += 0
        case 55..<60:
            totalPercent += 50.0
        case 60..<75:
            totalPercent += 75.0
        case 75..<85:
            totalPercent += 85.00
        case 85..<100:
            totalPercent += 100.0
        default:
            totalPercent += 0.0
        }
        if debug { print("Total Percent = \(totalPercent)") }
        // assign stars 1 - 5
        switch totalPercent {
        case 0..<40:
            stars = 1
        case 40..<80:
            stars = 2
        case 80..<120:
            stars = 3
        case 120..<160:
            stars = 4
        case 160...200:
            stars = 5
        default:
            stars = 1
        }
        if debug { print("\(stars) Stars") }
        
        // ⭐️⭐️⭐️⭐️⭐️
        if stars == 2 {
            starIcon = "★★"
        } else if stars == 3 {
            starIcon = "★★★"
        } else if stars == 4 {
            starIcon = "★★★★"
        } else if stars == 5 {
            starIcon = "★★★★★"
        }

        return (stars, starIcon )
    }
    
    func performanceString(ticker:String, updateRealm:Bool, debug: Bool)->String {
        let result = BackTest().calcPastTradesForEach(ticker: ticker, debug: debug, updateRealm: updateRealm)
        let profit = String(format: "%.0f", result.0)
        let LW = String(format: "%.0f", result.1)
        let LL = String(format: "%.0f", result.2)
        let roi = String(format: "%.2f", result.3)
        let winPct = String(format: "%.2f", result.4)
        let star = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        let answer = "\(ticker)\tProfit \t$\(profit),  LW/LL \(LW)/\(LL), \tROI \(roi)%, \t\(winPct)% Win, \t\(star) stars"
        return answer
    }
    
    func tableViewString(ticker:String)->String {
        let result = BackTest().calcPastTradesForEach(ticker: ticker, debug: false, updateRealm: false)
        let profit = String(format: "%.0f", result.0)
        let roi = String(format: "%.1f", result.3)
        let winPct = String(format: "%.1f", result.4)
        let star = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        return "\(ticker) $\(profit) \(roi)% \(winPct)% \t\(star.1)"
    }
    
    func chartString(ticker:String)->String {
        let result = BackTest().calcPastTradesForEach(ticker: ticker, debug: false, updateRealm: false)
        let profit = String(format: "%.2f", result.0)
        let roi = String(format: "%.1f", result.3)
        let winPct = String(format: "%.1f", result.4)
        let star = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
        return "$\(profit)\n\(roi)%  ROI\n\(winPct)%  Win\n\(star.1)"
    }
}












