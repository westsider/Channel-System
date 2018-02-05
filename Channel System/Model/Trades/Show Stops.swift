//
//  Show Stops.swift
//  Channel System
//
//  Created by Warren Hansen on 1/22/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift
import SciChart

class ShowStops {
    
//    func checkStop(showStops:Bool, ticker:String) {
//    
//        // flag for showStops in charts vc
//        if !showStops {
//            return
//        }
//
//        let realm = try! Realm()
//        let smartPrice = realm.objects(Prices.self).filter("ticker == %@", ticker).filter("inTrade == true")
//        // nil 
//        print("ticker \(ticker)\t\(String(describing: smartPrice.last?.ticker))")
//        
//        let stringDate:String = (smartPrice.last?.dateString)!
//        var priorLow:Double = 0.0
//        let lastEntryDate = Utilities().convertToDateFrom(string: stringDate, debug: false)
//        let smartLows = realm.objects(Prices.self).filter("ticker == %@", ticker)
//                                        .filter("date >= %@", lastEntryDate)
//                                        .sorted(byKeyPath: "date", ascending: true)
//        let entryPrice = (smartLows.first?.entry)!
//        var stop:Double = (smartLows.first?.stop)!
//        let stopDistance = entryPrice - stop
//        print("\n\(stringDate) last entry was \(entryPrice) stop \(stop) distance \(stopDistance)")
//        //MARK: - add trail stop to prices object
//        var priorStop = 0.0
//        for each in smartLows {
//            print("In Check Stop Loop. Stop is \(stop) on \(each.dateString) low is \(each.low)")
//            if each.low > priorLow {
//                // trailstop moves up
//                let tempStop = each.low - stopDistance
//               // if tempStop > priorStop {
//                    stop = each.low - stopDistance
//                //} else {
//                //    stop = priorStop
//                //}
//                print("\(each.dateString) \(each.low) is higher, move stop up to \(stop)")
//            } else {
//                stop = priorStop
//                print("\(each.dateString) \(each.low) stop remains the same at \(stop)")
//                // trailStop ramins the same
//            }
//            addTrailStop(on: each.date!, ticker: each.ticker, newStop: stop)
//            priorLow = each.low
//             priorStop = stop
//        }
//    }
    
    func addTrailStop(on:Date, ticker:String, newStop:Double) {
        let priceToChange = RealmHelpers().getOneDay(ticker: ticker, date: on)
        let realm = try! Realm()
        try! realm.write {
            priceToChange.trailStop = newStop
        }
    }
    
    func textForMainUI()-> String{
        
        let openTrades = RealmHelpers().getOpenTrades()
        var uiText:String = "\n--------> Trail Stop Change <--------\n"
        for each in openTrades {
            print(each.ticker, each.dateString)
            uiText += showStopChange(ticker: each.ticker)
        }
        return uiText
    }
    
    func showStopChange(ticker:String)-> String {

        var uiText:String = ""
        let realm = try! Realm()
        let smartPrice = realm.objects(Prices.self).filter("ticker == %@", ticker).filter("inTrade == true")
        let stringDate:String = (smartPrice.last?.dateString)!
        var priorLow:Double = 0.0
        let lastEntryDate = Utilities().convertToDateFrom(string: stringDate, debug: false)
        let smartLows = realm.objects(Prices.self).filter("ticker == %@", ticker)
            .filter("date >= %@", lastEntryDate)
            .sorted(byKeyPath: "date", ascending: true)
        let entryPrice = (smartLows.first?.entry)!
        var stop:Double = (smartLows.first?.stop)!
        let stopDistance = entryPrice - stop
        print("\n-----> Looping through trail stops for \(ticker)")
        print("\(ticker)\t\(stringDate) last entry was \(entryPrice) stop  \(String(format:"%.2f", stop)) distance \(String(format:"%.2f", stopDistance))\n")
        
        //MARK: - add trail stop to prices object
        var thisStopChange = ""
        var priorStop = stop
        for each in smartLows {

            //print("\(each.dateString) \(each.low)")
            let newPotentialStop = each.low - stopDistance
            if each.low > priorLow && newPotentialStop > stop {
                // trailstop moves up
                stop = newPotentialStop
                print("⬆️\(each.dateString) \(each.low) is higher, move stop up to \(String(format:"%.2f", stop))\n")
                thisStopChange = "\(each.ticker) stop now \(stop)\n"
            } else {
                stop = priorStop
                print("⬇️\(each.dateString) \(each.low) stop remains the same at \(String(format:"%.2f", stop))\n")
                // trailStop ramins the same
            }
            addTrailStop(on: each.date!, ticker: each.ticker, newStop: stop)
            priorLow = each.low
            priorStop = stop
        }
        uiText += thisStopChange
        return uiText
    }
}


