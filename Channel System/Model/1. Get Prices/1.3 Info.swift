//
//  1.3 Info.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
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
    
    func databeseReport(debug:Bool, galaxie:[String])-> String {
        var counter:Int = 0
        let total = galaxie.count
        var answer:String = ""
        for ticker in galaxie {
            if let symbol = getExchangeFrom(ticker: ticker, debug: debug) {
                if debug { print("\(symbol.ticker) \(symbol.name) \(symbol.stockExchange) \(symbol.country) \(symbol.sector) \(symbol.stopSize)")}
                counter += 1
            } else {
                if debug { print("\n*** WARNING *** No comapny info for \(ticker)\n") }
            }
        }
        if counter != total {
             answer = "\n*** WARNING *** Only \(counter) company records out of \(total) records expected"
            print(answer)
        } else {
            answer = "\nCompany Database is nominal\n\(counter) records found out of \(total) expected"
            print(answer)
        }
        return answer
    }
    
    //let request = "https://api.intrinio.com/companies?identifier=\(ticker)"
    //let request = "https://api.intrinio.com/securities?identifier=\(ticker)"
    func getExchangeFrom(ticker:String, debug: Bool)-> CompanyData? {
        let realm = try! Realm()
        let id = ticker
        if let symbol = realm.objects(CompanyData.self).filter("ticker == %@", id).last  {// found nil for Dia
            if debug { print("\(String(describing: symbol.ticker)) \(String(describing: symbol.name)) \(String(describing: symbol.stockExchange)) \(String(describing: symbol.country)) \(String(describing: symbol.sector)) \(String(describing: symbol.stopSize))") }
            return symbol
        } else {
            print("\n*** WARNING *** \nCompanyData().getExchangeFrom\nNo comapny info for \(ticker)\n")
            return nil
        }
    }
    
    /////
    func getInfo(galaxie: [String], debug:Bool, completion: @escaping (Bool) -> Void) {

        var counter = 0
        let total = galaxie.count
        for ticker in galaxie {
            DispatchQueue.global(qos: .background).async {
                self.getInfoFor(ticker: ticker, debug: debug, completion: { (finished) in
                    if finished {
                        DispatchQueue.main.async {
                            counter += 1
                            print("Company \(counter) of \(total)")
                            if counter == total {
                                print("\n*** Completion for getting company data now running ***\n")
                                completion(true)
                            }
                        }
                    }
                })
                
            }
        }
    }
    
    func getInfoFor(ticker: String, debug: Bool, completion: @escaping (Bool) -> Void)  {
        // get last price from intrio
        if ( debug ) { print("Requesting company data for \(ticker)") }
        let request = "https://api.intrinio.com/securities?identifier=\(ticker)"
        
        let user = Utilities().getUser().user
        let password = Utilities().getUser().password
        
        
        Alamofire.request("\(request)")
            .authenticate(user: user, password: password)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //if ( debug ) { print("JSON: \(json)\n") }
                    // check for missing pages
                    
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
                    
                    if ( debug ) { print("\(ticker) request complete") }
                    completion(true)
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

