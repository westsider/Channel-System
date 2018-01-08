//
//  4.3 Limited Portfolio Util.swift
//  Channel System
//
//  Created by Warren Hansen on 1/6/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class EntryUtil {
    
    /** filter buy signal with stars, mc, portfolio */
    func buyConfirmation(ticker:String, portfolio: [String: Double], tStars:Int, mStars:Int, date:Date, capReq:Double)->Bool {
        
        let mc = EntryUtil().checkMatrix(date: date)
        
        if portfolio[ticker] == nil  && portfolio.count < 20  && tStars >= mStars && mc && capReq != 0.00 {
            return true
        } else {
            return false
        }
    }

    func checkMatrix(date:Date)-> Bool {
        let matrix = MarketCondition().getMatixToProveOnChart(date: date)
        var mc = false
        if matrix <= 6 {
            mc = true
        }
        return mc
    }

    func sellConfirmation(ticker:String, portfolio: [String: Double], tStars:Int, mStars:Int, date:Date, capReq:Double)->Bool {
        return true
    }
}
