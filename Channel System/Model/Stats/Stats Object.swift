//
//  Stats Object.swift
//  Channel System
//
//  Created by Warren Hansen on 12/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Stats: Object {
    
    @objc dynamic var grossProfit  = 0.00
    @objc dynamic var avgPctWin    = 0.00
    @objc dynamic var avgROI       = 0.00
    @objc dynamic var grossROI     = 0.00
    @objc dynamic var avgStars     = 0.00
    @objc dynamic var maxCost     = 0.00
    @objc dynamic var largestLoser  = 0.00
    @objc dynamic var largestWinner = 0.00
    @objc dynamic var taskID     = "01"
    
    //MARK: - saveTotalStatsToRealm update or new object
    func updateFinalTotal(grossProfit: Double, avgPctWin:Double,avgROI:Double, grossROI:Double, avgStars:Double, maxCost:Double, largestWin:Double, largestLoss:Double  ) {
        
        let realm = try! Realm()
        let id = "01"
        if let updateStats = realm.objects(Stats.self).filter("taskID == %@", id).first {
        
            try! realm.write {
                updateStats.grossProfit = grossProfit
                updateStats.avgPctWin = avgPctWin
                updateStats.avgROI = avgROI
                updateStats.grossROI = grossROI
                updateStats.avgStars = avgStars
                updateStats.maxCost = maxCost
                updateStats.largestWinner = largestWin
                updateStats.largestLoser = largestLoss
            }
        } else {
            print("first time saving Stats Object")
            
            let newStats = Stats()
            newStats.grossProfit = grossProfit
            newStats.avgPctWin = avgPctWin
            newStats.avgROI = avgROI
            newStats.grossROI = grossROI
            newStats.avgStars = avgStars
            newStats.maxCost = maxCost
            
            try! realm.write {
                realm.add(newStats)
            }
        }
    }
}

