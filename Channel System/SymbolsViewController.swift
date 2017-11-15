//
//  SymbolsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//   open-source TA-Lib to integrate technical indicators to SciChart!

import UIKit
import RealmSwift

class SymbolsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    //var dataFeed = DataFeed()
    
    let realm = try! Realm()
    
    var tasks: Results<Prices>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = getEntriesFromRealm(debug: true)
    }
    
    func getEntriesFromRealm(debug: Bool)-> Results<Prices> {
        // get objects // filter onbjects
        let id = true
        let allEntries = realm.objects(Prices.self).filter("longEntry == %@", id)
        let sortedByDate = allEntries.sorted(byKeyPath: "date", ascending: false)
        if ( debug ) {
            for entries in sortedByDate {
                print("\(entries.ticker) \(entries.dateString)")
            }
        }
        return sortedByDate
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
        return tasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].ticker
        cell.detailTextLabel?.text = tasks[indexPath.row].dateString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        selectedSymbol(index: indexPath.row)
    }
    
    func selectedSymbol(index: Int) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        //myVC.dataFeed = dataFeed
        myVC.indexSelected = index
        navigationController?.pushViewController(myVC, animated: true)
    }

}
