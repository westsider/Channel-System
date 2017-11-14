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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var updateLable: UILabel!
    
    let dataFeed = DataFeed()
    
    let realm = try! Realm()
    
    let universe = ["SPY", "QQQ"] //, "DIA"] //, "MDY", "IWM", "EFA", "ILF", "EEM", "EPP",  "IEV"]

    override func viewDidLoad() {
        super.viewDidLoad()
 
        for (index, symbol) in universe.enumerated() {
           // counter += 1
            //MARK: - TODO update the lable not working
            let updateUI = "\nDownloading \(symbol) \(index)"
            print(updateUI)
            self.updateLable.text = updateUI
            self.dataFeed.getLastPrice(ticker: symbol, saveIt: false, debug: false){ ( doneWork ) in
                if doneWork {
                    print("Finished downloading \(symbol)\n")
                    if ( index == self.universe.count-1 ) {
                        self.finishedScanning()
                    }
                }
            }
        }
    }
    
    
    func finishedScanning() {
        
        print("\n**********   All Symbols downloaded   **********r\n")
        dataFeed.sortPrices(arrayToSort: dataFeed.lastPrice)
        //dataFeed.printThis(priceSeries: self.dataFeed.lastPrice)
        activityIndicator.isHidden = true
        dataFeed.separateSymbols(debug: false)
        //dataFeed.calcIndicators()
        dataFeed.debugAllSortedPrices(on: true)
        self.updateLable.text = "Downloaded \(self.dataFeed.symbolArray.count) Tickers..."
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
    
}

