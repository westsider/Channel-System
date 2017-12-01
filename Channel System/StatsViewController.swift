//
//  StatsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var topLeft: UILabel!
    
    @IBOutlet weak var topRight: UILabel!
    
    @IBOutlet weak var midLeft: UILabel!
    
    @IBOutlet weak var midRight: UILabel!
    
    @IBOutlet weak var bottomLeft: UILabel!
    
    @IBOutlet weak var bottomRight: UILabel!
    
    
    var galaxie = [String]()
    var totalProfit = [Double]()
    var averagePctWin = [Double]()
    var totalROI = [Double]()
    var averageStars = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
        calcStats()
    }

    func calcStats() {
        for each in galaxie {
            let report = BackTest().performanceString(ticker: each, debug: false)
            print(report)
            let result = BackTest().getResults(ticker: each, debug: false)
            let stars = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
            totalProfit.append(result.0)
            // calc performance on winners
            //if result.3 > 0 { I use this to find avg stars of winners
            averagePctWin.append(result.4)
            totalROI.append(result.3)
            averageStars.append(Double(stars.0))
            //}
            
        }
        let grossProfit = totalProfit.reduce(0, +)
        let grossROI = totalROI.reduce(0, +)
        let avgROI = grossROI / Double( totalROI.count )
        let aPctWin = averagePctWin.reduce(0, +) / Double( averagePctWin.count )
        let avgStars = averageStars.reduce(0, +) / Double( averageStars.count )
        print("\nTotal Profit \(String(format: "%.0f", grossProfit)), Avg Pct Win \(String(format: "%.2f", aPctWin)), Avg ROI \(String(format: "%.2f", avgROI)), Total ROI \(String(format: "%.2f", grossROI)), Avg Stars \(String(format: "%.2f", avgStars))")
        
        topLeft.text = "Total Profit \(String(format: "%.0f", grossProfit))"
        topRight.text = "Avg Pct Win \(String(format: "%.2f", aPctWin))"
        midLeft.text = "Avg ROI \(String(format: "%.2f", avgROI))"
        
        midRight.text = "Total ROI \(String(format: "%.2f", grossROI))"
        bottomLeft.text = "Avg Stars \(String(format: "%.2f", avgStars))"
        bottomRight.text = "This is open"
        
    }
    
    //MARK: - TODO - Stats VC scrollview of: stats as lables at top, graph p&L, sorted tableview,
    /*
     Total Profit 100627,   Avg Pct Win 65.94,
     Avg ROI 2.78,          Total ROI 513.61,
     Avg Stars 3.31
     */
    //MARK: - TODO - save to realm STATS object
    //MARK: - TODO - load with candidates tableview | SPY 70% $11,021 18.7% ROI ⭐️⭐️⭐️⭐️⭐️ |
    //MARK: - TODO - add STATS to PRICES object when loadDataFeed
    
}
