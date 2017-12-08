//
//  StatsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import SciChart
import RealmSwift
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
    
    var results: Results<WklyStats>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidAppear(_ animated: Bool) {
        getStatsfromRealm()
    }
    
    func ActivityOne(isOn:Bool) {
        DispatchQueue.main.async {
            if isOn {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func callChart() {
        ActivityOne(isOn: false)
        print("finished getting stats, calling build chart")
        getWeeklyFromRealm()
    }
    
    func getWeeklyFromRealm() {
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self)
        let sortedByDate = weeklyStats.sorted(byKeyPath: "date", ascending: true)
        if sortedByDate.count >  1 {
            results = sortedByDate
            print("We have  have weekly stats count > 1")
            print("now reading from realm count: \(sortedByDate.count)")
            for each in results! {
                print(each.date!, each.profit)
            }
            completeConfiguration()
        } else {
            print("count <= 1 weekly stats now calculating weekly stats")
            CumulativeProfit().weeklyProfit(debug: false)
            let loadWeekly = realm.objects(WklyStats.self)
            let sortedByDate = loadWeekly.sorted(byKeyPath: "date", ascending: true)
            results = sortedByDate
            
            print("now reading from realm count: \(sortedByDate.count)")
            for each in results! {
                print(each.date!, each.profit)
            }
            completeConfiguration()
        }
    }

    func getStatsfromRealm() {
        let realm = try! Realm()
        if let updateStats = realm.objects(Stats.self).last {
            print("getting saved stats from realm")
            DispatchQueue.main.async {
                self.topLeft.text = "$\(String(format: "%.0f", updateStats.grossProfit)) Profit"
                self.topRight.text = "\(String(format: "%.0f", updateStats.avgPctWin))% Wins"
                self.midLeft.text = "\(String(format: "%.1f", updateStats.avgROI))% Avg Roi "
                self.midRight.text = "\(String(format: "%.0f", updateStats.grossROI))% Gross Roi"
                self.bottomLeft.text = "\(String(format: "%.2f", updateStats.avgStars)) Avg Stars"
                self.bottomRight.text = "This is open"
                self.ActivityOne(isOn: false)
                self.callChart()
            }
        } else {
            print("did not find realm")
            calcStats(debug: false, completion: callChart)
        }
    }
    
    func calcStats(debug:Bool, completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for each in self.galaxie {
                let result:(Double, Double, Double, Double, Double) = BackTest().calcPastTradesForEach(ticker: each, debug: false, updateRealm: false)
                let stars:(Int,String) = BackTest().calcStars(grossProfit: result.0, annualRoi: result.3, winPct: result.4, debug: false)
                self.totalProfit.append(result.0)
                // calc performance on winners
                //if result.3 > 0 { I use this to find avg stars of winners
                self.self.averagePctWin.append(result.4)
                self.totalROI.append(result.3)
                self.averageStars.append(Double(stars.0))
                //}
               
            }
            let grossProfit:Double = self.totalProfit.reduce(0, +)
            let grossROI = self.totalROI.reduce(0, +)
            let avgROI = grossROI / Double( self.totalROI.count )
            let aPctWin = self.self.averagePctWin.reduce(0, +) / Double( self.averagePctWin.count )
            let avgStars = self.self.averageStars.reduce(0, +) / Double( self.averageStars.count )
            if debug {print("\nTotal Profit \(String(format: "%.0f", grossProfit)), Avg Pct Win \(String(format: "%.2f", aPctWin)), Avg ROI \(String(format: "%.2f", avgROI)), Total ROI \(String(format: "%.2f", grossROI)), Avg Stars \(String(format: "%.2f", avgStars))") }
            DispatchQueue.main.async {
                self.topLeft.text = "$\(String(format: "%.0f", grossProfit)) Profit"
                self.topRight.text = "\(String(format: "%.0f", aPctWin))% Wins"
                self.midLeft.text = "\(String(format: "%.1f", avgROI))% Avg Roi "
                self.midRight.text = "\(String(format: "%.0f", grossROI))% Gross Roi"
                self.bottomLeft.text = "\(String(format: "%.2f", avgStars)) Avg Stars"
                self.bottomRight.text = "This is open"
                //MARK: - Save stats to realm
                Stats().updateFinalTotal(grossProfit: grossProfit, avgPctWin: aPctWin, avgROI: avgROI, grossROI: grossROI, avgStars: avgStars)
                self.ActivityOne(isOn: false)
            }
            DispatchQueue.main.async {
                completion()
            }
        }
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
        for things in results! {
            lineDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.profit))
        }
        
        let lineRenderSeries = SCIFastLineRenderableSeries()
        lineRenderSeries.dataSeries = lineDataSeries
        lineRenderSeries.strokeStyle = SCISolidPenStyle(colorCode: 0xFF279B27, withThickness: 1.0)
        sciChartView1.renderableSeries.add(lineRenderSeries)
    }
    
}
