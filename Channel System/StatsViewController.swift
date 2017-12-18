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
    
    @IBOutlet weak var largestWinLabel: UILabel!
    
    @IBOutlet weak var largestLossLabel: UILabel!
    
    @IBOutlet weak var tradingDaysLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityIndicatorTwo: UIActivityIndicatorView!
    
    @IBOutlet weak var chartView: UIView!
    
    @IBOutlet weak var backtestButton: UIButton!
    
    @IBOutlet weak var graphButton: UIButton!
    
    var galaxie = [String]()
    var totalProfit = [Double]()
    var averagePctWin = [Double]()
    var totalROI = [Double]()
    var averageStars = [Double]()
    var results: Results<WklyStats>?
    let barsToShow:Int = 125
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        getStatsfromRealm()
    }
    
    // need completion handler for this
    @IBAction func runNewBacktestAction(_ sender: Any) {
        self.topLeft.textAlignment = .right
        ActivityOne(isOn:true)
        calcStats(debug: false, completion: callChart)
    }
    
    @IBAction func runNewChartCalc(_ sender: Any) {
        self.topLeft.alpha = 0.1
        self.topRight.alpha = 0.1
        self.backtestButton.alpha = 0.2
        self.graphButton.alpha = 0.2
        self.largestWinLabel.alpha = 0.2
        self.largestLossLabel.alpha = 0.2
        self.tradingDaysLabel.alpha = 0.2
        ActivityOne(isOn:true)
        textAlpha(isNow: 0.1)
        DispatchQueue.global(qos: .background).async {
            CumulativeProfit().weeklyProfit(debug: false) {
                (result: Bool) in
                if result {
                    DispatchQueue.main.async {
                        self.callChart()
                        self.ActivityOne(isOn:false)
                        self.textAlpha(isNow: 1.0)
                        self.topLeft.alpha = 1.0
                        self.topRight.alpha = 1.0
                        self.backtestButton.alpha = 1.0
                        self.graphButton.alpha = 1.0
                        self.largestWinLabel.alpha = 1.0
                        self.largestLossLabel.alpha = 1.0
                        self.tradingDaysLabel.alpha = 1.0
                    }
                }
            }
        }
    }
    
    func showCounter(count:Int,max:Int) {
        DispatchQueue.main.async {
            //self.topLeft.textAlignment = .right
            self.topLeft.text = "Calculating \(count)"
            self.topRight.text = "of \(max)"
        }
    }
    
    func textAlpha(isNow:CGFloat){
        DispatchQueue.main.async {
            //self.topLeft.alpha = isNow
            //self.topRight.alpha = isNow
            self.midLeft.alpha = isNow
            self.midRight.alpha = isNow
            self.bottomLeft.alpha = isNow
        }
    }
    
    func ActivityOne(isOn:Bool) {
        DispatchQueue.main.async {
            if isOn {
                self.activityIndicator.startAnimating()
                self.textAlpha(isNow: 0.1)
                self.backtestButton.alpha = 0.2
                self.graphButton.alpha = 0.2
            } else {
                self.activityIndicator.stopAnimating()
                self.textAlpha(isNow: 1.0)
                self.backtestButton.alpha = 1.0
                self.graphButton.alpha = 1.0
            }
        }
    }
    
    func callChart() {
        ActivityOne(isOn: false)
        print("finished getting stats, calling build chart")
        getWeeklyFromRealm()
    }
    
    func getWeeklyFromRealm() {
        print("\n inside getWeeklyFromRealm()\n")
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
            calcStats(debug: false, completion: callChart)
        }
    }

    func getStatsfromRealm() {
        let realm = try! Realm()
        if let updateStats = realm.objects(Stats.self).last {
            print("getting saved stats from realm")
            let gross = Utilities().dollarStr(largeNumber: updateStats.grossProfit)
            let cost = Utilities().dollarStr(largeNumber: updateStats.maxCost)
            let thisRisk = Account().currentRisk()
            let roi = updateStats.avgROI * 100
            DispatchQueue.main.async {
                self.topLeft.textAlignment = .left
                self.topLeft.text = "$\(gross) Profit"
                self.topRight.text = "\(String(format: "%.0f", updateStats.avgPctWin))% Wins"
                self.midLeft.text = "\(String(format: "%.2f", roi))%  Roi "
                self.midRight.text = "$\(cost) Cost, \(thisRisk) Risk"
                self.bottomLeft.text = "\(String(format: "%.2f", updateStats.avgStars)) Avg Stars"
                let lWin = Utilities().dollarStr(largeNumber: updateStats.largestWinner)
                self.largestWinLabel.text = "Largest Win \(lWin)"
                let lLos = Utilities().dollarStr(largeNumber: updateStats.largestLoser)
                self.largestLossLabel.text = "Largest Loss \(lLos)"
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
            self.ActivityOne(isOn:true)
            
            _ = CumulativeProfit().allTickerBacktestWithCost(debug: false, saveToRealm: true)
           
            DispatchQueue.main.async {
                completion()
                self.getStatsfromRealm()
                self.ActivityOne(isOn:false)
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
            self.addAxes(BarsToShow: self.barsToShow)
            self.addSeries()
        }
    }
    
    // MARK: Private Functions
    fileprivate func addAxes(BarsToShow:Int) {
        
        let totalBars:Int = results!.count
        let rangeStart:Int = totalBars - BarsToShow
        
        let xAxis = SCICategoryDateTimeAxis()
        xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        xAxis.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        xAxis.style.labelStyle.fontName = "Helvetica"
        xAxis.style.labelStyle.fontSize = 7
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        yAxis.style.labelStyle.fontName = "Helvetica"
        yAxis.style.labelStyle.fontSize = 14
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
        lineRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), withThickness: 1.0)
        sciChartView1.renderableSeries.add(lineRenderSeries)
    }
    
}
