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
    @objc dynamic var annualProfit = 0.00
    @objc dynamic var avgPctWin    = 0.00
    @objc dynamic var avgROI       = 0.00 // annual roi
    @objc dynamic var grossROI     = 0.00
    @objc dynamic var avgStars     = 0.00
    @objc dynamic var maxCost     = 0.00
    @objc dynamic var largestLoser  = 0.00
    @objc dynamic var largestWinner = 0.00
    @objc dynamic var taskID     = "01"
    @objc dynamic var firstDate = Date()
    @objc dynamic var minStars = 0
    @objc dynamic var numDays = 0
    @objc dynamic var numYears = 0.00
    
    func changeMinStars(stars: Int) {
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
    
    func changeAvgStars(avgStars: Double) {
        let realm = try! Realm()
        let id = "01"
        if let updateStats = realm.objects(Stats.self).filter("taskID == %@", id).last {
            try! realm.write {
                updateStats.avgStars = avgStars
            }
        } else {
            let newStats = Stats()
            newStats.avgStars = avgStars
            try! realm.write {
                realm.add(newStats)
            }
        }
    }
    
    func getStars()-> Int {
        let realm = try! Realm()
        var minStars:Int = 0
        let id = "01"
        if let updateStats = realm.objects(Stats.self).filter("taskID == %@", id).last {
            minStars = updateStats.minStars
        }
        return minStars
    }
    
//    struct StatsSummary {
//        var totalProfit:Double
//        var annualProfit:Double
//        var totalRoi:Double
//        var annualRoi:Double
//        var winPct:Double
//        var maxCost:Double
//        var largestWin:Double
//        var largestLoss:Double
//        var numDays:Int
//        var numYears:Double
//    }
    
    //MARK: - saveTotalStatsToRealm update or new object
    func updateFinalTotal(data: PortfolioFilters.StatsSummary) {
        
        let realm = try! Realm()
        let oldStatstData = realm.objects(Stats.self)
        let avgStarsBefore = oldStatstData.last?.avgStars // get avg stars before I remove the object from realm
        let minStars = oldStatstData.last?.minStars
        try! realm.write {
            realm.delete(oldStatstData)
           
            let statsData = Stats()
            statsData.grossProfit = data.totalProfit
            statsData.annualProfit = data.annualProfit
            statsData.avgPctWin = data.winPct
            statsData.avgROI = data.annualRoi     // annual roi
            statsData.grossROI = data.totalRoi
            statsData.avgStars = avgStarsBefore! // using avg stars created ealier in lifecycle
            statsData.maxCost = data.maxCost
            statsData.largestLoser = data.largestLoss
            statsData.largestWinner = data.largestWin
            statsData.minStars = minStars!
            statsData.numDays = data.numDays
            statsData.numYears = data.numYears
            
            realm.add(statsData)
            
        }
    }
}
















