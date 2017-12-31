//
//  Market Condition.swift
//  Channel System
//
//  Created by Warren Hansen on 12/21/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
/*
     1               2               3
     Bull Volatile   Bull Normal     Bull Quiet
 
     4               5               6
     Side Volatile   Side Normal     Side Quiet
 
     7               8               9
     Bear Volatile   Bear Normal     Bear Quiet
 */

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
    @objc dynamic var strGuidance = 0
    @objc dynamic var guidance = false
    @objc dynamic var guidanceChart = ""
    @objc dynamic var matrixResult = 0
    @objc dynamic var matrixCondition = ""
    
    @objc dynamic var taskID     = NSUUID().uuidString
    
    //MARK: - Clear Realm
    func deleteAll() {
        let realm = try! Realm()
        let allMarketCondition = realm.objects(MarketCondition.self)
        try! realm.write {
            realm.delete(allMarketCondition)
        }
        print("\nRealm \tMarketCondition \tCleared!\n")
    }
    
    //MARK: -  trend as bull, bear, sideways
    func trend(close: Double, sma200: Double)-> (trend:String, value:Int, upper:Double, lower:Double) {
        let up = sma200 + ( sma200 * 0.02 )
        let dn = sma200 - ( sma200 * 0.02 )
        switch close {
        case let x where x > up:
            return ("Bull", 1, up, dn)
        case let x where x < dn:
            return ("Bear", -1, up, dn)
        default:
            return ("Sideways", 0, up, dn)
        }
    }
    
    //MARK: -  trueRange
    func trueRange(high:Double, low:Double, close1:Double)-> Double {
        //double trueRange    = Math.Max(Math.Abs(low0 - close1), Math.Max(high0 - low0, Math.Abs(high0 - close1)));
        let calc1 = low - close1
        let calc2 = high - low
        let calc3 = high - close1
        return max(calc1, calc2, calc3)
    }
    
    //MARK: -  ATR % = ATR(14)  / close renturns array same size as realm object
    func atrPct(series:Results<Prices> )-> [Double] {
        var fourteenPeriodArray = [Double]()
        var sum:Double
        var averages = [Double]()
        let period:Int = 14
        var close1:Double = 0.00
        for today in series {
            let range = trueRange(high: today.high, low: today.low, close1: close1)
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
            close1 = today.close
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
        
        let arraySlice = atrSeries.suffix(100); print(arraySlice)
        
        for today in atrSeries {
            array100.append(today)
            if array100.count > period {
                array100.remove(at: 0)
                sum = array100.reduce(0, +)
                let average = sum / Double(period)
                let max = array100.max()
                let min = array100.min()
                let stdDev = standardDeviation(arr: array100)
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
                    if debug { print("Setting Volatility to 1 because \(today) > \(stdDevClacHi)")}
                    answer = ("volatil", 1, stdDevClacHi, stdDevClacLo)
                }
                else if( today < stdDevClacLo ) {
                    answer = ("quiet", -1, stdDevClacHi, stdDevClacLo)
                    if debug { print("Setting Volatility to -1 because \(today) < \(stdDevClacLo)")}
                }
                else {
                    answer = ("normal", 0, stdDevClacHi, stdDevClacLo)
                    if debug { print("Setting Volatility to 0 because \(today) <> \(stdDevClacHi) \(stdDevClacLo)")}
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
    func calcMarketCondFirstRun(debug:Bool, completion: @escaping () -> ()) {
        deleteAll()
        let realm = try! Realm()
        if realm.objects(MarketCondition.self).last != nil {
            if debug { print("\nYo! we have data in market condition so we are not calling calcMarketCondFirstRun()\n")}
            return
        }
        //DispatchQueue.global(qos: .background).async {
        if debug { print("\n------> Market Contition Start <--------\n") }
            let spySeries = Prices().sortOneTicker(ticker: "SPY", debug: debug)
            let aytrPct = self.atrPct(series: spySeries )
            let volatil = self.volatility(atrSeries: aytrPct, debug: debug)
            var count = 0
            for (index, today) in spySeries.enumerated() {
                let todayTrend = self.trend(close: today.close, sma200: today.movAvg200)
                let matrix = self.setMatrix(trnd: todayTrend.value, volatl: volatil[index].value, debug: debug)
                let guide = self.guidance(matrix: matrix)
                
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
                mc.guidance = guide.long
                mc.guidanceChart = guide.guidance
                mc.matrixResult = matrix.result
                mc.matrixCondition = matrix.condition
                
                try! realm.write {
                    realm.add(mc)
                }
                count = index
                if debug { print("MC: finished \(count) of \(spySeries.count)")}
            }
    
            DispatchQueue.main.async {
                if count == spySeries.count {
                    completion()
                    if debug { print("\n------> Market Contition Complete <--------\n")}
                }
            }
        //}
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
                    let matrix = self.setMatrix(trnd: todayTrend.value, volatl: volatil[index].value, debug: debug)
                    let guide = self.guidance(matrix: matrix)
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
                    mc.guidance = guide.long
                    mc.guidanceChart = guide.guidance
                    mc.matrixResult = matrix.result
                    mc.matrixCondition = matrix.condition
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
    
    func standardDeviation(arr : [Double]) -> Double {
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    func setMatrix(trnd:Int, volatl:Int, debug:Bool)-> (result:Int, condition:String) {
        var answer:(result:Int, condition:String) = (result:0, condition:"no condition")
        if  trnd == 1 && volatl == 1 {
            answer = (result:1, condition:"bull volatile")
        }
        if trnd == 1 && volatl == 0 {
            answer = (result:2, condition:"Bull Normal")
        }
        if trnd == 1 && volatl == -1 {
            answer = (result:3, condition:"Bull Quiet")
        }
        if trnd == 0 && volatl == 1 {
            answer = (result:4, condition:"Sideways Volatile")
        }
        if trnd == 0 && volatl == 0 {
           answer = (result:5, condition:"Sideways Normal")
        }
        if trnd == 0 && volatl == -1 {
            answer = (result:6, condition:"Sideways Quiet")
        }
        if trnd == -1 && volatl == 1 {
            answer = (result:7, condition:"Bear Volatile")
        }
        if trnd == -1 && volatl == 0 {
            answer = (result:8, condition:"Bear Normal")
        }
        if trnd == -1 && volatl == -1 {
            answer = (result:9, condition:"Bear Quiet")
        }
        if debug { print("we have set matrix! \ninput trend: \(trnd) volatility: \(volatl)\noutput: condition \(answer.condition) result \(answer.result) ") }
        return answer
    }
    
    func guidance(matrix:(result:Int, condition:String))->(guidance:String, long:Bool) {
        var guidance:(guidance:String, long:Bool) = (guidance:"No Guidance", long:false)
        switch matrix.result {
        case 1...3:
            guidance = (guidance:"Tomorrow is Favorable", long:true)
        case 6:
            guidance = (guidance:"Tomorrow is Favorable", long:true)
        case 4...5:
            guidance = (guidance:"Tomorrow is Flat", long:false)
        case 7...9:
            guidance = (guidance:"Tomorrow is Down", long:false)
        default:
            guidance = (guidance:"no guidance", long:false)
        }
        return guidance
    }
    
    func getStrMatixForChart(debug:Bool)->String {
        let realm = try! Realm()
        let mc = realm.objects(MarketCondition.self)
        let sortedByDate = mc.sorted(byKeyPath: "date", ascending: true)
        let lastMc = sortedByDate.last
        if let date = lastMc?.dateString, let condition = lastMc?.matrixCondition, let guidance = lastMc?.guidanceChart {
        let strResult = date + " " + condition + ", " + guidance
        if debug {
            print("\n----> here is your  matrix <----")
            print("date: \(String(describing: lastMc?.date!))")
            print("trend: \(String(describing: lastMc?.trend ))")
            print("trend string: \(String(describing: lastMc?.trendString ))")
            print("volatility: \(String(describing: lastMc?.volatility ))")
            print("volatilityString: \(String(describing: lastMc?.volatilityString ))")
            print("strGuidance: \(String(describing: lastMc?.strGuidance ))")
            print("guidance: \(String(describing: lastMc?.guidance ))")
            print("guidanceChart: \(String(describing: lastMc?.guidanceChart))")
            print("matrixResult: \(String(describing: lastMc?.matrixResult))")
            print("matrixCondition: \(String(describing: lastMc?.matrixCondition))")
            print("\nThe bands -----------------------------")
            print("volatilityAverage: \(String(describing: lastMc?.volatilityAverage ))")
            print("stdDevClacHi: \(String(describing: lastMc?.stdDevClacHi))")
            print("stdDevClacLow: \(String(describing: lastMc?.stdDevClacLow ))\n")
            }
        return strResult
        } else {
            return "NoData"
        }
    }
    
    func getMatixForBacktest()->Bool {
        let realm = try! Realm()
        if let mc = realm.objects(MarketCondition.self).last {
            return mc.guidance
        } else {
            return false
        }
    }
    
    func getMatixToProveOnChart(date:Date)->Int {
        var answer = 20
        let realm = try! Realm()
        if let mc = realm.objects(MarketCondition.self).filter("date == %@", date).last {
            answer = mc.matrixResult
        }
        return answer
    }
}


