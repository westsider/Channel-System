//
//  Weekly Stats.swift
//  Channel System
//
//  Created by Warren Hansen on 12/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class WklyStats: Object {
    
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var taskID     = NSUUID().uuidString
    
    func updateStats(date: Date, profit: Double) {
        
        let realm = try! Realm()
        
        let thisWeek = WklyStats()
       
        
        thisWeek.date = date
        thisWeek.profit = profit
        
        try! realm.write {
            realm.add(thisWeek)
        }
    }
}
