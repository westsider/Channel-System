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
    
    let universe = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL"]
    
    let block = { print( "\nData returned from CSV <----------\n" ) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //let realm = try! Realm()
        let priceCount = prices.allPricesCount()

        if ( priceCount > 0 ) {
            self.updateLable(with: "Historical Data Found")
            activityIndicator.isHidden = true
            let oneTicker = prices.sortOneTicker(ticker: universe[0], debug: true)
   
            // calc SMA 10 on Spy
            // Print results
            // show chart
        } else {
            RealmHelpers().deleteAll()
            getDataFromCSV()
        }
    }
    
    func getDataFromCSV() {
        DispatchQueue.global(qos: .background).async {
            for ( index, symbols ) in self.universe.enumerated() {
                self.updateLable(with: "Getting data for \(symbols) \(index) of \( self.universe.count-1)")
                self.dataFeed.getPricesFromCSV(count: index, ticker: symbols, debug: false, completion: self.block)
            }
            DispatchQueue.main.async { self.activityIndicator.isHidden = true }
            self.updateLable(with: "All tickers have been downloaded!")
        }
    }
    
    func updateLable(with: String) {
        DispatchQueue.main.async {
            print(with)
            self.updateLable?.text =  with
        }
    }

    func segueToCandidatesVC() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "SymbolsVC") as! SymbolsViewController
       // myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
}


