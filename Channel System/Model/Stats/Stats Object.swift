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
    
    @objc dynamic var longestDDperiod = 0
    @objc dynamic var longestDDdate = Date()
    @objc dynamic var largestDD = 0.0
    @objc dynamic var largestDDdate = Date()
    @objc dynamic var ddAsPctOfProfit = 0.0
    

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
            statsData.longestDDperiod = data.longestDDperiod
            statsData.longestDDdate = data.longestDDdate
            statsData.largestDD = data.largestDD
            statsData.largestDDdate = data.largestDDdate
            statsData.ddAsPctOfProfit = data.ddAsPctOfProfit
            realm.add(statsData)
        }
    }
}
















