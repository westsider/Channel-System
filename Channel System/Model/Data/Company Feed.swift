//
//  Company Feed.swift
//  Channel System
//
//  Created by Warren Hansen on 12/1/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//


import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class CompanyData: Object {
    
    @objc dynamic var ticker        = ""
    @objc dynamic var name  = ""
    @objc dynamic var stockExchange = ""
    @objc dynamic var country       = ""
    @objc dynamic var sector        = ""
    @objc dynamic var stopSize        = 3
    
    //let request = "https://api.intrinio.com/companies?identifier=\(ticker)"
    //let request = "https://api.intrinio.com/securities?identifier=\(ticker)"
    func getExchangeFrom(ticker:String, debug: Bool)-> CompanyData {
        let realm = try! Realm()
        let id = ticker
        let symbol = realm.objects(CompanyData.self).filter("ticker == %@", id).last!
        if debug { print("\(symbol.ticker) \(symbol.name) \(symbol.stockExchange) \(symbol.country) \(symbol.sector) \(symbol.stopSize)") }
        return symbol
    }
    
    func getInfoFor(ticker: String, debug: Bool, completion: @escaping () -> ()) {
        // get last price from intrio
        if ( debug ) { print("Requesting company data for \(ticker)") }
        let request = "https://api.intrinio.com/securities?identifier=\(ticker)"
        let user = "d7e969c0309ff3b9ced6ed36d75e6d0d"
        let password = "e6cf8f921bb621f398240e315ab79068"

        
        Alamofire.request("\(request)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //if ( debug ) { print("JSON: \(json)\n") }
                    
                    let comData = CompanyData()
     
                    if let sector = json["market_sector"].string {
                        if ( debug ) { print("\nFound sector as \(sector)") }
                        comData.sector = sector }
                    if let country = json["figi_exch_cntry"].string {
                        if ( debug ) { print("Found country as \(country)") }
                        comData.country = country }
                    if let ticker = json["ticker"].string {
                        if ( debug ) { print("Found ticker as \(ticker)") }
                        comData.ticker = ticker }
                    if let name = json["security_name"].string {
                        if ( debug ) { print("Found name as \(name)") }
                        comData.name = name }
                    
                    // NYSE 3% NASDAQ 5% IF Forign then 5%
                    if let stockExchange = json["stock_exchange"].string {
                        comData.stockExchange = stockExchange
                        if ( debug ) {
                            print("Found exchange as \(stockExchange)")
                        } else {
                            if ( debug ) {
                                print("\n----> No exchange found for \(ticker) <----\n")
                            }
                        }
                    }
                    if comData.stockExchange == "NYSE" {
                        comData.stopSize = 3
                        if ( debug ) { print("\n----> Stop for \(ticker) is now \(comData.stopSize)% <----\n") }
                    }
                    
                    if comData.stockExchange == "NASDAQ" {
                        comData.stopSize = 5
                        if ( debug ) { print("\n----> Stop for \(ticker) is now \(comData.stopSize)% <----\n") }
                    }
                    // QQQ and internationals indexes == 5% stop
                    for volatile in Symbols().international {
                        if comData.ticker == volatile {
                            comData.stopSize = 5
                            if ( debug ) { print("\n----> Stop for \(ticker) is now \(comData.stopSize)% <----\n") }
                        }
                    }
                   
                    let realm = try! Realm()
                    try! realm.write({
                        realm.add(comData)
                    })

                    DispatchQueue.main.async { completion() }
                    if ( debug ) { print("\(ticker) request complete") }
                    
                case .failure(let error):
                    /*   Error Code    Meaning
                     200    OK – Everything worked as expected
                     401    Unauthorized – Your User/Password API Keys are incorrect
                     403    Forbidden – You are not subscribed to the data feed requested
                     404    Not Found – The end point requested is not available
                     429    Too Many Requests – You have hit a limit. See Limits
                     500    Internal Server Error – We had a problem with our server. Try again later.
                     503    Service Unavailable – You have hit your throttle limit or Intrinio may be experiencing difficulties.
                     */
                    print("We had an error\(error) getting company info")
                    debugPrint(error)
                }
        }
    }
}
