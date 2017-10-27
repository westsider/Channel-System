//
//  Date Utility.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

class DateHelper {
    
    let formatter = DateFormatter()
    let today = Date()
    
    func convertToDateFrom(string: String, debug: Bool)-> Date {
        if ( debug ) { print("\n0. date from server as string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "yyyy/MM/dd"
        let date:Date = formatter.date(from: dateS)!
        
        if ( debug ) { print("Convertion to Date: \(date)\n") }
        return date
    }
}
