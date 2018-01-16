//
//  Portfolio Performance.swift
//  Channel System
//
//  Created by Warren Hansen on 1/16/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Performance: Object {
    
    @objc dynamic var date:Date?
    @objc dynamic var dailyCumProfit    = 0.00
    @objc dynamic var dailyCost         = 0.00
    @objc dynamic var taskID            = NSUUID().uuidString
    
    struct ChartData {
        var date: Date
        var dailyCumProfit:Double
        var dailyCost:Double
    }
    
    //MARK: - delete od chart data, create new
    func updateFinalTotal(data: [PortfolioFilters.StatsData] ) {
        
        let realm = try! Realm()
        let oldChartData = realm.objects(Performance.self)
        try! realm.write {
            realm.delete(oldChartData)
            for each in data {
                let chartData = Performance()
                chartData.date = each.date
                chartData.dailyCumProfit = each.dailyCumProfit
                chartData.dailyCost  = each.dailyCost
                realm.add(chartData)
            }
        }
    }
    
    func getPerformanceChart(debug:Bool)-> [ChartData] {

        var chartArray:[ChartData]  = []
        let realm = try! Realm()
        let chartData = realm.objects(Performance.self)
        let sortedByDate = chartData.sorted(byKeyPath: "date", ascending: true)
        if debug { print("\nChart Data from Realm\n") }
        for each in sortedByDate {
            let oneDay = ChartData(date: each.date!, dailyCumProfit: each.dailyCumProfit, dailyCost: each.dailyCost)
            chartArray.append(oneDay)
            if debug { printPerformanceChart(data: oneDay) }
        }
        return chartArray
    }
    
    func printPerformanceChart(data:ChartData) {
        let strDate = Utilities().convertToStringNoTimeFrom(date: data.date)
        let cp = Utilities().dollarStr(largeNumber:  data.dailyCumProfit)
        let cc = Utilities().dollarStr(largeNumber:  data.dailyCost)
        print("\(strDate)\t\(cp)\t\(cc)")
    }
}


