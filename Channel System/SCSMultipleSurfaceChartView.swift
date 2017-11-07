//
//  SCSMultipleSurfaceChartView.swift
//  SciChartSwiftDemo
//
//  Created by Mykola Hrybeniuk on 6/6/16.
//  Copyright © 2016 SciChart Ltd. All rights reserved.
//

import Foundation
import SciChart

class SCSSyncMultiChartView: UIViewController {
    
    var dataFeed = DataFeed()
    let showTrades = ShowTrades()
    let portfolio = Portfolio()
    
    let axisY1Id = "Y1"
    let axisX1Id = "X1"
    
    let axisY2Id = "Y2"
    let axisX2Id = "X2"
    
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
    
    override func viewDidLoad() {
        completeConfiguration()
    }

    @IBAction func addToPortfolioAction(_ sender: Any) {
        print("tapped add")
        if let ticker = dataFeed.sortedPrices.last?.ticker!, let close = dataFeed.sortedPrices.last?.close!  {
            let stopDistance = Double(close) * 0.03
            let stop = Double(close) - stopDistance
            let target = Double(close) + stopDistance
            let stopString = String(format: "%.2f", stop)
            
            //MARK: - TODO - number of shares + risk
            let message = "Entry:\(close)\tStop:\(stopString)\tTarget:\(target)"
            print(message)
            let alert = UIAlertController(title: "\(ticker) Entry", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Record", style: .default) { (alertAction) in
                let textField = alert.textFields![0] as UITextField
                if let entryString = textField.text {
                    self.portfolio.makeEntry(ticker: ticker, entryString: entryString, target: target, stop: stop, debug: true)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
            }
            alert.addTextField { (textField) in
                textField.text = "\(close)"
                textField.keyboardAppearance = .dark
                textField.keyboardType = .decimalPad
            }
            alert.addAction(cancel)
            alert.addAction(action)
            present(alert, animated:true, completion: nil)
        } else {
            print("Trouble with Ticker")
        }
    }
    
    // MARK: Internal Functions    
    func completeConfiguration() {
        configureChartSuraface()
        addAxis(BarsToShow: 75)
        addModifiers()
        
        addDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addWPctRSeries(debug: true, surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
        addFastSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addSlowSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        showEntries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
    }
    
    // MARK: Private Functions
    
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
        
        let totalBars = dataFeed.sortedPrices.count
        let rangeStart = totalBars - BarsToShow
        
        let axisX1 = SCINumericAxis()
        axisX1.axisId = axisX1Id
        rangeSync.attachAxis(axisX1)
        
        axisX1.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX1.style.labelStyle.fontName = "Helvetica"
        axisX1.style.labelStyle.fontSize = 14
        
        sciChartView1.xAxes.add(axisX1)
        
        let axisY1 = SCINumericAxis()
        axisY1.axisId = axisY1Id
        axisY1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY1.style.labelStyle.fontName = "Helvetica"
        axisY1.style.labelStyle.fontSize = 14
        sciChartView1.yAxes.add(axisY1)
        
        let axisX2 = SCINumericAxis()
        axisX2.axisId = axisX2Id
        rangeSync.attachAxis(axisX2)
        axisX2.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX2.style.labelStyle.fontName = "Helvetica"
        axisX2.style.labelStyle.fontSize = 14
        sciChartView2.xAxes.add(axisX2)
        
        let axisY2 = SCINumericAxis()
        axisY2.axisId = axisY2Id
        axisY2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY2.style.labelStyle.fontName = "Helvetica"
        axisY2.style.labelStyle.fontSize = 14
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
    
    fileprivate func addDataSeries(surface:SCIChartSurface, xID:String, yID:String) {

        surface.renderableSeries.add(getCandleRenderSeries(debug: false, isReverse:false,  xID: xID, yID: yID))
    }
    
    fileprivate func showEntries(surface:SCIChartSurface, xID:String, yID:String) {
        
        let items = dataFeed.sortedPrices
         for ( index, things) in items.enumerated() {
            if let signal = things.longEntry, let high = things.high , let low = things.low {
                surface.annotations = showTrades.showTradesOnChart(currentBar: index, signal: signal, high: high, low: low, xID:xID, yID: yID)
            }
            
        }
    }
    
    fileprivate func getCandleRenderSeries(debug: Bool, isReverse: Bool, xID:String, yID:String) -> SCIFastCandlestickRenderableSeries {
        
        let upBrush = SCISolidBrushStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        let downBrush = SCISolidBrushStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        let upWickPen = SCISolidPenStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), withThickness: 0.7)
        let downWickPen = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 0.7)
        let ohlcDataSeries = SCIOhlcDataSeries(xType: .double, yType: .double)
        ohlcDataSeries.acceptUnsortedData = true
        
