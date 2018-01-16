//
//  S+P Returns.swift
//  Channel System
//
//  Created by Warren Hansen on 12/23/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class SpReturns {
 
    func textForStats(yearEnding:Int)->String {
        var answer = "nil"
        if yearEnding == 2007 {
            answer = calcTenYearsReturn(start: 98.31, end: 137.37, yearEnding: yearEnding)
            print("1997 - 2007 ", answer)
            
        } else {
            answer = calcTenYearsReturn(start: 137.37, end: 267.51, yearEnding: yearEnding)
            print("2007 - 2017 ", answer)
        }
        return answer
    }
    
    func calcTenYearsReturn(start:Double, end: Double, yearEnding:Int)->String {
        let tenYrReturn = end - start
        let annualReturn = tenYrReturn / 10
        let roi = (annualReturn / end) * 100.00
        return ("10 year benchmark ending \(yearEnding) \(String(format: "%.2f", roi))% ")
    }
}
