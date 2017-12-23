//
//  ChartViewController.swift
//  SciChartSwiftDemo
//
//  Created by Warren Hansen on 6/6/16.
//  Copyright © 2016 SciChart Ltd. All rights reserved.
//

import Foundation
import SciChart
import RealmSwift

class SCSSyncMultiChartView: UIViewController {

    var dataFeed = DataFeed()
    var oneTicker:Results<Prices>!
    var marketCondition:Results<MarketCondition>!
    let showTrades = ShowTrades()
    var ticker:String = ""
    var taskIdSelected:String = ""
    var rangeStart:Int = 0
    let axisY1Id:String = "Y1"
    let axisX1Id:String = "X1"
    var startBar:Int = 0
    var highestPrice:Double = 0.00
    var highestAtr:Double = 0.00
    let axisY2Id:String = "Y2"
    let axisX2Id:String = "X2"
    let maxBarsOnChart:Int = 75
    var sciChartView1 = SCIChartSurface()
    var sciChartView2 = SCIChartSurface()
    
    let rangeSync = SCIAxisRangeSynchronization()
    let sizeAxisAreaSync = SCIAxisAreaSizeSynchronization()
    let rolloverModifierSync = SCIMultiSurfaceModifier(modifierType: SCIRolloverModifier.self)
    let pinchZoomModifierSync = SCIMultiSurfaceModifier(modifierType: SCIPinchZoomModifier.self)
    let yDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIYAxisDragModifier.self)
    let xDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIXAxisDragModifier.self)
    let zoomExtendsSync = SCIMultiSurfaceModifier(modifierType: SCIZoomExtentsModifier.self)
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBAction func unwindToCharts(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        oneTicker = Prices().getFrom(taskID: taskIdSelected)
        marketCondition = MarketCondition().getData()
        ticker = (oneTicker.first?.ticker)!
        title = ticker
        completeConfiguration()
    }
    
    @IBAction func segueToSettings(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as! PrefViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    
    //MARK: - Add Pices Series
    fileprivate func addDataSeries(surface:SCIChartSurface, xID:String, yID:String) {
        surface.renderableSeries.add(getCandleRenderSeries(debug: false, xID: xID, yID: yID))
    }
    //MARK: - Get Candle Render Series
    fileprivate func getCandleRenderSeries(debug: Bool, xID:String, yID:String) -> SCIFastCandlestickRenderableSeries {
        
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
    //MARK: - Add To Portfolio
    @IBAction func addToPortfolioAction(_ sender: Any) {
        print("tapped add")
        segueToManageVC(taskID: taskIdSelected, action: "Entry For")
    }
    
    @IBAction func managePortfolioAction(_ sender: Any) {
        print("tapped edit")
        segueToManageVC(taskID: taskIdSelected, action: "Manage")
        
    }
    
    func sequeToPortfolio() {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "PortfolioVC") as! PortfolioViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    //MARK: - Complete Configuration
    func completeConfiguration() {
        //chartSelected = dataFeed.allSortedPrices[indexSelected]
        configureChartSuraface()
        addAxis(BarsToShow: maxBarsOnChart)
        addModifiers()
        addDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addWPctRSeries(debug: false, surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
        addWAtrSeries(debug: true, surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
        addFastSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addSlowSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addBands(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        showEntries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        
        let statsText = BackTest().chartString(ticker: (oneTicker.first?.ticker)!)
        let stats = ShowTrades().showStats(xID: axisX1Id, yID: axisY1Id,
                                           date: Double(rangeStart), price: highestPrice, text: statsText)
        let guidanceText = MarketCondition().getStrMatixForChart()
        let guideChart = ShowTrades().showStats(xID: axisX2Id, yID: axisY2Id,
                                                date: Double(rangeStart), price: highestAtr, text: guidanceText)
        
        
        sciChartView1.annotations.add(stats)
        sciChartView2.annotations.add(guideChart)
    }
    
    fileprivate func addMatrixValues(isOn:Bool, date:Date, low:Double, index:Double) {
        if !isOn { return }
        let matrix = MarketCondition().getMatixToProveOnChart(date: date)
        let mStat = ShowTrades().showMatrix(xID: axisX1Id, yID: axisY1Id, date: index, price: low, text: "\(matrix)")
        sciChartView1.annotations.add(mStat)
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
        
        let axisX2:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX2.axisId = axisX2Id
        rangeSync.attachAxis(axisX2)
        axisX2.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX2.style.labelStyle.fontName = "Helvetica"
        axisX2.style.labelStyle.fontSize = 14
        sciChartView2.xAxes.add(axisX2)
        
        let axisY2:SCINumericAxis = SCINumericAxis()
        axisY2.axisId = axisY2Id
        axisY2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY2.style.labelStyle.fontName = "Helvetica"
        axisY2.style.labelStyle.fontSize = 14
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
        //sciChartView1.yAxes.item(at: 0).autoRange = .always
        var xDateDragModifier = xDragModifierSync.modifier(forSurface: sciChartView1) as? SCIXAxisDragModifier
        xDateDragModifier?.axisId = axisX1Id
        xDateDragModifier?.dragMode = .pan;
        xDateDragModifier?.clipModeX = .none
        
        var modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView1.chartModifiers = modifierGroup
        
        yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView2) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY2Id
        yDragModifier?.dragMode = .pan;
        
        xDateDragModifier = xDragModifierSync.modifier(forSurface: sciChartView2) as? SCIXAxisDragModifier
        xDateDragModifier?.axisId = axisX2Id
        xDateDragModifier?.dragMode = .pan;
        xDateDragModifier?.clipModeX = .none
        
        modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView2.chartModifiers = modifierGroup
    }
    
    fileprivate func showEntries(surface:SCIChartSurface, xID:String, yID:String) {
         for ( index, things) in oneTicker.enumerated() {
            let signal:Bool = things.longEntry
            let high:Double = things.high
            let low:Double = things.low
            surface.annotations = showTrades.showTradesOnChart(currentBar: index, signal: signal, high: high, low: low, xID:xID, yID: yID)
            addMatrixValues(isOn:true, date: things.date!, low: things.low, index: Double(index))
        }
    }
    //MARK: - pctR
    fileprivate func addWPctRSeries(debug: Bool, surface:SCIChartSurface, xID:String, yID:String)  {
        if ticker == "SPY" { return }
        let indicatorDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        indicatorDataSeries.acceptUnsortedData = true
        let triggerDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        triggerDataSeries.acceptUnsortedData = true
        let sellTriggerDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        sellTriggerDataSeries.acceptUnsortedData = true
        var wPctR:Double = 0.0
        for things in oneTicker {
            wPctR = things.wPctR
            if ( debug ) { print("c:\(things.close) wPctR: \(wPctR)") }
            indicatorDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(wPctR))
            triggerDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(-20.0))
            sellTriggerDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(-80.0))
        }
        
        let indicatorRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        indicatorRenderSeries.dataSeries = indicatorDataSeries
        indicatorRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1.0)
        indicatorRenderSeries.xAxisId = xID
        indicatorRenderSeries.yAxisId = yID
        surface.renderableSeries.add(indicatorRenderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: SCIGeneric( wPctR))
        
        let triggerRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        triggerRenderSeries.dataSeries = triggerDataSeries
        triggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        triggerRenderSeries.xAxisId = xID
        triggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(triggerRenderSeries)
        
        let sellTriggerRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        sellTriggerRenderSeries.dataSeries = sellTriggerDataSeries
        sellTriggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        sellTriggerRenderSeries.xAxisId = xID
        sellTriggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(sellTriggerRenderSeries)
    }
    
    //MARK: - atr
    fileprivate func addWAtrSeries(debug: Bool, surface:SCIChartSurface, xID:String, yID:String)  {
        if ticker != "SPY" { return }
        let atrPctAvgDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        atrPctAvgDataSeries.acceptUnsortedData = true
        let stdDevHiDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        stdDevHiDataSeries.acceptUnsortedData = true
        let stdDevLoDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
        stdDevLoDataSeries.acceptUnsortedData = true
        //var wPctR:Double = 0.0
        for (index, things) in marketCondition.enumerated() {
            
            if ( debug ) { print("c:\(things.close) ATR: \(things.volatilityAverage) High: \(things.stdDevClacHi) Low: \(things.stdDevClacLow)") }
            atrPctAvgDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.volatilityAverage))
            stdDevHiDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.stdDevClacHi))
            stdDevLoDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.stdDevClacLow))
            
            if index >= startBar {
                if things.stdDevClacHi > highestAtr {
                    highestAtr = things.stdDevClacHi
                }
            }
        }
        
        let indicatorRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        indicatorRenderSeries.dataSeries = atrPctAvgDataSeries
        indicatorRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1.0)
        indicatorRenderSeries.xAxisId = xID
        indicatorRenderSeries.yAxisId = yID
        surface.renderableSeries.add(indicatorRenderSeries)
        //addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: SCIGeneric( wPctR))
        
        let triggerRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        triggerRenderSeries.dataSeries = stdDevHiDataSeries
        triggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        triggerRenderSeries.xAxisId = xID
        triggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(triggerRenderSeries)
        
        let sellTriggerRenderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        sellTriggerRenderSeries.dataSeries = stdDevLoDataSeries
        sellTriggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        sellTriggerRenderSeries.xAxisId = xID
        sellTriggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(sellTriggerRenderSeries)
    }
    //MARK: - SMA 10
    fileprivate func addFastSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        var lastValue:SCIGenericType = SCIGeneric(0.0)
        //let items = dataFeed.sortedPrices
        for ( things) in oneTicker {
            smaDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.movAvg10))
            lastValue = SCIGeneric(things.movAvg10)
        }
        
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 0.7)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: lastValue)
    }
    //MARK: - SMA 200
    fileprivate func addSlowSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        var lastValue:SCIGenericType = SCIGeneric(0.0)
        //let items = dataFeed.sortedPrices
        for things in oneTicker {
            smaDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.movAvg200))
            lastValue = SCIGeneric(things.movAvg200)
        }
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 2)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: lastValue)
    }
    
    fileprivate func addBands(surface:SCIChartSurface, xID:String, yID:String)  {
        if ticker != "SPY" { return }
        let upperBandDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        let lowerBandDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        print("\nwe are adding bands")
        for things in marketCondition {
            upperBandDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.upperBand))
            lowerBandDataSeries.appendX(SCIGeneric(things.date!), y: SCIGeneric(things.lowerBand))
            print("upper: \(things.upperBand) lower: \(things.lowerBand)")
        }
        
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = upperBandDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
        
        let renderSeries2:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries2.dataSeries = lowerBandDataSeries
        renderSeries2.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1)
        renderSeries2.style.isDigitalLine = false
        renderSeries2.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries2.xAxisId = xID
        renderSeries2.yAxisId = yID
        surface.renderableSeries.add(renderSeries2)
    }
    
    func addAxisMarkerAnnotation(surface:SCIChartSurface, yID:String, color:UIColor, valueFormat:String, value:SCIGenericType){
        let axisMarker:SCIAxisMarkerAnnotation = SCIAxisMarkerAnnotation()
        axisMarker.yAxisId = yID;
        axisMarker.style.margin = 5;
        
        let textFormatting:SCITextFormattingStyle = SCITextFormattingStyle();
        textFormatting.color = UIColor.white;
        textFormatting.fontSize = 10;
        axisMarker.style.textStyle = textFormatting;
        axisMarker.formattedValue = String.init(format: valueFormat, SCIGenericDouble(value));
        axisMarker.coordinateMode = .absolute
        axisMarker.style.backgroundColor = color
        axisMarker.position = value;
        //print("SMA Anntation \(value.doubleData)")
        surface.annotations.add(axisMarker);
    }
    
    func segueToManageVC(taskID: String, action: String) {
        let myVC:ManageViewController = storyboard?.instantiateViewController(withIdentifier: "ManageVC") as! ManageViewController
        myVC.taskID = taskIdSelected
        myVC.action = "Entry For"
        navigationController?.pushViewController(myVC, animated: true)
    }
}

