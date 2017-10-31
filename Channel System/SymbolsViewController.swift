//
//  SymbolsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit

class SymbolsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    
    var dataFeed = DataFeed()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Price data loaded from Scan VC Total days: \(self.dataFeed.lastPrice .count)\n")
        for prices in self.dataFeed.sortedPrices {
            print("\(prices.date!)\t\(prices.ticker!)\to:\(prices.open!)\th:\(prices.high!)\tl:\(prices.low!)\tc:\(prices.close!)")
        }
        titleArray.append((self.dataFeed.sortedPrices.last?.ticker)!)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = titleArray[indexPath.row]
        let close = (String(format: "%.2f", dataFeed.sortedPrices.last!.close!))
        cell.detailTextLabel?.text = close
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        selectedSymbol()
    }
    
    func selectedSymbol() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! ChartViewController
        myVC.dataFeed = dataFeed
        navigationController?.pushViewController(myVC, animated: true)
    }
}
