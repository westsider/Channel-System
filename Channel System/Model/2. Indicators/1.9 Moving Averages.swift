//
//  1.9 Moving Averages.swift
//  Channel System
//
//  Created by Warren Hansen on 2/18/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

import UIKit


class MovingAverage {
    var samples: Array<Double>
    var sampleCount = 0
    var period = 5
    var averages: Array<Double>
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Double>()
        averages = Array<Double>()
    }
    
    var average: Double {
        let sum: Double = samples.reduce(0, +)
        
        if period > samples.count {
            return sum / Double(samples.count)
        } else {
            return sum / Double(period)
        }
    }
    
    func addSample(value: Double) -> Double {
        
        sampleCount = sampleCount + 1
        let pos = Int(fmodf(Float(sampleCount + 1), Float(period)))
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        
        return average
    }
}

/*
 let closes = [280.410004,282.690002,283.290009,283.179993,283.299988,286.579987,284.679993,281.76001,281.899994,281.579987,275.450012,263.929993,269.130005,267.670013,257.630005,261.5,265.339996,266,269.589996,273.029999,273.109985]
 
 var movAvg = MovingAverage()
 movAvg.period = 5
 let avg = closes.map { (value) -> Double in
 return movAvg.addSample(value: value)
 }
 print(avg)
 */
