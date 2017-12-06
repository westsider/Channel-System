//
//  CandidatesVC.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//   open-source TA-Lib to integrate technical indicators to SciChart!

import UIKit
import RealmSwift

class SymbolsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var tasks: Results<Prices>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let days:Int = 1
        title = "last \(days) day(s)"
        tasks = Prices().sortEntriesBy(recent: true, days: days)
    }
    
    // Now settings for risk
    @IBAction func clearRealmAction(_ sender: Any) {
        //MARK: - TODO - mae alert view or side menue
    }
    
    @IBAction func showIndexAction(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = Prices().getLastTaskIDfrom(ticker: "SPY")
        navigationController?.pushViewController(myVC, animated: true)
    }
    // NOW Sugue to Portfolio
    @IBAction func readRealmContents(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PortfolioVC") as! PortfolioViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    
    @IBAction func showStats(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let ticker:String = tasks[indexPath.row].ticker
        cell.textLabel?.text = BackTest().tableViewString(ticker: ticker)
        
        let longDate:String = tasks[indexPath.row].dateString
        let date:String = String(longDate.dropFirst(5))
        let slash:String = date.replacingOccurrences(of: "-", with: "/")
        
        cell.detailTextLabel?.text = slash
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
