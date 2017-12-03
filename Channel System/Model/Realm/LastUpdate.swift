//
//  LastUpdate.swift
//  Channel System
//
//  Created by Warren Hansen on 11/28/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class LastUpdate: Object {
    @objc dynamic var lastUpdateString = ""
    @objc dynamic var lastUpdate:Date?
    @objc dynamic var updates    = 0

    let formatter = DateFormatter()
    let now = Date()
    
    func checkUpate()-> String {
        let realm = try! Realm()
        let calendar = NSCalendar.current
        // check date
        let getDate = realm.objects(LastUpdate.self)
        let priorDate = getDate.last?.lastUpdate!
        if ( priorDate == nil ) {
            return "No Updates in realm"
        } else {
            if !calendar.isDateInToday(priorDate!)  {
                self.resetAtMidnight()
            }
            
            // parse update
            let getRealm = realm.objects(LastUpdate.self)
            let lastUpdate = getRealm.last?.lastUpdateString
            //todo: add count
            let count = getRealm.last?.updates
            return "Last update: \(lastUpdate!), \(String(describing: count!)) updates today"
        }
    }
    
    func incUpdate() {
        let realm = try! Realm()
        let checkData = realm.objects(LastUpdate.self)
        
        if checkData.last?.lastUpdate == nil {
            let this = LastUpdate()
            this.lastUpdate = now
            this.lastUpdateString = DateHelper().convertToStringFrom(date:now)
            this.updates += 1
            
            try! realm.write({
                realm.add(this)
            })
        } else {
            try! realm.write({
                let this = LastUpdate()
                this.lastUpdate = DateHelper().convertUTCtoLocal(debug: false, UTC: now)
                this.lastUpdateString = DateHelper().convertToStringFrom(date:now)
                this.updates += 1
            })
        }
    }
    
    func resetAtMidnight() {
        // time = 0:00 updates = 0
        let realm = try! Realm()
        try! realm.write({
            let this = LastUpdate()
            this.updates = 0
        })
    }
}
