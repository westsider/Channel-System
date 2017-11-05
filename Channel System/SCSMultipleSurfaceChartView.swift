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

    // MARK: Internal Functions    
    func completeConfiguration() {
        configureChartSuraface()
        addAxis(BarsToShow: 50)
        addModifiers()
        
        addDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addDataSeries(surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
        addFastSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        addSlowSmaSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
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

        surface.renderableSeries.add(getCandleRenderSeries(isReverse:false,  xID: xID, yID: yID))

    }
    
    fileprivate func getCandleRenderSeries(isReverse: Bool, xID:String, yID:String) -> SCIFastCandlestickRenderableSeries {
        
        let upBrush = SCISolidBrushStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        let downBrush = SCISolidBrushStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        let upWickPen = SCISolidPenStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), withThickness: 0.7)
        let downWickPen = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 0.7)
        let ohlcDataSeries = SCIOhlcDataSeries(xType: .double, yType: .double)
        
        ohlcDataSeries.acceptUnsortedData = true
        
        let items = dataFeed.sortedPrices
        
        print("getting candle render series\narray Size = \(items.count)")
        
        for ( index, things) in items.enumerated() {

            print("\(things.open!) \(things.high!) \(things.low!) \(things.close!)")
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
        candleRendereSeries.dataSeries = ohlcDataSeries
        
        return candleRendereSeries
    }
    
    fileprivate func addFastSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let fourierDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            fourierDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg10!))
        }
        
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = fourierDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), withThickness: 0.7)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
    }
    
    fileprivate func addSlowSmaSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let fourierDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            fourierDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg200!))
        }
        
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = fourierDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), withThickness: 1.2)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
    }
    
}

