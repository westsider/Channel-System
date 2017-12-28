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
    var isOn = false
    
    @IBOutlet weak var openTradesBttnTxt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = RealmHelpers().getOpenTrades()
        TradeManage().printOpenTrades()
        title = "Portfolio"
        
    }
    
    
    @IBAction func portfolioSwitch(_ sender: UIButton) {
        let title = activateButton(bool: !isOn)
        sender.setTitle(title.0, for: [])
        sender.setTitleColor(title.1, for: [])
        sender.backgroundColor = title.2
        tableView.reloadData()
    }
    
    func activateButton(bool: Bool)-> (String, UIColor, UIColor) {
        isOn = bool
        let onColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        let offColor = #colorLiteral(red: 0.3489862084, green: 0.3490410447, blue: 0.3489741683, alpha: 0)
        let onTitle = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let offTitle = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        let color = bool ? onColor : offColor
        let title = bool ? "Closed" : "Open"
        let titleColor = bool ? onTitle : offTitle
        let bkgColor = bool ? onColor : offColor

        tasks = bool ? RealmHelpers().getClosedTrades() : RealmHelpers().getOpenTrades()
        print(isOn,color, title, titleColor)
        return (title, titleColor, bkgColor)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let date = tasks[indexPath.row].dateString
        let shortDate = date.dropFirst(5)
        let thisSymbol = Prices().sortOneTicker(ticker: tasks[indexPath.row].ticker, debug: false).last
        let closeString = String(format: "%.2f", (thisSymbol?.close)!)
        let task:String = "\(shortDate) \t\(tasks[indexPath.row].ticker) \t\(closeString)"
        cell.textLabel?.text = task
       
        let profit:Double = (thisSymbol!.close - tasks[indexPath.row].entry) * Double(tasks[indexPath.row].shares)
        print("\n\(tasks[indexPath.row].ticker) entry: \(tasks[indexPath.row].entry) and close \(thisSymbol!.close) shares \(tasks[indexPath.row].shares) and profit \(profit)")
        cell.detailTextLabel?.text = (String(format: "%.2f", profit))
        
        if profit < 0 {
            cell.contentView.backgroundColor = UIColorScheme().alertCell
        } else {
            cell.contentView.backgroundColor = UIColorScheme().activeCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let openProfit = totalOpenProfit()
        return "$\(openProfit.0) profit \t\(openProfit.1)% win"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColorScheme().activeCell
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name: "PingFang HK", size: 20)
    }
    
    func totalOpenProfit()->(String,String) {
        var sum = 0.00
        var wins = 0.00
        for each in tasks {
            let thisSymbol = Prices().sortOneTicker(ticker: each.ticker, debug: false).last
            let profit:Double = (thisSymbol!.close - each.entry ) * Double(each.shares)
            print("\(each.ticker) profit: \(String(format: "%.2f", profit)) = c:\(thisSymbol!.close) - e:\(each.entry) * s:\(each.shares)")
            sum += profit
            if profit > 0 {
                wins += 1
            }
        }
        let winPct = (wins / Double(tasks.count)) * 100
        let winPctStr = String(format: "%.2f", winPct)
        return (String(format: "%.2f", sum), winPctStr)
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
