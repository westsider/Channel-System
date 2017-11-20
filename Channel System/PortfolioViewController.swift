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
    
    var tasks: Results<Prices>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = RealmHelpers().getOpenTrades()
        TradeManage().printOpenTrades()
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
        selectedSymbol(index: indexPath.row)
    }
    
    func selectedSymbol(index: Int) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = tasks[index].taskID
        navigationController?.pushViewController(myVC, animated: true)
    }
}
