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
import CSV

class ScanViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var updateLable: UILabel!
    
    let dataFeed = DataFeed()
    
    let realm = try! Realm()
    
    let universe = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLable.text = "Getting Closing Prices..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        RealmHelpers().deleteAll()
        
        let block = { self.updateLable(with: "Data from CSV Complete" ) }
        
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                self.getPricesFromCSV( count: index, total: self.universe.count-1, ticker: symbols, debug: true, completion: block)
            }
            DispatchQueue.main.async { self.activityIndicator.isHidden = true }
        }
    }
    // update UI on main thread
    func updateLable(with: String) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
        }
    }
        
    func getPricesFromCSV(count: Int, total: Int, ticker: String,debug: Bool, completion: @escaping () -> ()) {
        // update UI on start
        updateLable(with: "Getting data for \(ticker) \(count) of \(total)")
        
        // the call to csv
        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
        let stream = InputStream(fileAtPath: filleURLProject!)!
        let csv = try! CSVReader(stream: stream)
        //"date","close","volume","open","high","low"
        while let row = csv.next() {
            if ( debug ) { print("\(row)") }
            let lastPriceObject = LastPrice()
            
            lastPriceObject.ticker = ticker
            
            let date = row[0]
            lastPriceObject.dateString = date
            lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
            
            if let open = Double(row[3]) {
                lastPriceObject.open = open }
            
            if let high = Double(row[4]){
                lastPriceObject.high = high }
            
            if let low = Double(row[4]){
                lastPriceObject.low = low }
            
            if let close = Double(row[1]){
                lastPriceObject.close = close }
            //self.lastPrice.append(lastPriceObject)
        }
        // update  UI on completion
        DispatchQueue.main.async {
            completion()
            self.updateLable(with: "Data complete for \(ticker) \(count) of \(total)")
            if ( count == total ) {
                self.updateLable(with: "All tickers have been downloaded!")
            }
        }
     }
}




//    func getCsvData(ticker: String, debug: Bool, doneWork: @escaping (Bool) -> Void ) {
//
//        doneWork(false)
//
//
//        let filleURLProject = Bundle.main.path(forResource: ticker, ofType: "csv")
//        let stream = InputStream(fileAtPath: filleURLProject!)!
//        let csv = try! CSVReader(stream: stream)
//        //"date","close","volume","open","high","low"
//        while let row = csv.next() {
//            if ( debug ) { print("\(row)") }
//            let lastPriceObject = LastPrice()
//
//            lastPriceObject.ticker = ticker
//
//            let date = row[0]
//            lastPriceObject.dateString = date
//            lastPriceObject.date = DateHelper().convertToDateFrom(string: date, debug: false)
//
//            if let open = Double(row[3]) {
//                lastPriceObject.open = open }
//
//            if let high = Double(row[4]){
//                lastPriceObject.high = high }
//
//            if let low = Double(row[4]){
//                lastPriceObject.low = low }
//
//            if let close = Double(row[1]){
//                lastPriceObject.close = close }
//
//            //self.lastPrice.append(lastPriceObject)
//        }
//        //self.sortPrices(arrayToSort: self.lastPrice)
//
//        DispatchQueue.main.async {
//            doneWork(true)
//        }
//
//        // need to separate symbols
//    }
    
    
    
    

    
//    func getLiveData() {
//        for (index, symbol) in universe.enumerated() {
//            // counter += 1
//            //MARK: - TODO update the lable not working
//            updateUI = "\nDownloading \(symbol) \(index)"
//            self.updateLable.text = updateUI; print(updateUI)
//            self.updateLable.text = updateUI
//            self.dataFeed.getLastPrice(ticker: symbol, saveIt: false, debug: false){ ( doneWork ) in
//                if doneWork {
//                    self.updateUI = "Finished downloading \(index) symbols..."
//                    self.updateLable.text = self.updateUI; print(self.updateUI)
//                    if ( index == self.universe.count-1 ) {
//                        self.finishedScanning()
//                    }
//                }
//            }
//        }
//    }
//
//    func fininsedCSVImport() {
//        print("\n**********   All Symbols Imported fromCSV   **********r\n")
//        activityIndicator.isHidden = true
//        dataFeed.separateSymbols(debug: false)
//        dataFeed.calcIndicators()
//        dataFeed.debugAllSortedPrices(on: false)
//        self.updateLable.text = "Downloaded \(self.dataFeed.symbolArray.count) Tickers..."
//
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
//        //myVC.dataFeed = dataFeed
//        navigationController?.pushViewController(myVC, animated: true)
//    }
//
//    func finishedScanning() {
//
//        print("\n**********   All Symbols downloaded   **********r\n")
//        dataFeed.sortPrices(arrayToSort: dataFeed.lastPrice)
//        //dataFeed.printThis(priceSeries: self.dataFeed.lastPrice)
//        activityIndicator.isHidden = true
//        dataFeed.separateSymbols(debug: false)
//        dataFeed.calcIndicators()
//        dataFeed.debugAllSortedPrices(on: true)
//        self.updateLable.text = "Downloaded \(self.dataFeed.symbolArray.count) Tickers..."
//
//
//    }
//
//    func segueToCandidatesVC() {
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
//       // myVC.dataFeed = dataFeed
//        navigationController?.pushViewController(myVC, animated: true)
//    }
    


