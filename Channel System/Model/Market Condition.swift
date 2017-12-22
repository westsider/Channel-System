//
//  Market Condition.swift
//  Channel System
//
//  Created by Warren Hansen on 12/21/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class MarketCondition: Object {
    
    @objc dynamic var dateString = ""
    @objc dynamic var date:Date?
    @objc dynamic var open       = 0.00
    @objc dynamic var high       = 0.00
    @objc dynamic var low        = 0.00
    @objc dynamic var close      = 0.00
    @objc dynamic var movAvg200 = 0.00
    @objc dynamic var trend = 0
    @objc dynamic var trendString = ""
    @objc dynamic var upperBand = 0.00
    @objc dynamic var lowerBand = 0.00
    @objc dynamic var volatility = 0
    @objc dynamic var volatilityString = ""
    @objc dynamic var volatilityAverage = 0.00
    @objc dynamic var stdDevClacHi = 0.00
    @objc dynamic var stdDevClacLow = 0.00
    @objc dynamic var taskID     = NSUUID().uuidString
    
    //MARK: -  trend as bull, bear, sideways
    func trend(close: Double, sma200: Double)-> (trend:String, value:Int, upper:Double, lower:Double) {
        let up = sma200 + ( sma200 * 0.02 )
        let dn = sma200 - ( sma200 * 0.02 )
        switch close {
        case let x where x > up:
            return ("Bull", 1, up, dn)
        case let x where x < dn:
            return ("Bear", 0, up, dn)
        default:
            return ("Sideways", -1, up, dn)
        }
    }
    
    //MARK: -  trueRange
    func trueRange(high:Double, low:Double)-> Double {
        return  high - low
    }
    
    //MARK: -  ATR % = ATR(14)  / close renturns array same size as realm object
    func atrPct(series:Results<Prices> )-> [Double] {
        var fourteenPeriodArray = [Double]()
        var sum:Double
        var averages = [Double]()
        let period:Int = 14
        
        for today in series {
            let range = trueRange(high: today.high, low: today.low)
            fourteenPeriodArray.append(range)
            if fourteenPeriodArray.count > period {
                fourteenPeriodArray.remove(at: 0)
                sum = fourteenPeriodArray.reduce(0, +)
                let average = sum / Double(period)
                let pctRange = average / today.close
                averages.append(pctRange)
            } else {
                averages.append(0.00)
            }
        }
        return averages
    }
    
    // 100 days ATR% max, min, avg, std dev returns an array same size as realm oby
    //MARK: -  ATR % = ATR(14)  / close renturns array same size as realm object
    func volatility(atrSeries:[Double], debug:Bool  )-> [(volatility:String, value:Int, stdDevClacHi:Double, stdDevClacLo:Double )] {
        var answer:(volatility:String, value:Int, stdDevClacHi:Double, stdDevClacLo:Double ) = ("nil", -100, 0.0, 0.0)
        var array100 = [Double]()
        var sum:Double
        var volatilityAnswer = [(volatility:String, value:Int, stdDevClacHi:Double, stdDevClacLo:Double)]()
        let period:Int = 100
        
        for today in atrSeries {
            array100.append(today)
            if array100.count > period {
                array100.remove(at: 0)
                sum = array100.reduce(0, +)
                let average = sum / Double(period)
                let max = array100.max()
                let min = array100.min()
                // find Std Dev
                let summedSquared = sumOfSquareOfDifferences(array: array100)
                let arrayLength:Double = Double(array100.count)-1
                let stdDev = sqrt( summedSquared / arrayLength )
                
                let stdDevClacHi:Double = average + stdDev;
                let stdDevClacLo:Double = average - stdDev;
                
                if ( debug ) {
                    print("-----");
                    print("stdDev  ", stdDev);
                    print("   max  ", max!);
                    print("ClacHi  ", stdDevClacHi );
                    print("ClacLo  ", stdDevClacLo );
                    print("   min  ", min!);
                    print("-----");
                }
                
                if( today > stdDevClacHi ) {
                    answer = ("volatil", 1, stdDevClacHi, stdDevClacLo)
                    //volatil = true; // normal = false;  //quiet = false;
                }
                else if( today < stdDevClacLo ) {
                    answer = ("quiet", -1, stdDevClacHi, stdDevClacLo)
                    // volatil = false // normal = false // quiet = true;
                }
                else {
                    answer = ("normal", 0, stdDevClacHi, stdDevClacLo)
                    // volatil = false; // normal = true; // quiet = false;
                }
                
                volatilityAnswer.append(answer)
            } else {
                volatilityAnswer.append(("nil", -100, 0.0, 0.0))
            }
        }
        return volatilityAnswer
    }
    
    func sumOfSquareOfDifferences(array: [Double]) -> Double {
        let sumOfSquares = array.map({ $0 * $0 }).reduce(0, +)
        let sum = array.reduce(0, +)
        let squareOfSum = sum * sum
        return squareOfSum - sumOfSquares
    }
    
    //MARK: -  Market condition func to be called at price update after sma200
    func calcMarketCondFirstRun(debug:Bool) {
        DispatchQueue.global(qos: .background).async {
            let spySeries = Prices().sortOneTicker(ticker: "SPY", debug: debug)
            let aytrPct = self.atrPct(series: spySeries )
            let volatil = self.volatility(atrSeries: aytrPct, debug: debug)
            let realm = try! Realm()
            for (index, today) in spySeries.enumerated() {
                let todayTrend = self.trend(close: today.close, sma200: today.movAvg200)
                let mc = MarketCondition()
                mc.dateString = today.dateString
                mc.date = today.date
                mc.open = today.open
                mc.high = today.high
                mc.low = today.low
                mc.close = today.close
                mc.movAvg200 = today.movAvg200
                mc.trend = todayTrend.value
                mc.trendString = todayTrend.trend
                mc.upperBand = todayTrend.upper
                mc.lowerBand = todayTrend.lower
                mc.volatility = volatil[index].value
                mc.volatilityString = volatil[index].volatility
                mc.volatilityAverage = aytrPct[index]
                mc.stdDevClacHi      = volatil[index].stdDevClacHi
                mc.stdDevClacLow     = volatil[index].stdDevClacLo
                try! realm.write {
                    realm.add(mc)
                }
            }
        }
    }
    
    func calcMarketCondUpdate(debug:Bool) {
        DispatchQueue.global(qos: .background).async {
            let spySeries = Prices().sortOneTicker(ticker: "SPY", debug: debug)
            let aytrPct = self.atrPct(series: spySeries )
            let volatil = self.volatility(atrSeries: aytrPct, debug: debug)
            var isNewDate = false
            let lastInRealm = Prices().getLastDateInMktCond(debug: debug)
            let realm = try! Realm()
            
            for (index, today) in spySeries.enumerated() {
                let todayTrend = self.trend(close: today.close, sma200: today.movAvg200)
                isNewDate = Prices().checkIfNew(date: today.date!, realmDate:lastInRealm, debug: debug)
                if isNewDate {
                    let mc = MarketCondition()
                    mc.dateString = today.dateString
                    mc.date = today.date
                    mc.open = today.open
                    mc.high = today.high
                    mc.low = today.low
                    mc.close = today.close
                    mc.movAvg200 = today.movAvg200
                    mc.trend = todayTrend.value
                    mc.trendString = todayTrend.trend
                    mc.volatility = volatil[index].value
                    mc.volatilityString = volatil[index].volatility
                    mc.volatilityAverage = aytrPct[index]
                    mc.stdDevClacHi      = volatil[index].stdDevClacHi
                    mc.stdDevClacLow     = volatil[index].stdDevClacLo
                    try! realm.write {
                        realm.add(mc)
                    }
                }
            }
        }
    }
    
    //MARK: - Get Series for analisys
    func getData()-> Results<MarketCondition> {
        let realm = try! Realm()
        let mc = realm.objects(MarketCondition.self)
        let sortedByDate = mc.sorted(byKeyPath: "date", ascending: true)
        return sortedByDate
    }
    
    // create a market condition realm obj
    // loop through SPY obj
    // for each day, save to realm
    //  1. trend
    //  2. volatility
    //  3. market condition
    //  4. volatility average line
    //  5. stdDevClacHi, stdDevClacLow
    
    // now I have a filter object I can backtest my system and
    // change spy chart to show market cond
    //  1. plot 200 sma
    //  2. plot bands
    //  3. plot volatility with Std dev
    //  4. plot a matrix of 9 market conditions
    
    // filter backtest with market condition and check the results
    
    
    
    
    
    
    
    
}
