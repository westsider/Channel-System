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
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var backtestButton: UIButton!
    
    @IBOutlet weak var graphButton: UIButton!
    
    @IBOutlet weak var minStarsLabel: UILabel!
    
    @IBOutlet weak var annualProfitLabel: UILabel!
    
    @IBOutlet weak var spReturnLabel: UILabel!
    
    var galaxie = [String]()
    var totalProfit = [Double]()
    var averagePctWin = [Double]()
    var totalROI = [Double]()
    var averageStars = [Double]()
    var results: Results<WklyStats>?
    let maxBarsOnChart:Int = 100
    var minStars:Int = 0
    //MARK: - chart vars
    var dataFeed = DataFeed()
    var oneTicker:Results<Prices>!
    let showTrades = ShowTrades()
    var ticker:String = "SPY"
    var taskIdSelected:String = ""
    var rangeStart:Int = 0
    let axisY1Id:String = "Y1"
    let axisX1Id:String = "X1"
    var highestPrice:Double = 0.00
    let axisY2Id:String = "Y2"
    let axisX2Id:String = "X2"
    var sciChartView1 = SCIChartSurface()
    var sciChartView2 = SCIChartSurface()
    let rangeSync = SCIAxisRangeSynchronization()
    let sizeAxisAreaSync = SCIAxisAreaSizeSynchronization()
    let rolloverModifierSync = SCIMultiSurfaceModifier(modifierType: SCIRolloverModifier.self)
    let pinchZoomModifierSync = SCIMultiSurfaceModifier(modifierType: SCIPinchZoomModifier.self)
    let yDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIYAxisDragModifier.self)
    let xDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIXAxisDragModifier.self)
    let zoomExtendsSync = SCIMultiSurfaceModifier(modifierType: SCIZoomExtentsModifier.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
        //MARK: - Todo if lastdate in realm wklySTats is today just load from realm.. else CumulativeProfit().weeklyProfit
        
        // now only calc cum profit when this vc is called
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            PortfolioWeekly().weeklyProfit(debug: true, completion: { (finished) in
                if finished {
                    WklyStats().showCumProfitFromRealm()
                    self.getStatsfromRealm()
                }
            })
        }

        // got stuck in inf loop after reloading everything
        //getStatsfromRealm()
        //newStatsToGet()
        
    }
    
    
    func newStatsToGet() {
//        CalcStars().backtest(galaxie: galaxie, debug: false, completion: {
//            print("\ncalc Stars done!\n")
//            //self.updateNVActivity(with:"Daily + Weekly Back Test")
//            CumulativeProfit().backtestDailyWeekly(debug: false, completion: { (finished) in
//                if finished  {
//                    print("Backtest done")
//                    DispatchQueue.main.async {
//                        //self.stopAnimating()
//                    }
//                }
//            })
//        })
    }
    //MARK: - Backtest Button
    @IBAction func runNewBacktestAction(_ sender: Any) {
//        self.topLeft.textAlignment = .right
//        ActivityOne(isOn:true)
//        calcStats(debug: false, completion: getDataForChart)
        newStatsToGet()
    }
    
    @IBAction func runNewChartCalc(_ sender: Any) {
        ActivityOne(isOn:true)
        //textAlpha(isNow: 0.3)
        DispatchQueue.global(qos: .background).async {
            PortfolioWeekly().weeklyProfit(debug: false) {
                (result: Bool) in
                if result {
                    DispatchQueue.main.async {
                        self.getDataForChart()
                        self.ActivityOne(isOn:false)
                        //self.textAlpha(isNow: 1.0)
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
            self.topLeft.alpha = isNow
            self.topRight.alpha = isNow
            self.midLeft.alpha = isNow
            self.midRight.alpha = isNow
            self.bottomLeft.alpha = isNow
            self.topLeft.alpha = isNow
            self.topRight.alpha = isNow
            self.backtestButton.alpha = isNow
            self.graphButton.alpha = isNow
            self.largestWinLabel.alpha = isNow
            self.largestLossLabel.alpha = isNow
            self.tradingDaysLabel.alpha = isNow
            self.spReturnLabel.alpha = isNow
            self.minStarsLabel.alpha = isNow
            self.annualProfitLabel.alpha = isNow
        }
    }
    
    func ActivityOne(isOn:Bool) {
        DispatchQueue.main.async {
            if isOn {
                self.activityIndicator.startAnimating()
                self.textAlpha(isNow: 0.3)
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
// this is nil and so we call calc stats
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
            print("No stats in Realm")
            //calcStats(debug: false, completion: getDataForChart)
        }
    }

    func getStatsfromRealm() {
        let realm = try! Realm()
        minStars = Stats().getStars()
        if let updateStats = realm.objects(Stats.self).last {
            print("getting saved stats from realm")
            let gross = Utilities().dollarStr(largeNumber: updateStats.grossProfit)
            let cost = Utilities().dollarStr(largeNumber: updateStats.maxCost)
            let thisRisk = Account().currentRisk()
            let roi = updateStats.avgROI * 100
            let fistDayofProfit = Utilities().convertToDateFrom(string: "2016/02/01", debug: false)
            let numDays = Utilities().calcuateDaysBetweenTwoDates(start: fistDayofProfit, end: Date())
            let numYears = Double(numDays) / 365.00
            let annualProfit = updateStats.grossProfit / numYears
            let annualProfitString = Utilities().dollarStr(largeNumber: annualProfit)
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
                self.tradingDaysLabel.text = "\(numDays) days, \(String(format: "%.1f", numYears)) years"
                self.largestLossLabel.text = "Largest Loss \(lLos)"
                self.minStarsLabel.text = "Minimun Stars: \(self.minStars)"
                self.annualProfitLabel.text = "$\(annualProfitString) Annually"
                self.spReturnLabel.text = SpReturns().textForStats(yearEnding: 2007)
                self.ActivityOne(isOn: false)
                self.getDataForChart()
            }
        } else {
            print("did not find realm")
            //calcStats(debug: false, completion: getDataForChart)
        }
    }
    
    func calcStats(debug:Bool, completion: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.ActivityOne(isOn:true)
            print("\n---------------> Now running new backtest <----------------\n")
            _ = PortfolioEntries().allTickerBacktestWithCost(debug: false, saveToRealm: true)
           
            DispatchQueue.main.async {
                completion()
                print("\n---------------> Now calling completion on new backtest <----------------\n")
                self.getStatsfromRealm()
                self.ActivityOne(isOn:false)
            }
        }
    }

    func getDataForChart() {
        ActivityOne(isOn: false)
        print("finished getting stats, calling build chart")
        getWeeklyFromRealm()
    }
    
    // MARK: Overrided Functions
    func completeConfiguration() {
        configureChartSuraface()
        addAxis(BarsToShow: maxBarsOnChart)
        addModifiers()
        topChartDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        bottomChartDataSeries(surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
    }
    
    //MARK: - Add Profit Series
    fileprivate func topChartDataSeries(surface:SCIChartSurface, xID:String, yID:String) {
        let cumulativeProfit = SCIXyDataSeries(xType: .dateTime, yType: .double)
        cumulativeProfit.acceptUnsortedData = true
        for things in results! {
            cumulativeProfit.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.profit))
        }
        let topChartRenderSeries = SCIFastLineRenderableSeries()
        topChartRenderSeries.dataSeries = cumulativeProfit
        topChartRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), withThickness: 1.0)
        topChartRenderSeries.xAxisId = xID
        topChartRenderSeries.yAxisId = yID
        surface.renderableSeries.add(topChartRenderSeries)
    }
    
    //MARK: - Cost Data Series
    fileprivate func bottomChartDataSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let cumulativeCost = SCIXyDataSeries(xType: .dateTime, yType: .double)
        cumulativeCost.acceptUnsortedData = true
        for things in results! {
            cumulativeCost.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.cost))
        }
        let bottomChartRenderSeries = SCIFastColumnRenderableSeries()
        bottomChartRenderSeries.dataSeries = cumulativeCost
        bottomChartRenderSeries.xAxisId = xID
        bottomChartRenderSeries.yAxisId = yID
        bottomChartRenderSeries.dataSeries = cumulativeCost
        bottomChartRenderSeries.paletteProvider = ColumnsTripleColorPalette()
        
        let animation = SCIWaveRenderableSeriesAnimation(duration: 1.5, curveAnimation: SCIAnimationCurveEaseOut)
        animation.start(afterDelay: 0.3)
        bottomChartRenderSeries.addAnimation(animation)
        surface.renderableSeries.add(bottomChartRenderSeries)
        
    }
   
    fileprivate func configureChartSuraface() {
        sciChartView1 = SCIChartSurface(frame: self.topView.bounds)
        sciChartView1.frame = self.topView.bounds
        sciChartView1.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView1.translatesAutoresizingMaskIntoConstraints = true
        self.topView.addSubview(sciChartView1)
        
        sciChartView2 = SCIChartSurface(frame: self.bottomView.bounds)
        sciChartView2.frame = self.bottomView.bounds
        sciChartView2.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView2.translatesAutoresizingMaskIntoConstraints = true
        self.bottomView.addSubview(sciChartView2)
    }
    
    fileprivate func addAxis(BarsToShow: Int) {
        
        let dateAxisSize:Float = 9.0
        let dollarAxisSize :Float = 12.0
        
        let totalBars:Int = results!.count
        rangeStart = totalBars - BarsToShow
        
        let axisX1:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX1.axisId = axisX1Id
        rangeSync.attachAxis(axisX1)
        
        axisX1.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX1.style.labelStyle.fontName = "Helvetica"
        axisX1.style.labelStyle.fontSize = dateAxisSize
        
        sciChartView1.xAxes.add(axisX1)
        
        let axisY1:SCINumericAxis = SCINumericAxis()
        axisY1.axisId = axisY1Id
        axisY1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY1.style.labelStyle.fontName = "Helvetica"
        axisY1.style.labelStyle.fontSize = dollarAxisSize
        sciChartView1.yAxes.add(axisY1)
        
        let axisX2:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX2.axisId = axisX2Id
        rangeSync.attachAxis(axisX2)
        axisX2.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX2.style.labelStyle.fontName = "Helvetica"
        axisX2.style.labelStyle.fontSize = dateAxisSize
        sciChartView2.xAxes.add(axisX2)
        
        let axisY2:SCINumericAxis = SCINumericAxis()
        axisY2.axisId = axisY2Id
        axisY2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY2.style.labelStyle.fontName = "Helvetica"
        axisY2.style.labelStyle.fontSize = dollarAxisSize
        sciChartView2.yAxes.add(axisY2)
    }
    
    fileprivate func addModifiers() {
        sizeAxisAreaSync.syncMode = .right
        sizeAxisAreaSync.attachSurface(sciChartView1)
        sizeAxisAreaSync.attachSurface(sciChartView2)
        
        var yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView1) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY1Id
        yDragModifier?.dragMode = .pan;
        
        var xDragModifier = xDragModifierSync.modifier(forSurface: sciChartView1) as? SCIXAxisDragModifier
        xDragModifier?.axisId = axisX1Id
        xDragModifier?.dragMode = .pan;
        
        var modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView1.chartModifiers = modifierGroup
        
        yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView2) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY2Id
        yDragModifier?.dragMode = .pan;
        
        xDragModifier = xDragModifierSync.modifier(forSurface: sciChartView2) as? SCIXAxisDragModifier
        xDragModifier?.axisId = axisX2Id
        xDragModifier?.dragMode = .pan;
        
        modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView2.chartModifiers = modifierGroup
    }
    
    func addAxisMarkerAnnotation(surface:SCIChartSurface, yID:String, color:UIColor, valueFormat:String, value:SCIGenericType){
        let axisMarker:SCIAxisMarkerAnnotation = SCIAxisMarkerAnnotation()
        axisMarker.yAxisId = yID;
        axisMarker.style.margin = 5;

        let textFormatting:SCITextFormattingStyle = SCITextFormattingStyle();
        textFormatting.color = UIColor.white;
        textFormatting.fontSize = 14;
        axisMarker.style.textStyle = textFormatting;
        axisMarker.formattedValue = String.init(format: valueFormat, SCIGenericDouble(value));
        axisMarker.coordinateMode = .absolute
        axisMarker.style.backgroundColor = color
        axisMarker.position = value;
        //print("SMA Anntation \(value.doubleData)")
        surface.annotations.add(axisMarker);
    }
}

class ColumnsTripleColorPalette : SCIPaletteProvider {
    let style1 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    let style2 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    let style3 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    
    override init() {
        super.init()

        style1.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style1.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
        style2.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style2.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
        style3.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style3.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
    }
    
    override func styleFor(x: Double, y: Double, index: Int32) -> SCIStyleProtocol! {
        let styleIndex : Int32 = index % 3;
        if (styleIndex == 0) {
            return style1;
        } else if (styleIndex == 1) {
            return style2;
        } else {
            return style3;
        }
    }
}
