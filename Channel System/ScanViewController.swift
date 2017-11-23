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
    
    @IBOutlet weak var updateLable: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    let prices = Prices()
    
    var updatedProgress: Float = 0
    
    var incProgress: Float = 0
    
    let universe = ["SPY"] //, "QQQ","AAPL", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV"]
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProgressBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        //initially(deleteAll: true, printPrices: false, printTrades: false)
        //self.segueToCandidatesVC()
        //Prices().printAllPrices()
        
        //MARK: - Check for realm data
        if ( Prices().allPricesCount() > 0 ) {
            print("--> 1. <-- Have Prices \(Prices().allPricesCount()) = show chart")

            // check if today > newest dat in realm
            if (Prices().checkIfNew(date: Date(), debug: false)) {
                //MARK: - Get new prices from intrio
                getDataFromDataFeed(debug: false, completion: self.datafeedBlock)
            } else {
                //MARK: - search for trade management scenario else segue to candidates
                manageTradesOrShowEntries()
            }

        } else {
            print("--> 2. <-- No Prices, get csv, calc SMA, segue to chart")
            RealmHelpers().deleteAll()
            getDataFromCSV(completion: self.csvBlock)
        }
    }
    
    func initially(deleteAll: Bool, printPrices: Bool, printTrades: Bool){
        if ( deleteAll ) { RealmHelpers().deleteAll() }
        if ( printPrices ) { Prices().printAllPrices() }
        if ( printTrades ) { RealmHelpers().printOpenTrades() }
    }
    
    //MARK: - Trade Management
    func manageTradesOrShowEntries() {
        // search for trade management scenario else segue to candidates
        let tasks = RealmHelpers().getOpenTrades()
        print("Open trade count is \(tasks.count)")
        if ( tasks.count > 0) {
            for trades in tasks {
                //MARK: - TODO - Check if stop
                if trades.close < trades.stop {
                    print("\nStop Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Stop")
                }
                //MARK: - TODO - Check if target
                if trades.close > trades.target {
                    print("\nTarget Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Target")
                }
                if trades.wPctR > -30 {
                    print("\nwPctR Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Pct(R) Target")
                }
                //MARK: - TODO - Set up exit date on entry
                if Date() >= trades.exitDate {
                    print("\nTime Stop Hit for \(trades.ticker) from \(trades.dateString)\n")
                    segueToManageVC(taskID: trades.taskID, action: "Date Stop")
                }
                self.updateProgressBar()
            }
        } else {
            // exit here if no entries found
            segueToCandidatesVC()
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    //MARK: - Get Data From CSV
    func getDataFromCSV(completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Getting local data for \(current) \(index+1) of \( self.universe.count)", spinIsOff: false)
                DataFeed().getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.csvBlock)
                self.updateProgressBar()
            }
            self.updateUI(with: "All tickers have been downloaded!", spinIsOff: true)
            self.calcSMA10(completion: self.smaBlock2)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - Get Data From Datafeed
    func getDataFromDataFeed(debug: Bool, completion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Getting remote data for \(current) \(index+1) of \( self.universe.count)", spinIsOff: false)
                DataFeed().getLastPrice(ticker: symbols, debug: true, completion: {
                    self.counter += 1
                    if ( debug ) { print("\n----> counter: \(self.counter) universe: \(self.universe.count) <----\n") }
                    if ( self.counter == self.universe.count ) {
                        self.updateUI(with: "All remote data has been downloaded!\n", spinIsOff: true)
                        self.calcSMA10(completion: self.smaBlock2)
                    }
                })
                self.updateProgressBar()
            }
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: - SMA 10
    func calcSMA10(completion: @escaping () -> ()) {
        self.updateUI(with: "Calulating SMA(10)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing SMA(10) for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(10) for \(current)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(10) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcSMA200(completion: self.smaBlock2)
            }
        }
    }
    //MARK: - SMA 200
    func calcSMA200(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing SMA(200)...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing SMA(200) for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(200) for \(current)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SMA(200) Complete", spinIsOff: true)
                print("\nSegue to Charts\n")
                self.calcwPctR(completion: self.wPctRBlock)
            }
        }
    }
    //MARK: - wPctR
    func calcwPctR(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing PctR...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing PctR for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(debug: false, prices: oneTicker, completion: self.wPctRBlock)
                self.updateUI(with: "Finished Processing PctR for \(current)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing SPctR Complete", spinIsOff: true)
                self.calcEntries(completion: self.entryBlock)
            }
        }
    }
    //MARK: - Entries
    func calcEntries(completion: @escaping () -> ()) {
        self.updateUI(with: "Processing Entries...", spinIsOff: false)
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing Entries for \(current) \(index+1) of \(self.universe.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                Entry().calcLong(debug: false, prices: oneTicker, completion: self.entryBlock)
                self.updateUI(with: "Finished Processing Entries for \(current)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing Entries Complete", spinIsOff: true)
                //let tickerToSend = self.universe[1]
                //print("\nSegue to Candidates with \(tickerToSend)\n")
                self.segueToCandidatesVC()
            }
        }
    }
    
    func updateProgressBar() {
        DispatchQueue.main.async {
            self.updatedProgress += self.incProgress
            self.progressView.progress = self.updatedProgress
        }
    }
    
    func updateUI(with: String, spinIsOff: Bool) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
        }
    }
    
    func initProgressBar() {
        let tickerCount = Float(universe.count)
        let processCount = Float(5)
        let divisor = Float(1)
        incProgress = Float( divisor / (tickerCount * processCount ) )
        print("\nProgress inc = \(incProgress)\n")
        progressView.setProgress(incProgress, animated: true)
    }

    func segueToChart(ticker: String) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = Prices().getLastTaskID()
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func segueToCandidatesVC() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    func segueToManageVC(taskID: String, action: String) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ManageVC") as! ManageViewController
        myVC.taskID = taskID
        myVC.action = action
        navigationController?.pushViewController(myVC, animated: true)
    }
}