        let items = dataFeed.sortedPrices
        
        if ( debug ) { print("getting candle render series\narray Size = \(items.count)") }
        
        for ( index, things) in items.enumerated() {

            if ( debug ) { print("\(things.open!) \(things.high!) \(things.low!) \(things.close!)") }
            ohlcDataSeries.appendX(SCIGeneric(index),
                                   open: SCIGeneric(things.open!),
                                   high: SCIGeneric(things.high!),
                                   low: SCIGeneric(things.low!),
                                   close: SCIGeneric(things.close!))
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
    
    fileprivate func addWPctRSeries(debug: Bool, surface:SCIChartSurface, xID:String, yID:String)  {
        
        let indicatorDataSeries = SCIXyDataSeries(xType: .float, yType: .float)
        indicatorDataSeries.acceptUnsortedData = true
        let triggerDataSeries = SCIXyDataSeries(xType: .float, yType: .float)
        triggerDataSeries.acceptUnsortedData = true
        let sellTriggerDataSeries = SCIXyDataSeries(xType: .float, yType: .float)
        sellTriggerDataSeries.acceptUnsortedData = true
        
        let items = dataFeed.sortedPrices
        if ( debug ) { print("getting wPctR render series\narray Size = \(items.count)") }

        var wPctR = 0.0
        for ( index, things) in items.enumerated() {
            
            wPctR = things.wPctR!
            
            if ( debug ) { print("c:\(things.close!) wPctR: \(wPctR)") }
            indicatorDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(wPctR))
            triggerDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(-20.0))
            sellTriggerDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(-80.0))
        }
        
        let indicatorRenderSeries = SCIFastLineRenderableSeries()
        indicatorRenderSeries.dataSeries = indicatorDataSeries
        indicatorRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1.0)
        indicatorRenderSeries.xAxisId = xID
        indicatorRenderSeries.yAxisId = yID
        surface.renderableSeries.add(indicatorRenderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: SCIGeneric( wPctR))
        
        let triggerRenderSeries = SCIFastLineRenderableSeries()
        triggerRenderSeries.dataSeries = triggerDataSeries
        triggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        triggerRenderSeries.xAxisId = xID
        triggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(triggerRenderSeries)
        
        let sellTriggerRenderSeries = SCIFastLineRenderableSeries()
        sellTriggerRenderSeries.dataSeries = sellTriggerDataSeries
        sellTriggerRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 2.0)
        sellTriggerRenderSeries.xAxisId = xID
        sellTriggerRenderSeries.yAxisId = yID
        surface.renderableSeries.add(sellTriggerRenderSeries)
    }
    
    fileprivate func addFastSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        var lastValue = SCIGeneric(0.0)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            smaDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg10!))
            lastValue = SCIGeneric(things.movAvg10!)
        }
        
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 0.7)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: lastValue)
    }
    
    fileprivate func addSlowSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        var lastValue = SCIGeneric(0.0)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            smaDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg200!))
            lastValue = SCIGeneric(things.movAvg200!)
        }
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), withThickness: 2)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
        addAxisMarkerAnnotation(surface: surface, yID:yID, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), valueFormat: "%.2f", value: lastValue)
    
    }
    
    func addAxisMarkerAnnotation(surface:SCIChartSurface, yID:String, color:UIColor, valueFormat:String, value:SCIGenericType){
        let axisMarker = SCIAxisMarkerAnnotation()
        axisMarker.yAxisId = yID;
        axisMarker.style.margin = 5;
        
        let textFormatting = SCITextFormattingStyle();
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
    

    
}

