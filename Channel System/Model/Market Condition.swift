//
//  Market Condition.swift
//  Channel System
//
//  Created by Warren Hansen on 12/21/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class MarketCondition {
    
    let spySeries = Prices().sortOneTicker(ticker: "SPY", debug: false)
    
    //MARK: -  trend as bull, bear, sideways
    func trend(close: Double, sma200: Double)-> (trend:String, value:Int) {
        let up = sma200 + ( sma200 * 0.02 )
        let dn = sma200 - ( sma200 * 0.02 )

        switch close {
        case let x where x > up:
            return ("Bull", 1)
        case let x where x < dn:
            return ("Bear", 0)
        default:
            return ("Sideways", -1)
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
    func volatility(atrSeries:[Double], debug:Bool  )-> [(volatility:String, value:Int)] {
        var answer:(volatility:String, value:Int) = ("nil", -100)
        var array100 = [Double]()
        var sum:Double
        var volatilityAnswer = [(volatility:String, value:Int)]()
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
                    answer = ("volatil", 1)
//                    volatil = true;
//                    normal = false;
//                    quiet = false;
                }
                else if( today < stdDevClacLo ) {
                    answer = ("quiet", -1)
//                    volatil = false;
//                    normal = false;
//                    quiet = true;
                }
                else {
                    answer = ("normal", 0)
//                    volatil = false;
//                    normal = true;
//                    quiet = false;
                }
                
                volatilityAnswer.append(answer)
            } else {
                volatilityAnswer.append(("nil", -100))
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
    
    
    // create cal Market cond func
    // create a morket condition realm obj
    // loop through SPY obj
    // for each day, save to realm
    //  1. trend
    //  2. volatility
    //  3. market condition
    //  4. volatility average line
    //  5. stdDevClacHi, stdDevClacLow
    
    // now I have a filter object I can backtest my system and
    // make a spy chart to prove the results
    //  1. plot 200 sma
    //  2. plot bands
    //  3. plot volatility with Std dev
    //  4. plot a matrix of 9 market conditions
    
    
    
    
    
    
    
    
}
