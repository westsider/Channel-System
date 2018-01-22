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
    
    // goal 1. show trail stop on any ticker in portfolio
    // this would get called in segue from portfolio to chart
    // this would be an indicator just like entries
    // steps to change original stop

    func checkStop(showStops:Bool, ticker:String) {
        
        // flag for showStops in charts vc
        if !showStops {
            return
        }

        let realm = try! Realm()
        let smartPrice = realm.objects(Prices.self).filter("ticker == %@", ticker).filter("inTrade == true")
        let entryPrice = (smartPrice.last?.entry)!
        var stop:Double = (smartPrice.last?.stop)!
        let stopDistance = entryPrice - stop
        let stringDate:String = (smartPrice.last?.dateString)!
        var priorLow:Double = 0.0
        print("\n\(stringDate) last entry was \(entryPrice) stop \(stop) distance \(stopDistance)")
        let lastEntryDate = Utilities().convertToDateFrom(string: stringDate, debug: false)

        let smartLows = realm.objects(Prices.self).filter("ticker == %@", ticker)
                                        .filter("date >= %@", lastEntryDate)
                                        .sorted(byKeyPath: "date", ascending: true)

        //MARK: - add trail stop to prices object
        for each in smartLows {
            print("\(each.dateString) \(each.low)")
            if each.low > priorLow {
                // trailstop moves up
                stop = each.low - stopDistance
                print("\(each.dateString) \(each.low) is higher, move stop up to \(stop)")
            } else {
                print("\(each.dateString) \(each.low) stop remains the same at \(stop)")
                // trailStop ramins the same
            }
            addTrailStop(on: each.date!, ticker: each.ticker, newStop: stop)
            priorLow = each.low
        }
    }
    
    func addTrailStop(on:Date, ticker:String, newStop:Double) {
        let priceToChange = RealmHelpers().getOneDay(ticker: ticker, date: on)
        let realm = try! Realm()
        try! realm.write {
            priceToChange.trailStop = newStop
        }
    }

}
