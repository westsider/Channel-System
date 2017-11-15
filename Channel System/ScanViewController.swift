//
//  ScanViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation

import UIKit
import RealmSwift
import Realm

class ScanViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var updateLable: UILabel!
    
    let dataFeed = DataFeed()
    
    let realm = try! Realm()
    
    let universe = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL"]

    var updateUI = ""
    
    var symbolCount = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLable.text = "Getting Closing Prices..."
RealmHelpers().deleteAll()
        ProcessCSV().loopThroughTickers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //getDataFromPriorDownload()
    }
    
    func getDataFromPriorDownload() {
        
        for symbols in universe {

            self.updateLable.text = "Getting CSV Data for \(symbols)..."
          
            dataFeed.getCsvData(ticker: symbols, debug: false){ ( doneWork ) in
                if doneWork {
                    self.symbolCount += 1
                    //self.updateLable.text = "All Symbols Retrieved!"
                    print("Data Retrieved for \(symbols)")
                    if ( self.symbolCount == self.universe.count ) {
                        self.activityIndicator.isHidden = true
                        self.fininsedCSVImport()
                    }
                    
                }
            }
        }
    }

    
    func getLiveData() {
        for (index, symbol) in universe.enumerated() {
            // counter += 1
            //MARK: - TODO update the lable not working
            updateUI = "\nDownloading \(symbol) \(index)"
            self.updateLable.text = updateUI; print(updateUI)
            self.updateLable.text = updateUI
            self.dataFeed.getLastPrice(ticker: symbol, saveIt: false, debug: false){ ( doneWork ) in
                if doneWork {
                    self.updateUI = "Finished downloading \(index) symbols..."
                    self.updateLable.text = self.updateUI; print(self.updateUI)
                    if ( index == self.universe.count-1 ) {
                        self.finishedScanning()
                    }
                }
            }
        }
    }
    
    func fininsedCSVImport() {
        print("\n**********   All Symbols Imported fromCSV   **********r\n")
        activityIndicator.isHidden = true
        dataFeed.separateSymbols(debug: false)
        dataFeed.calcIndicators()
        dataFeed.debugAllSortedPrices(on: false)
        self.updateLable.text = "Downloaded \(self.dataFeed.symbolArray.count) Tickers..."
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func finishedScanning() {
        
        print("\n**********   All Symbols downloaded   **********r\n")
        dataFeed.sortPrices(arrayToSort: dataFeed.lastPrice)
        //dataFeed.printThis(priceSeries: self.dataFeed.lastPrice)
        activityIndicator.isHidden = true
        dataFeed.separateSymbols(debug: false)
        dataFeed.calcIndicators()
        dataFeed.debugAllSortedPrices(on: true)
        self.updateLable.text = "Downloaded \(self.dataFeed.symbolArray.count) Tickers..."
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
    
}

