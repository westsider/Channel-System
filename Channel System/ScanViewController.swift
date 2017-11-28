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
    
    let csvBlock = { print( "\nData returned from CSV <----------\n" ) }
    let smaBlock1 = { print( "\nSMA calc finished 1 Calc Func first <----------\n" ) }
    let smaBlock2 = { print( "\nSMA calc finished 2 Main Func <----------\n" ) }
    let wPctRBlock = { print( "\nWpctR calc finished  <----------\n" ) }
    let entryBlock = { print( "\nEntry calc finished  <----------\n" ) }
    let datafeedBlock = { print( "\nDatafeed finished  <----------\n" ) }
    
    var counter = 0
    
    var updateRealm = false
    
    var lastDateInRealm:Date!
   
    var megaSymbols = [String]()
    
    let resetAll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkDuplicates() {
        megaSymbols = SymbolLists().uniqueElementsFrom(test3: true)
        for ticker in megaSymbols {
            Prices().findDuplicates(ticker: ticker, debug: true)
        }
    }
    
    func checkEarlyDates() {
        megaSymbols = SymbolLists().uniqueElementsFrom(test3: false)
        for ticker in megaSymbols {
            GetCSV().removeEarlyDates(ticker: ticker)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
                        //checkDuplicates()
                        //checkEarlyDates()
        // write an entry to test exits
        
        //MARK: - reset
        if ( resetAll ) {
            print("--> 0. <-- we are resetting")
            initially(deleteAll: true, printPrices: true, printTrades: false)
            megaSymbols = SymbolLists().uniqueElementsFrom(test3: false)
            initProgressBar()
            GetCSV().areTickersValid(megaSymbols: megaSymbols)
            getDataFromCSV(completion: self.csvBlock)
        }
        //MARK: - dont reset
        if ( !resetAll ) {
            let allCountRealm = Prices().allPricesCount()
            if ( allCountRealm  > 0 ) {
                print("--> 1. <-- Have Prices \(Prices().allPricesCount()) = check for new data")
                updateRealm = DateHelper().realmNotCurrent(debug: true)
                lastDateInRealm = Prices().getLastDateInRealm(debug: true) //- why do this twice?
                megaSymbols = SymbolLists().uniqueElementsFrom(test3: false)
                // not a good idea priorRealmCount = Prices().allPricesCount() / megaSymbols.count
        
            //MARK: - database not current - get new data
                if ( updateRealm ) {
                    getDataFromDataFeed(debug: false, completion: self.datafeedBlock)
            //MARK: - Prices current check for candidates
                } else {
                    //MARK: - search for trade management scenario else segue to candidates
                    manageTradesOrShowEntries()
                }

            } else {
            //MARK: - First run
                print("--> 2. <-- First Run, No Prices, get csv, calc SMA, segue to chart")
                initially(deleteAll: true, printPrices: false, printTrades: false)
                megaSymbols = SymbolLists().uniqueElementsFrom(test3: true)
                GetCSV().areTickersValid(megaSymbols: megaSymbols)
                getDataFromCSV(completion: self.csvBlock)
            }
        }

    }
    
    func initially(deleteAll: Bool, printPrices: Bool, printTrades: Bool){
        if ( deleteAll ) { RealmHelpers().deleteAll() }
        if ( printPrices ) { Prices().printLastPrices(symbols: megaSymbols, last: 4) }
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Getting local data for \(current) \(index+1) of \( self.megaSymbols.count)", spinIsOff: false)
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                self.updateUI(with: "Getting remote data for \(symbols) \(index+1) of \( self.megaSymbols.count)", spinIsOff: false)
                DataFeed().getLastPrice(ticker: symbols, lastInRealm: self.lastDateInRealm, debug: false, completion: {
                    self.counter += 1
                    if ( debug ) { print("\n----> counter: \(self.counter) universe: \(self.megaSymbols.count) <----\n") }
                    if ( self.counter == self.megaSymbols.count ) {
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                self.updateUI(with: "Processing SMA(10) for \(symbols) \(index+1) of \(self.megaSymbols.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 10, debug: false, priorCount: oneTicker.count, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(10) for \(symbols)", spinIsOff: true)
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                self.updateUI(with: "Processing SMA(200) for \(symbols) \(index+1) of \(self.megaSymbols.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                SMA().averageOf(period: 200, debug: false, priorCount: oneTicker.count, prices: oneTicker, completion: self.smaBlock1)
                self.updateUI(with: "Finished Processing SMA(200) for \(symbols)", spinIsOff: true)
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing PctR for \(current) \(index+1) of \(self.megaSymbols.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                PctR().williamsPctR(priorCount: oneTicker.count, debug: false, prices: oneTicker, completion: self.wPctRBlock)
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
            for ( index, symbols ) in self.megaSymbols.enumerated() {
                let current = symbols.replacingOccurrences(of: "2", with: "")
                self.updateUI(with: "Processing Entries for \(current) \(index+1) of \(self.megaSymbols.count)", spinIsOff: false)
                let oneTicker = self.prices.sortOneTicker(ticker: symbols, debug: false)
                Entry().calcLong(priorCount: oneTicker.count, debug: false, prices: oneTicker, completion: self.entryBlock)
                self.updateUI(with: "Finished Processing Entries for \(current)", spinIsOff: true)
                self.updateProgressBar()
            }
            DispatchQueue.main.async {
                completion()
                self.updateUI(with: "Processing Entries Complete", spinIsOff: true)
                print("\n-------> Now printing database <--------\n")
                Prices().printLastPrices(symbols: self.megaSymbols, last: 4)
                //self.segueToCandidatesVC()
                self.manageTradesOrShowEntries()
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
        let tickerCount = Double(megaSymbols.count)
        let processCount = Double(5)
        let divisor = Double(1)
        print("tickerCount \(tickerCount), processCount \(processCount), divisor \(divisor),")
        incProgress = Float( divisor / (tickerCount * processCount ) )
        print("\nProgress inc = \(incProgress)\n")
        progressView.setProgress(incProgress, animated: true)
        progressView.isHidden = false
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


