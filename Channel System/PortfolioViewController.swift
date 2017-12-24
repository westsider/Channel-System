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
    
    let realm:Realm = try! Realm()
    
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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task:String = "\(tasks[indexPath.row].ticker)"
        cell.textLabel?.text = task
       
        let profit:Double = (tasks[indexPath.row].entry - tasks[indexPath.row].close) * Double(tasks[indexPath.row].shares)
         print("\nHere is the entry price \(tasks[indexPath.row].entry) and close \(tasks[indexPath.row].close) shares \(tasks[indexPath.row].shares) and profit \(profit)")
        cell.detailTextLabel?.text = (String(format: "%.2f", profit))
        if profit < 0 {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        selectedSymbol(index: indexPath.row)
    }
    
    func selectedSymbol(index: Int) {
        let myVC:SCSSyncMultiChartView = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = tasks[index].taskID
        navigationController?.pushViewController(myVC, animated: true)
    }
}
