//
//  SymbolsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//   open-source TA-Lib to integrate technical indicators to SciChart!

import UIKit

class SymbolsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var dataFeed = DataFeed()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        for tickers in self.dataFeed.allSortedPrices {
//            for items in tickers {
//                //symbol = items.ticker!.last
//                titleArray.append(items.ticker!)
//                closeArray.append(items.close!)
//                print("Appending: \(items.dateString!) \(items.ticker!) and \(items.close!)")
//            }
//            print("titles count:\(titleArray.count) closes: \(closeArray.count)")
//        }
        
       
        
        //titleArray.append((self.dataFeed.sortedPrices.last?.ticker)!)
    }
    
    @IBAction func clearRealmAction(_ sender: Any) {
        RealmHelpers().deleteAll()
    }
    
    // NOW Sugue to Portfolio
    @IBAction func readRealmContents(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PortfolioVC") as! PortfolioViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataFeed.symbolArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataFeed.symbolArray[indexPath.row]
        cell.detailTextLabel?.text = "Buy Signal"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        selectedSymbol(index: indexPath.row)
    }
    
    func selectedSymbol(index: Int) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.dataFeed = dataFeed
        myVC.indexSelected = index
        navigationController?.pushViewController(myVC, animated: true)
    }

}
