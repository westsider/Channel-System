//
//  ShowTrades.swift
//  Channel System
//
//  Created by Warren Hansen on 11/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import SciChart

class ShowTrades {
    
    let annotationGroup = SCIAnnotationCollection()
    
    func showTradesOnChart(currentBar: Int, signal: Bool, high: Double, low: Double, xID:String, yID:String)-> SCIAnnotationCollection {
        if( signal ) {
            //print("\nLong signal: \(signal) on bar \(currentBar)")
            annotationGroup.add( createUpArrow(Date: currentBar, Entry: low, xID: xID, yID: yID) )
        }
        return annotationGroup
    }
    
    func createUpArrow(Date: Int, Entry:Double, xID:String, yID:String)-> SCICustomAnnotation {
        let customAnnotationGreen = SCICustomAnnotation()
        customAnnotationGreen.customView = UIImageView.init(image: UIImage.init(named: "chevronUpBlue"))
        customAnnotationGreen.x1=SCIGeneric(Date)
        customAnnotationGreen.y1=SCIGeneric(Entry)
        customAnnotationGreen.xAxisId = xID
        customAnnotationGreen.yAxisId = yID
        return customAnnotationGreen
    }
    
    func createDnArrow(Date: Int, Entry:Double, xID:String, yID:String)-> SCICustomAnnotation {
        let customAnnotationGreen = SCICustomAnnotation()
        customAnnotationGreen.customView = UIImageView.init(image: UIImage.init(named: "triangleDown"))
        customAnnotationGreen.x1=SCIGeneric(Date)
        customAnnotationGreen.y1=SCIGeneric(Entry)
        customAnnotationGreen.xAxisId = xID
        customAnnotationGreen.yAxisId = yID
        return customAnnotationGreen
    }
    
    func createExit(Date: Int, Entry:Double, xID:String, yID:String)-> SCICustomAnnotation {
        let customAnnotationGreen = SCICustomAnnotation()
        customAnnotationGreen.customView = UIImageView.init(image: UIImage.init(named: "exit"))
        customAnnotationGreen.x1=SCIGeneric(Date)
        customAnnotationGreen.y1=SCIGeneric(Entry)
        customAnnotationGreen.xAxisId = xID
        customAnnotationGreen.yAxisId = yID
        return customAnnotationGreen
    }
    
}
