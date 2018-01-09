//
//  DeBugViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 1/8/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit
import SciChart
import RealmSwift

class DeBugViewController: UIViewController {
    
    @IBOutlet weak var topLable: UILabel!
    
    @IBOutlet weak var chartView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var sliderDefault: UISlider!
    
    var ticker:String = "SPY"
    var taskIdSelected:String = ""
    var galaxie = [String]()
    
    var dataFeed = DataFeed()
    var oneTicker:Results<Prices>!
    let showTrades = ShowTrades()
    
    let axisY1Id:String = "Y1"
    let axisX1Id:String = "X1"
    let axisY2Id:String = "Y2"
    let axisX2Id:String = "X2"
    
    var rangeStart:Int = 0
    var startBar:Int = 0
    var maxBarsOnChart:Int = 75
    var highestPrice:Double = 0.00
    
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
        detectDevice()
        oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false)
        galaxie = SymbolLists().uniqueElementsFrom(testSet: false, of: 100)
        setUpSlider()
        chartConfiguration(debug: false)
    }
    
    
    //////////////////////////////////////////////////////////////////
    //                            Set Up Slider                     //
    //////////////////////////////////////////////////////////////////
    func setUpSlider() {
        sliderDefault.maximumValue = Float(galaxie.count)
        sliderDefault.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc func sliderDidEndSliding() {
        let currentValue = Int(sliderDefault.value)
        let update = String(galaxie[currentValue])
        topLable.text = update
        print("Hello Slider value \(sliderDefault.value) \(update)")
        ticker = update
        removeSeries()
        chartConfiguration(debug: false)
    }
    
    func removeSeries() {
        if sciChartView1.renderableSeries.count() > 0 {
            sciChartView1.renderableSeries.remove(at: 0)
            highestPrice = 0.0
        }
    }
    
    func clearSeries() {
        sciChartView1.renderableSeries.clear()
        sciChartView1.annotations.clear()
        sciChartView1.xAxes.clear()
        sciChartView1.yAxes.clear()
        sciChartView1.chartModifiers.clear()
        
        
        sciChartView2.renderableSeries.clear()
        sciChartView2.annotations.clear()
        sciChartView2.xAxes.clear()
        sciChartView2.yAxes.clear()
        sciChartView2.chartModifiers.clear()
    }
    
    //////////////////////////////////////////////////////////////////
    //                          Set up chart                        //
    //////////////////////////////////////////////////////////////////
    //MARK: - Complete Chart Configuration
    func chartConfiguration(debug:Bool) {
        configureChartSuraface()
        addAxis(BarsToShow: maxBarsOnChart)
        addModifiers()
        addDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addFastSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addSlowSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        showEntries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        let statsText = BackTest().chartString(ticker: (oneTicker.first?.ticker)!)
        let stats = ShowTrades().showStats(xID: axisX1Id, yID: axisY1Id, date: Double(rangeStart), price: highestPrice, text: statsText)
        sciChartView1.annotations.add(stats)
    }
    
    //MARK: - Add Prices Series
    fileprivate func addDataSeries(surface:SCIChartSurface, xID:String, yID:String) {
        surface.renderableSeries.add(getCandleRenderSeries(debug: false, xID: xID, yID: yID))
    }
    //MARK: - Get Candle Render Series
    fileprivate func getCandleRenderSeries(debug: Bool, xID:String, yID:String) -> SCIFastCandlestickRenderableSeries {
        oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false)
        print("\nPopulating candle series\n")
        let upBrush:SCISolidBrushStyle = SCISolidBrushStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        let downBrush:SCISolidBrushStyle = SCISolidBrushStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        let upWickPen:SCISolidPenStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), withThickness: 0.7)
        let downWickPen:SCISolidPenStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 0.7)
        let ohlcDataSeries:SCIOhlcDataSeries = SCIOhlcDataSeries(xType: .dateTime, yType: .double)
        ohlcDataSeries.acceptUnsortedData = true
        startBar = oneTicker.count - maxBarsOnChart
        
        for ( index, things ) in oneTicker.enumerated() {
            if ( debug ) { print("\(things.date!) \(things.open) \(things.high) \(things.low) \(things.close)") }
            ohlcDataSeries.appendX(SCIGeneric(things.date!),
                                   open: SCIGeneric(things.open),
                                   high: SCIGeneric(things.high),
                                   low: SCIGeneric(things.low),
                                   close: SCIGeneric(things.close))
            
            if index >= startBar {
                if things.high > highestPrice {
                    highestPrice = things.high
                }
            }
        }
        
        let candleRendereSeries = SCIFastCandlestickRenderableSeries()
        candleRendereSeries.dataSeries = ohlcDataSeries
        candleRendereSeries.fillUpBrushStyle = upBrush
        candleRendereSeries.fillDownBrushStyle = downBrush
        candleRendereSeries.strokeUpStyle = upWickPen
        candleRendereSeries.strokeDownStyle = downWickPen
        candleRendereSeries.xAxisId = xID
        candleRendereSeries.yAxisId = yID
        
        return candleRendereSeries
    }
    
    fileprivate func configureChartSuraface() {
        sciChartView1 = SCIChartSurface(frame:  self.chartView.bounds)
        sciChartView1.frame = self.chartView.bounds
        sciChartView1.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView1.translatesAutoresizingMaskIntoConstraints = true
        self.chartView.addSubview(sciChartView1)
        
//        sciChartView2 = SCIChartSurface(frame: self.bottomView.bounds)
//        sciChartView2.frame = self.bottomView.bounds
//        sciChartView2.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        sciChartView2.translatesAutoresizingMaskIntoConstraints = true
//        self.bottomView.addSubview(sciChartView2)
    }
    
    
    fileprivate func addAxis(BarsToShow: Int) {
        
        let totalBars:Int = oneTicker.count
        rangeStart = totalBars - BarsToShow
        
        let axisX1:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX1.axisId = axisX1Id
        rangeSync.attachAxis(axisX1)
        
        axisX1.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX1.style.labelStyle.fontName = "Helvetica"
        axisX1.style.labelStyle.fontSize = 14
        
        sciChartView1.xAxes.add(axisX1)
        
        let axisY1:SCINumericAxis = SCINumericAxis()
        axisY1.axisId = axisY1Id
        axisY1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY1.style.labelStyle.fontName = "Helvetica"
        axisY1.style.labelStyle.fontSize = 14
        //sciChartView1.yAxes.item(at: 0).autoRange = .always
        axisY1.autoRange = .always
        sciChartView1.yAxes.add(axisY1)
        
    }
    
    fileprivate func addModifiers() {
        sizeAxisAreaSync.syncMode = .right
        sizeAxisAreaSync.attachSurface(sciChartView1)
        sizeAxisAreaSync.attachSurface(sciChartView2)
        
        let yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView1) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY1Id
        yDragModifier?.dragMode = .pan;
        //sciChartView1.yAxes.item(at: 0).autoRange = .always
        let xDateDragModifier = xDragModifierSync.modifier(forSurface: sciChartView1) as? SCIXAxisDragModifier
        xDateDragModifier?.axisId = axisX1Id
        xDateDragModifier?.dragMode = .pan;
        xDateDragModifier?.clipModeX = .none
        
        let modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView1.chartModifiers = modifierGroup
    }
    
    fileprivate func showEntries(surface:SCIChartSurface, xID:String, yID:String) {
        for ( index, things) in oneTicker.enumerated() {
            let signal:Bool = things.longEntry
            let high:Double = things.high
            let low:Double = things.low
            surface.annotations = showTrades.showTradesOnChart(currentBar: index, signal: signal, high: high, low: low, xID:xID, yID: yID)
            //addMatrixValues(isOn:true, date: things.date!, low: things.low, index: Double(index))
        }
    }
    
    //MARK: - SMA 10
    fileprivate func addFastSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        for ( things) in oneTicker {
            smaDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.movAvg10))
        }
        
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 0.7)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
    }
    //MARK: - SMA 200
    fileprivate func addSlowSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        for things in oneTicker {
            smaDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.movAvg200))
        }
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 2)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
    }

    
    @IBAction func allEntryAction(_ sender: Any) {
    }
    
    @IBAction func flatEntryAction(_ sender: Any) {
    }
    
    func detectDevice() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            print("It's an iPhone")
        case .pad:
            print("it's an iPad")
            maxBarsOnChart = maxBarsOnChart * 2
        case .unspecified:
            print("It's an iPhone")
        case .tv:
            print("It's an iPhone")
            maxBarsOnChart = maxBarsOnChart * 3
        case .carPlay:
            print("It's an iPhone")
        }
    }
}
