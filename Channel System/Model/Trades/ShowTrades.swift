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
            annotationGroup.add( createUpArrow(Date: currentBar, Entry: low, xID: xID, yID: yID) )
            //annotationGroup.add( createStats( xID: xID, yID: yID) )
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
    
    func showStats( xID:String, yID:String, date:Double, price:Double, text: String)-> SCITextAnnotation {
        
        let textAnnotation = SCITextAnnotation()
        textAnnotation.coordinateMode = .absolute;
        textAnnotation.x1 = SCIGeneric(date);
        textAnnotation.y1 = SCIGeneric(price);
        textAnnotation.horizontalAnchorPoint = .left;
        textAnnotation.verticalAnchorPoint = .top;
        
        let textStyle = SCITextFormattingStyle()
        textStyle.fontName = "Helvetica"
        textStyle.fontSize = 14
        textAnnotation.text = text
        textAnnotation.style.textStyle = textStyle;
        textAnnotation.style.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        textAnnotation.style.backgroundColor = #colorLiteral(red: 0.1247214451, green: 0.1294646859, blue: 0.1380600333, alpha: 0.5)
        textAnnotation.isEditable = false

        textAnnotation.xAxisId = xID
        textAnnotation.yAxisId = yID
        return textAnnotation
    }
    
    func showMatrix( xID:String, yID:String, date:Double, price:Double, text: String)-> SCITextAnnotation {
        
        let textAnnotation = SCITextAnnotation()
        textAnnotation.coordinateMode = .absolute;
        textAnnotation.x1 = SCIGeneric(date);
        textAnnotation.y1 = SCIGeneric(price);
        textAnnotation.horizontalAnchorPoint = .left;
        textAnnotation.verticalAnchorPoint = .top;
        
        let textStyle = SCITextFormattingStyle()
        textStyle.fontName = "Helvetica"
        textStyle.fontSize = 14
        textAnnotation.text = text
        textAnnotation.style.textStyle = textStyle;
        textAnnotation.style.textColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        textAnnotation.style.backgroundColor = #colorLiteral(red: 0.1247214451, green: 0.1294646859, blue: 0.1380600333, alpha: 0)
        textAnnotation.isEditable = false
        
        textAnnotation.xAxisId = xID
        textAnnotation.yAxisId = yID
        return textAnnotation
    }
    
//    func showGuidanceForChart( xID:String, yID:String, date:Double, price:Double, text: String)-> SCITextAnnotation {
//        
//        let textAnnotation = SCITextAnnotation()
//        textAnnotation.coordinateMode = .absolute;
//        textAnnotation.x1 = SCIGeneric(date);
//        textAnnotation.y1 = SCIGeneric(price);
//        textAnnotation.horizontalAnchorPoint = .left;
//        textAnnotation.verticalAnchorPoint = .top;
//        
//        let textStyle = SCITextFormattingStyle()
//        textStyle.fontName = "Helvetica"
//        textStyle.fontSize = 14
//        textAnnotation.text = text
//        textAnnotation.style.textStyle = textStyle;
//        textAnnotation.style.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        textAnnotation.style.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        textAnnotation.isEditable = false
//        
//        //textAnnotation.x1 = SCIGeneric(Date);
//        //textAnnotation.y1 = SCIGeneric(Entry);
//        textAnnotation.xAxisId = xID
//        textAnnotation.yAxisId = yID
//        return textAnnotation
//    }
    
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
    
    fileprivate func setupAnnotations(xID:String, yID:String) {
        let textStyle = SCITextFormattingStyle()
        textStyle.fontSize = 20

        buildTextAnnotation(x:10, y:10.5,
                            horizontalAnchorPoint: .left,
                            verticalAnchorPoint: .top,
                            textStyle: textStyle,
                            coordMode: .absolute,
                            text: "Buy!",
                            xID: xID, yID: yID)
    }

    private func buildTextAnnotation(x:Double, y:Double, horizontalAnchorPoint:SCIHorizontalAnchorPoint, verticalAnchorPoint:SCIVerticalAnchorPoint, textStyle:SCITextFormattingStyle, coordMode:SCIAnnotationCoordinateMode, text:String, xID:String, yID:String){

        let textAnnotation = SCITextAnnotation()
        textAnnotation.coordinateMode = coordMode;
        textAnnotation.xAxisId = xID
        textAnnotation.yAxisId = yID
        textAnnotation.x1 = SCIGeneric(x);
        textAnnotation.y1 = SCIGeneric(y);
        textAnnotation.horizontalAnchorPoint = horizontalAnchorPoint;
        textAnnotation.verticalAnchorPoint = verticalAnchorPoint;
        textAnnotation.text = text;
        textAnnotation.style.textStyle = textStyle;
        textAnnotation.style.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)  //UIColor.fromARGBColorCode(color);
        textAnnotation.style.backgroundColor = UIColor.clear
        textAnnotation.isEditable = false
        //sciChartView1.annotations.add(textAnnotation);
    }
    
}
