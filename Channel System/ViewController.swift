//
//  ViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class ViewController: UIViewController {

    let dataFeed = DataFeed()
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for page in 1...3 {
            self.dataFeed.getLastPrice(ticker: "AAPL", page: page, saveIt: false, debug: true){ ( doneWork ) in
                if doneWork {
                    print("Page \(page) price data loaded. Total days: \(self.dataFeed.lastPrice .count)\n")
                    for prices in self.dataFeed.sortedPrices {
                        print("\(prices.date!)\tO:\(prices.open!)\tH:\(prices.high!)\tL:\(prices.low!)\tC:\(prices.close!)")
                    }
                   
                }
            }
        }
    }
    
}

