//
//  ScanViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
import Foundation
import RealmSwift
import UIKit

class ScanViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var updateLable: UILabel!
    
    let dataFeed = DataFeed()
    
    let prices = Prices()
    
    let universe = ["SPY2", "QQQ2"] //, "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL"]
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//RealmHelpers().deleteAll()
        //let realm = try! Realm()
        let priceCount = prices.allPricesCount()

        if ( priceCount > 0 ) {
            print("--> 1. <-- Have Prices = show chart")
            // show chart
            selectedSymbol(ticker: universe[0])
        } else {
            print("--> 2. <-- No Prices, get csv, calc SMA, segue to chart")
            RealmHelpers().deleteAll()
            getDataFromCSV(completion: self.csvBlock)
        }
        
        let newPriceCount = prices.allPricesCount()
        print("\n-----> Check if cal indicators adds any prices <-----\nold count \(priceCount) new count \(newPriceCount)\n")
    }
    
    func calcSMA(completion: @escaping () -> ()) {
        self.updateLable(with: "Calulating Indicators...")
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
        }
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateLable(with: "Starting Sma Clac for \(current) \(index+1) of \(self.universe.count)")
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, prices: oneTicker, completion: self.smaBlock1)
                self.updateLable(with: "Finished Sma Clac for \(current)")
            }
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            print("Can I go to chart here in SMA after func call?")
            DispatchQueue.main.async {
                completion()
                self.updateLable(with: "Calulating Indicators Complete")
                print("\nSegue to Charts\n")
                self.selectedSymbol(ticker: self.universe[1])
            }
        }
    }
    
    func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateLable(with: "Getting data for \(current) \(index+1) of \( self.universe.count)")
                self.dataFeed.getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
            }
            DispatchQueue.main.async { self.activityIndicator.isHidden = true }
            self.updateLable(with: "All tickers have been downloaded!")
            self.calcSMA(completion: self.smaBlock2)
            
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func updateLable(with: String) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
        }
    }

    func selectedSymbol(ticker: String) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        //myVC.dataFeed = dataFeed
        myVC.tickerSelected = ticker
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func segueToCandidatesVC() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
       // myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
}


