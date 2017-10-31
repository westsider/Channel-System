//
//  SymbolsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit

class SymbolsViewController: UIViewController {
    
    var dataFeed = DataFeed()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Price data loaded from Scan VC Total days: \(self.dataFeed.lastPrice .count)\n")
        for prices in self.dataFeed.sortedPrices {
            print("\(prices.date!)\t\(prices.ticker!)\to:\(prices.open!)\th:\(prices.high!)\tL:\(prices.low!)\tC:\(prices.close!)")
        }
    }


    


}
