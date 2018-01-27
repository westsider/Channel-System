//
//  PortfolioViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/8/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var openTradesBttnTxt: UIButton!
    let realm:Realm = try! Realm()
    var tasks: Results<Prices>!
    var showClosedTrades = false
    var costStr:String = "nan"
    var costDict: [String:Double] = [:]
    var action = "Target"
    var showTrailStop:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = RealmHelpers().getOpenTrades()
        TradeManage().printOpenTrades()
        title = "Portfolio"
        let portfolioCost = RealmHelpers().calcPortfolioCost()
        costStr = Utilities().dollarStr(largeNumber: portfolioCost)
        costDict = RealmHelpers().portfolioDict()
    }
    
    @IBAction func portfolioSwitch(_ sender: UIButton) {
        let title = activateButton(bool: !showClosedTrades)
        sender.setTitle(title.0, for: [])
        sender.setTitleColor(title.1, for: [])
        sender.backgroundColor = title.2
        tableView.reloadData()
    }
    
    func activateButton(bool: Bool)-> (String, UIColor, UIColor) {
        showClosedTrades = bool
        showTrailStop = !bool
        let onColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        let offColor = #colorLiteral(red: 0.3489862084, green: 0.3490410447, blue: 0.3489741683, alpha: 0)
        let onTitle = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let offTitle = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        //let color = bool ? onColor : offColor
        let title = bool ? "Closed" : "Open"
        let titleColor = bool ? onTitle : offTitle
        let bkgColor = bool ? onColor : offColor
        tasks = bool ? RealmHelpers().getClosedTrades() : RealmHelpers().getOpenTrades()
        
        print("ahowClosedTrades \(showClosedTrades)")
        for each in tasks {
            
            print("\(each.dateString)\t\(each.ticker)")
        }
        
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
        var cost:String = "N/A"
        if !showClosedTrades {
            cost = Utilities().dollarStr(largeNumber: costDict[tasks[indexPath.row].ticker]!) } else {
            cost = Utilities().dollarStr(largeNumber: tasks[indexPath.row].capitalReq)
        }
        let task:String = "\(shortDate) \t\(tasks[indexPath.row].ticker) \t\(closeString) \t$\(cost)"
        cell.textLabel?.text = task
        
        var profit:Double = 0.0
        
        // showing open trades
        if !showClosedTrades {
            profit = ((thisSymbol!.close - tasks[indexPath.row].entry)) * Double(tasks[indexPath.row].shares)
            //print("profit: \(profit) = close: \(thisSymbol!.close) - entry: \(tasks[indexPath.row].entry) * shares: \(Double(tasks[indexPath.row].shares))")
        } else {
            // showing closed trades
            profit = (tasks[indexPath.row].profit)
        }
        let profitStr = "\(String(format: "%.2f", profit)) profit"
        cell.detailTextLabel?.text = profitStr
        
        if profit < 0 {
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.contentView.backgroundColor = UIColorScheme().activeCell
        }
        print("\(tasks[indexPath.row].ticker)\t\(date)\t\(profit)")
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // showing open trades
        if !showClosedTrades {
            let openProfit = TradeHelpers().totalOpenProfit(tasks: tasks, debug: false)
            return "$\(openProfit.0) Profit \t\(openProfit.1)% Win \t$\(costStr) Comitted"
        } else {
            let openProfit = TradeHelpers().totalClosedProfit(tasks: tasks, debug: false)
            return "$\(openProfit.0) profit \t\(openProfit.1)% win"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColorScheme().activeCell
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name: "PingFang HK", size: 20)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row \(indexPath.row)")
        segueToChart(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //MARK: - Swipe left to delete old trade if isOn bool is true
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if showClosedTrades {
            if editingStyle == .delete {
                print("swipe left on \(tasks[indexPath.row].taskID)")
                RealmHelpers().deleteClosedTrade(taskID: tasks[indexPath.row].taskID, debug: false)
                tasks = RealmHelpers().getClosedTrades()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
       }
    }
    
    func segueToChart(index: Int) {
        let myVC:SCSSyncMultiChartView = storyboard?.instantiateViewController(withIdentifier: "ChartVC") as! SCSSyncMultiChartView
        myVC.taskIdSelected = tasks[index].taskID
        myVC.maxBarsOnChart = 30
        myVC.showTrailStop = true
        myVC.entryDate = tasks[index].dateString
        myVC.action = action
        myVC.showTrailStop = showTrailStop
        print("portfolio segue to chart. sending action \(action)")
        navigationController?.pushViewController(myVC, animated: true)
    }
}
