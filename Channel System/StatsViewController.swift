//
//  StatsViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 11/29/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    var galaxie = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        galaxie = SymbolLists().uniqueElementsFrom(testTenOnly: true)
    }

    @IBAction func runBackTestAction(_ sender: Any) {

        let result = BackTest().getResults(ticker: "KO")
        print("\nResult = \(result.0) \(result.1) \(result.2)\n")

    }
    
}
