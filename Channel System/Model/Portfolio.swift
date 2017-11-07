//
//  Portfolio.swift
//  Channel System
//
//  Created by Warren Hansen on 11/7/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation

class Entries {
    var ticker:String?
    var entry:Double?
    var stop:Double?
    var target:Double?
    var date:Date?
    var profit:Double?
    var shares:Int?
    var risk:Double?
}

class Portfolio: Entries {
    var open = [Entries]()
    var closed = [Entries]()
    
    func makeEntry(ticker:String, entryString:String, target:Double, stop:Double, debug:Bool) {
        print("You entered \(entryString)")
        let entries = Entries()
        let entry = Double(entryString)
        entries.ticker = ticker
        entries.entry = entry
        entries.stop = stop
        entries.target = target
        entries.shares = 100
        entries.risk = 50
        entries.date = Date()
        //let portfolio = Portfolio()
        self.open.append(entries)
        if ( debug ) { self.showOpenTrades() }
    }
    
    func showOpenTrades() {
        for items in open {
            print("Inside Open Trades")
            print("\(items.date!) \(String(describing: items.ticker!)) shares:\(String(describing: items.shares!)) entry:\(String(describing: items.entry!)) stop:\(String(describing: items.stop!)) target:\(String(describing: items.target!))")
        }
    }
}
