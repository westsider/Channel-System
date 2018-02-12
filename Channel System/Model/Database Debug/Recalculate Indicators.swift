//
//  Recalculate Indicators.swift
//  Channel System
//
//  Created by Warren Hansen on 2/12/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class Recalculate {
    
    func allIndicators(ticker:String, debug:Bool) {
        
        SMA().getData(galaxie: [ticker], debug: debug, period: 10) { (finished1) in
            if finished1 {
                print("Finished SMA10")
                SMA().getData(galaxie: [ticker], debug: debug, period: 200) { (finished2) in
                    if finished2 {
                        print("Finished SMA200")
                        PctR().getwPctR(galaxie: [ticker], debug: true, completion: { (finished3) in
                            if finished3 {
                                print("Finished wPct(R)")
                                Entry().getEveryEntry(galaxie: [ticker], debug: debug, completion: { (finished4) in
                                    if finished4 {
                                        print("Finished Entries")
                                        CalcStars().backtest(galaxie: [ticker], debug: debug, completion: {
                                            print("Finished ClacStars")
                                        })
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }
}
