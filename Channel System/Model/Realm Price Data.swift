//
//  Realm Price Data.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Prices: Object {
    
    @objc dynamic var ticker  = ""
    @objc dynamic var last    = 0.0
    @objc dynamic var time    = ""
    @objc dynamic var taskID  = NSUUID().uuidString
}

class RealmHelpers: Object {
    
    func saveToRealm(ticker: String, last: Double, date: String) {
        // populate realm with last
        print("ready for realm")
        let realm = try! Realm()
        
        let prices = Prices()
        
        prices.time = date
        
        prices.last = last
        
        prices.ticker = ticker
        
        print("Begin Realm Save \(prices.ticker) \(prices.time) \(prices.last)")
        
        try! realm.write({ // [2]
            realm.add(prices)
        })
    }
    
    func deleteAll() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
}

