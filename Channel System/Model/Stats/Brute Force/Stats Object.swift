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
    @objc dynamic var firstDate = Date()
    @objc dynamic var minStars = 0
    
    func changeStars(stars: Int) {
        let realm = try! Realm()
        let id = "01"
        if let updateStats = realm.objects(Stats.self).filter("taskID == %@", id).first {
            try! realm.write {
                updateStats.minStars = stars
            }
        } else {
            let newStats = Stats()
            newStats.minStars = stars
            try! realm.write {
                realm.add(newStats)
            }
        }
    }
    
    func getStars()-> Int {
        let realm = try! Realm()
        var minStars:Int = 0
        let id = "01"
        if let updateStats = realm.objects(Stats.self).filter("taskID == %@", id).first {
            minStars = updateStats.minStars
        }
        return minStars
    }
    
    //MARK: - saveTotalStatsToRealm update or new object
    func updateFinalTotal(grossProfit: Double, avgPctWin:Double,avgROI:Double, grossROI:Double, avgStars:Double, maxCost:Double, largestWin:Double, largestLoss:Double, firstDate:Date  ) {
        
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
                updateStats.firstDate = firstDate  // not sure what this is used for, might be to calc annual roi
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
            newStats.firstDate = firstDate
            
            try! realm.write {
                realm.add(newStats)
            }
        }
    }
}

