//
//  ScanViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class ScanViewController: UIViewController {

    let dataFeed = DataFeed()
    
    let realm = try! Realm()
    
    let universe = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP",  "IEV"]

    override func viewDidLoad() {
        super.viewDidLoad()
        getLatestsPrices(ticker: "AAPL")
    }
    
    func getLatestsPrices(ticker:String) {
        for page in 1...3 {
            self.dataFeed.getLastPrice(ticker: ticker, page: page, saveIt: false, debug: false){ ( doneWork ) in
                if doneWork {
                    if ( self.dataFeed.lastPrice.count == 300) {
                        self.finishedScanning()
                    }
                }
            }
        }
    }
    
    func finishedScanning() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
    
}

