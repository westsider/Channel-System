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
        self.dataFeed.getLastPrice(ticker: "AAPL", saveIt: false, debug: false){ ( doneWork ) in
            if doneWork {
                print("Price data loaded\n")
                for prices in self.dataFeed.lastPrice {
                    //print(prices.date! ,prices.open!, prices.high!, prices.low!, prices.close!)
                    print("\(prices.date!)\tO:\(prices.open!)\tH:\(prices.high!)\tL:\(prices.low!)\tC:\(prices.close!)")
                }
            }
        }
    }

}

