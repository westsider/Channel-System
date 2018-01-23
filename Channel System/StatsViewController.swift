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
import NVActivityIndicatorView

class StatsViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var topLeft: UILabel!
    @IBOutlet weak var topRight: UILabel!
    @IBOutlet weak var midLeft: UILabel!
    @IBOutlet weak var midRight: UILabel!
    @IBOutlet weak var bottomLeft: UILabel!
    @IBOutlet weak var largestWinLabel: UILabel!
    @IBOutlet weak var largestLossLabel: UILabel!
    @IBOutlet weak var tradingDaysLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var minStarsLabel: UILabel!
    @IBOutlet weak var annualProfitLabel: UILabel!
    
    var galaxie = [String]()
    var portfolio:[Performance.ChartData] = []
    let size = CGSize(width: 100, height: 100)
    var totalProfit = [Double]()
    var averagePctWin = [Double]()
    var totalROI = [Double]()
    var averageStars = [Double]()
    var results: Results<WklyStats>?
    let maxBarsOnChart:Int = 400
    var minStars:Int = 0
    //MARK: - chart vars

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
        title = "Performance"
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
        startAnimating(self.size, message: "Optimizing Portfolio", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.orbit.rawValue)!, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),  textColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    }

    override func viewDidAppear(_ animated: Bool) {
        portfolio = Performance().getPerformanceChart(debug: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            // get realm data for chart
            PortfolioFilters().using(mc: true, stars: true, numPositions: 20) { (finished) in
                if finished {
                    DispatchQueue.main.async {
                        self.updateNVActivity(with: "Creating Lables")
                        self.populateLables()
                        self.stopAnimating()
                    }
                }
            }
        }
    }

    //MARK: - update lables
    func populateLables() {
        let realm = try! Realm()
       
        if let updateStats = realm.objects(Stats.self).last {
            print("getting saved stats from realm")
            let gross = Utilities().dollarStr(largeNumber: updateStats.grossProfit)
            let cost = Utilities().dollarStr(largeNumber: updateStats.maxCost)
            let thisRisk = Account().currentRisk()
            let lWin = Utilities().dollarStr(largeNumber: updateStats.largestWinner)
            let lLos = Utilities().dollarStr(largeNumber: updateStats.largestLoser)
            let annualProfit = Utilities().dollarStr(largeNumber: updateStats.annualProfit)
            let annualRoi = "\(String(format: "%.1f", updateStats.avgROI))%  Annual Roi"
            let timePeriod = "\(String(format: "%.1f", updateStats.numYears)) years, \(updateStats.numDays) days"
            
            DispatchQueue.main.async {
                self.topLeft.textAlignment = .left
                
                self.topLeft.text = "$\(gross) Total Profit"
                self.topRight.text = "\(String(format: "%.1f", (updateStats.avgPctWin)))% Win Rate"
                
                self.midLeft.text = "\(String(format: "%.1f", updateStats.grossROI))%  Total Roi"
                self.midRight.text = "$\(cost) Cost  $\(thisRisk) Risk"
                
                self.bottomLeft.text = "$\(annualProfit) Annual Profit"
                self.minStarsLabel.text = "\(updateStats.minStars) stars, \(String(format: "%.1f", updateStats.avgStars)) average"
                
                self.tradingDaysLabel.text = annualRoi
                self.annualProfitLabel.text = "Max gain \(lWin), loss \(lLos)"
                
                self.largestWinLabel.text = timePeriod
                self.largestLossLabel.text = SpReturns().textForStats(yearEnding: 2007)
                
                self.completeConfiguration()
            }
        }
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
        for things in portfolio {
            cumulativeProfit.appendX(SCIGeneric(things.date), y: SCIGeneric(things.dailyCumProfit))
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
        for things in portfolio {
            cumulativeCost.appendX(SCIGeneric(things.date), y: SCIGeneric(things.dailyCost))
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
        
        let totalBars:Int = portfolio.count
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
        axisY1.autoRange = .always
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
        axisY2.autoRange = .always
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
    
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
        }
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
