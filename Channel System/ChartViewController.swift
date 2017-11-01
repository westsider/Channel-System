//
//  ChartViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 10/31/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit
import Foundation
import SciChart

class ChartViewController: UIViewController {

    var dataFeed = DataFeed()
    
    var surface = SCIChartSurface()
    
    var ohlcDataSeries: SCIOhlcDataSeries!
    
    var ohlcRenderableSeries: SCIFastOhlcRenderableSeries!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSurface()
        addAxis(BarsToShow: 50)
        addDefaultModifiers()
        addDataSeries()
        addFastSmaSeries()
        addSlowSmaSeries()
    }
    
    fileprivate func addSurface() {
        surface = SCIChartSurface(frame: self.view.bounds)
        surface.translatesAutoresizingMaskIntoConstraints = true
        surface.frame = self.view.bounds
        surface.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(surface)
    }
    
    fileprivate func addAxis(BarsToShow: Int) {
        
        let totalBars = dataFeed.sortedPrices.count
        let rangeStart = totalBars - BarsToShow
        
        let xAxis = SCINumericAxis()
        xAxis.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        xAxis.style.labelStyle.fontName = "Helvetica"
        xAxis.style.labelStyle.fontSize = 14
        surface.xAxes.add(xAxis)
        
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        yAxis.style.labelStyle.fontName = "Helvetica"
        yAxis.style.labelStyle.fontSize = 14
        surface.yAxes.add(yAxis)
    }
    
    fileprivate func addDataSeries() {
        let upBrush = SCISolidBrushStyle(colorCode: 0x9000AA00)
        let downBrush = SCISolidBrushStyle(colorCode: 0x90FF0000)
        let upWickPen = SCISolidPenStyle(colorCode: 0xFF00AA00, withThickness: 0.7)
        let downWickPen = SCISolidPenStyle(colorCode: 0xFFFF0000, withThickness: 0.7)
        
        surface.renderableSeries.add(getCandleRenderSeries(false, upBodyBrush: upBrush, upWickPen: upWickPen, downBodyBrush: downBrush, downWickPen: downWickPen, count: 30))
    }
    
    fileprivate func getCandleRenderSeries(_ isReverse: Bool,
                                           upBodyBrush: SCISolidBrushStyle,
                                           upWickPen: SCISolidPenStyle,
                                           downBodyBrush: SCISolidBrushStyle,
                                           downWickPen: SCISolidPenStyle,
                                           count: Int) -> SCIFastCandlestickRenderableSeries {
        
        let ohlcDataSeries = SCIOhlcDataSeries(xType: .double, yType: .double)
        
        ohlcDataSeries.acceptUnsortedData = true
        
        let items = dataFeed.sortedPrices
        
        print("array Size = \(items.count)")
        
        for ( index, things) in items.enumerated() {
            let date:Date = things.date!
            ///print("Date OHLC: \(date) \(items[i].open!) \(items[i].high!) \(items[i].low!) \(items[i].close!)")
            ohlcDataSeries.appendX(SCIGeneric(index),
                                   open: SCIGeneric(things.open!),
                                   high: SCIGeneric(things.high!),
                                   low: SCIGeneric(things.low!),
                                   close: SCIGeneric(things.close!))
        }
        
        let candleRendereSeries = SCIFastCandlestickRenderableSeries()
        candleRendereSeries.dataSeries = ohlcDataSeries
        candleRendereSeries.fillUpBrushStyle = upBodyBrush
        candleRendereSeries.fillDownBrushStyle = downBodyBrush
        candleRendereSeries.strokeUpStyle = upWickPen
        candleRendereSeries.strokeDownStyle = downWickPen
        
        return candleRendereSeries
    }
    
    func addDefaultModifiers() {
        
        let xAxisDragmodifier = SCIXAxisDragModifier()
        
        xAxisDragmodifier.dragMode = .scale
        xAxisDragmodifier.clipModeX = .none
        
        let yAxisDragmodifier = SCIYAxisDragModifier()
        yAxisDragmodifier.dragMode = .pan
        
        let extendZoomModifier = SCIZoomExtentsModifier()
        
        let pinchZoomModifier = SCIPinchZoomModifier()
        
        let rolloverModifier = SCIRolloverModifier()
        rolloverModifier.style.tooltipSize = CGSize(width: 200, height: CGFloat.nan)
        
        let marker = SCIEllipsePointMarker()
        marker.width = 20
        marker.height = 20
        marker.strokeStyle = SCISolidPenStyle(colorCode:0xFF390032,withThickness:0.25)
        marker.fillStyle = SCISolidBrushStyle(colorCode:0xE1245120)
        rolloverModifier.style.pointMarker = marker
        
        let groupModifier = SCIChartModifierCollection(childModifiers: [xAxisDragmodifier, yAxisDragmodifier, pinchZoomModifier, extendZoomModifier, rolloverModifier])
        
        surface.chartModifiers = groupModifier
    }
    
    fileprivate func addFastSmaSeries() {
        let fourierDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            fourierDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg10!))
        }
        
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = fourierDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 1.0)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        surface.renderableSeries.add(renderSeries)
    }
    
    fileprivate func addSlowSmaSeries() {
        let fourierDataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        let items = dataFeed.sortedPrices
        for ( index, things) in items.enumerated() {
            fourierDataSeries.appendX(SCIGeneric(index), y: SCIGeneric(things.movAvg200!))
        }
        
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = fourierDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), withThickness: 1.0)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        surface.renderableSeries.add(renderSeries)
    }

}
