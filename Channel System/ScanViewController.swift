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
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//RealmHelpers().deleteAll()
        
        let priceCount = prices.allPricesCount()

        if ( priceCount > 0 ) {
            print("--> 1. <-- Have Prices = show chart")
            // show chart
            selectedSymbol(ticker: universe[1])
        } else {
            print("--> 2. <-- No Prices, get csv, calc SMA, segue to chart")
            RealmHelpers().deleteAll()
            getDataFromCSV(completion: self.csvBlock)
        }
    }
    
    func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Getting data for \(current) \(index+1) of \( self.universe.count)", spinIsOff: false)
                self.dataFeed.getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
            }
            DispatchQueue.main.async { self.activityIndicator.isHidden = true }
            self.updateUI(with: "All tickers have been downloaded!", spinIsOff: true)
            self.calcSMA10(completion: self.smaBlock2)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    //MARK: - TODO - Construct all indicators
    func calcSMA10(completion: @escaping () -> ()) {
        self.updateUI(with: "Calulating SMA(10)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing SMA(10) for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(10) for \(current)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(10) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcSMA200(completion: self.smaBlock2)
            }
        }
    }
    
    func calcSMA200(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing SMA(200)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing SMA(200) for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(200) for \(current)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(200) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcwPctR(completion: self.smaBlock2)
            }
        }
    }
    
    func calcwPctR(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing PctR...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing PctR for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(debug: false, prices: oneTicker, completion: self.wPctRBlock)
                self.updateUI(with: "Finished Processing PctR for \(current)", spinIsOff: true)
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SPctR Complete", spinIsOff: true)
                let tickerToSend = self.universe[1]
                print("\nSegue to Charts with \(tickerToSend)\n")
                self.selectedSymbol(ticker: tickerToSend)
            }
        }
    }
    
    func updateUI(with: String, spinIsOff: Bool) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
            self.activityIndicator.isHidden = spinIsOff
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


