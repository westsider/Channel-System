//
//  PortfolioViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/8/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import RealmSwift

class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var tasks: Results<Entries>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = realm.objects(Entries.self)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = "\(tasks[indexPath.row].ticker)"
        cell.textLabel?.text = task
        
        let profit = tasks[indexPath.row].profit
        cell.detailTextLabel?.text = String(profit)
  
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        //selectedSymbol()
    }
    
//    func selectedSymbol() {
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
//        myVC.dataFeed = dataFeed
//        navigationController?.pushViewController(myVC, animated: true)
//    }
    
//    func debugDataSeries(on: Bool) {
//        if ( !on ) { return }
//        print("Price data loaded from Scan VC Total days: \(self.dataFeed.lastPrice .count)\n")
//        for prices in self.dataFeed.sortedPrices {
//            print("\(prices.date!)\t\(prices.ticker!)\to:\(prices.open!)\th:\(prices.high!)\tl:\(prices.low!)\tc:\(prices.close!) 10:\(prices.movAvg10!) %R:\(prices.wPctR!)")
//        }
//
//    }
 
}
