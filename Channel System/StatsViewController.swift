//
//  StatsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import SciChart

class StatsViewController: UIViewController {

    @IBOutlet weak var topLeft: UILabel!
    
    @IBOutlet weak var topRight: UILabel!
    
    @IBOutlet weak var midLeft: UILabel!
    
    @IBOutlet weak var midRight: UILabel!
    
    @IBOutlet weak var bottomLeft: UILabel!
    
    @IBOutlet weak var bottomRight: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var chartView: UIView!
    
    var galaxie = [String]()
    var totalProfit = [Double]()
    var averagePctWin = [Double]()
    var totalROI = [Double]()
    var averageStars = [Double]()
    let backTest = CumBackTest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidAppear(_ animated: Bool) {
        calcStats(debug: false)
        backTest.getdataforChart {
            self.makeChart()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func calcStats(debug:Bool) {
        for each in galaxie {
            let result:(Double, Double, Double, Double, Double) = BackTest().getResults(ticker: each, debug: false, updateRealm: false)
            let stars:(Int,String) = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
            totalProfit.append(result.0)
            // calc performance on winners
            //if result.3 > 0 { I use this to find avg stars of winners
            averagePctWin.append(result.4)
            totalROI.append(result.3)
            averageStars.append(Double(stars.0))
            //}
            
        }
        let grossProfit:Double = totalProfit.reduce(0, +)
        let grossROI = totalROI.reduce(0, +)
        let avgROI = grossROI / Double( totalROI.count )
        let aPctWin = averagePctWin.reduce(0, +) / Double( averagePctWin.count )
        let avgStars = averageStars.reduce(0, +) / Double( averageStars.count )
        if debug {print("\nTotal Profit \(String(format: "%.0f", grossProfit)), Avg Pct Win \(String(format: "%.2f", aPctWin)), Avg ROI \(String(format: "%.2f", avgROI)), Total ROI \(String(format: "%.2f", grossROI)), Avg Stars \(String(format: "%.2f", avgStars))") }
        
        topLeft.text = "$\(String(format: "%.0f", grossProfit)) Profit"
        topRight.text = "\(String(format: "%.0f", aPctWin))% Wins"
        midLeft.text = "\(String(format: "%.1f", avgROI))% Avg Roi "
        
        midRight.text = "\(String(format: "%.0f", grossROI))% Gross Roi"
        bottomLeft.text = "\(String(format: "%.2f", avgStars)) Avg Stars"
        bottomRight.text = "This is open"
        
    }
    
    func makeChart() {
        completeConfiguration()
    }

     var sciChartView1 = SCIChartSurface()
    
    // MARK: initialize surface
    fileprivate func addSurface() {
        sciChartView1 = SCIChartSurface(frame: self.chartView.bounds)
        sciChartView1.frame = self.chartView.bounds
        sciChartView1.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView1.translatesAutoresizingMaskIntoConstraints = true
        self.chartView.addSubview(sciChartView1)
    }
    
    // MARK: Overrided Functions
    func completeConfiguration() {
        addSurface()
        SCIUpdateSuspender.usingWithSuspendable(sciChartView1) {[unowned self] in
            self.addAxes()
            self.addSeries()
        }
    }
    
    // MARK: Private Functions
    fileprivate func addAxes() {
        let xAxis = SCICategoryDateTimeAxis()
        xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        sciChartView1.xAxes.add(xAxis)
        sciChartView1.yAxes.add(yAxis)
    }
    
    fileprivate func addSeries() {
        let lineDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        lineDataSeries.acceptUnsortedData = true
        for things in backTest.cumProfitWeelky {
            lineDataSeries.appendX(SCIGeneric(things.date), y: SCIGeneric(things.profit))
        }
        
        let lineRenderSeries = SCIFastLineRenderableSeries()
        lineRenderSeries.dataSeries = lineDataSeries
        lineRenderSeries.strokeStyle = SCISolidPenStyle(colorCode: 0xFF279B27, withThickness: 1.0)
        sciChartView1.renderableSeries.add(lineRenderSeries)
    }
    
}
