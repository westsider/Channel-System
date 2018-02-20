//
//  First Run Routine.swift
//  Channel System
//
//  Created by Warren Hansen on 1/23/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class FirstRun {
    //////////////////////////////////////////////////////////////////////////////////
    //                                  First Run                                   //
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Initialize Everything
    func initializeEverything(galaxie:[String], debug:Bool) {
        //updateNVActivity(with:"Clearing Database")
        RealmHelpers().deleteAll()                                                     // 1.0
        //updateNVActivity(with:"Loading Historical Prices")                                            // 1.1
        CSVFeed().getData(galaxie: galaxie, debug: debug) { ( finished ) in            // 1.2
            if finished {
                print("csv done")
                //self.updateNVActivity(with:"Loading Exchanges")
                CompanyData().getInfo(galaxie: galaxie, debug: debug) { ( finished ) in // 1.3
                    if finished {
                        print("\n*** Company Info done ***\n")
                        //self.updateNVActivity(with:"Contacting NYSE")
                        IntrioFeed().getDataAsync(galaxie: galaxie, debug: debug) { ( finished ) in // 1.4
                            if finished {
                                print("intrinio done")
                                //self.updateNVActivity(with:"Loading Trend 1")
                                SMA().getData(galaxie: galaxie, debug: debug, period: 10, redoAll: true) { ( finished ) in // 2.0
                                    if finished {
                                        print("sma(10) done")
                                        //self.updateNVActivity(with:"Loading Trend 2")
                                        SMA().getData(galaxie: galaxie, debug: debug, period: 200, redoAll: true) { ( finished ) in // 2.0
                                            if finished {
                                                print("sma(200) done")
                                                //self.updateNVActivity(with:"Loading Oscilator")
                                                PctR().getwPctR(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                    if finished {
                                                        print("oscilator done")
                                                        //self.updateNVActivity(with:"Loading Market Condition")
                                                        MarketCondition().getMarketCondition(debug: debug, completion: { (finished) in
                                                            if finished  {
                                                                print("mc done")
                                                                //self.updateNVActivity(with:"Finding Trades")
                                                                Entry().getEveryEntry(galaxie: galaxie, debug: debug, completion: { (finished) in
                                                                    if finished  {
                                                                        print("Entry done")
                                                                        //self.updateNVActivity(with:"Brute Force Back Test")
                                                                        CalcStars().backtest(galaxie: galaxie, debug: debug, completion: {
                                                                            print("\ncalc Stars done!\n")
                                                                            //self.stopAnimating()
                                                                            //self.marketConditionUI(debug: false)
                                                                        })
                                                                    }
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
                    }
                }
            }
        }
    }
}
