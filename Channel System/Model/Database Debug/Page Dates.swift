//
//  Page Dates.swift
//  Channel System
//
//  Created by Warren Hansen on 2/16/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PageInfo {

    class func showDatesForPages(ticker:String) {

        //      (start: "2013-10-01", end: "2013-10-01", ticker: ticker, debug: true)
        pageDateRange(ticker: ticker, debug: true) { (thesePages:[(String,Int,String,String)]) in
            if thesePages.count == 14 {

                
                print("Pages for \(ticker)")
                for each in thesePages {
                    print("\(each.1)\t\(each.2) -> \(each.3)")
                }
            }
        }
        
        /*
        Pages for SPY
         
        13    2012-12-19 -> 2013-05-14
        12    2013-05-15 -> 2013-10-04  // first date in Spy is 2013-10-01
        11    2013-10-07 -> 2014-02-28
        10    2014-03-03 -> 2014-07-23
        9     2014-07-24 -> 2014-12-12
        8     2014-12-15 -> 2015-05-08
        7     2015-05-11 -> 2015-09-30
        6     2015-10-01 -> 2016-02-24
        5     2016-02-25 -> 2016-07-18
        4     2016-07-19 -> 2016-12-07
        3     2016-12-08 -> 2017-05-03
        2     2017-05-04 -> 2017-09-25
        1     2017-09-26 -> 2018-02-16
        0     2017-09-26 -> 2018-02-16
        */

    }
    
    class func pagesForSpy()-> [(Int, Date, Date)] {
        
        var arrayOfPages:[(Int, Date, Date)] = []
        arrayOfPages.append((13, Utilities().convertToDateFrom(string: "2012-12-19", debug: false), Utilities().convertToDateFrom(string: "2013-05-14", debug: false)))
        arrayOfPages.append((12, Utilities().convertToDateFrom(string: "2013-05-15", debug: false), Utilities().convertToDateFrom(string: "2013-10-04", debug: false)))
        arrayOfPages.append((11, Utilities().convertToDateFrom(string: "2013-10-07", debug: false), Utilities().convertToDateFrom(string: "2014-02-28", debug: false)))
        arrayOfPages.append((10, Utilities().convertToDateFrom(string: "2014-03-03", debug: false), Utilities().convertToDateFrom(string: "2014-07-23", debug: false)))
        arrayOfPages.append((9, Utilities().convertToDateFrom(string: "2014-07-24", debug: false), Utilities().convertToDateFrom(string: "2014-12-12", debug: false)))
        arrayOfPages.append((8, Utilities().convertToDateFrom(string: "2014-12-15", debug: false), Utilities().convertToDateFrom(string: "2015-09-30", debug: false)))
        arrayOfPages.append((7, Utilities().convertToDateFrom(string: "2015-05-11", debug: false), Utilities().convertToDateFrom(string: "2015-09-30", debug: false)))
        arrayOfPages.append((6, Utilities().convertToDateFrom(string: "2015-10-01", debug: false), Utilities().convertToDateFrom(string: "2016-02-24", debug: false)))
        arrayOfPages.append((5, Utilities().convertToDateFrom(string: "2016-02-25", debug: false), Utilities().convertToDateFrom(string: "2016-07-18", debug: false)))
        arrayOfPages.append((4, Utilities().convertToDateFrom(string: "2016-07-19", debug: false), Utilities().convertToDateFrom(string: "2016-12-07", debug: false)))
        arrayOfPages.append((3, Utilities().convertToDateFrom(string: "2016-12-08", debug: false), Utilities().convertToDateFrom(string: "2017-05-03", debug: false)))
        arrayOfPages.append((2, Utilities().convertToDateFrom(string: "2017-05-04", debug: false), Utilities().convertToDateFrom(string: "2017-09-25", debug: false)))
        arrayOfPages.append((1, Utilities().convertToDateFrom(string: "2017-09-26", debug: false), Utilities().convertToDateFrom(string: "2018-02-16", debug: false)))
        arrayOfPages.append((0, Utilities().convertToDateFrom(string: "2017-09-26", debug: false), Utilities().convertToDateFrom(string: "2018-02-16", debug: false)))

        return arrayOfPages
 
    }

    class func pageDateRange(ticker: String,  debug: Bool, completion: @escaping ([(String,Int,String,String)]) -> Void) {
        
        var arrayOfPages:[(String,Int,String,String)] = []
        
        for i in 0...13 {
            print("Requesting page \(i) for \(ticker)") //}
            let request = "https://api.intrinio.com/prices?ticker=\(ticker)&page_number=\(i)"
            let user = Utilities().getUser().user
            let password = Utilities().getUser().password
            var dateArray:[String] = []
            
            Alamofire.request("\(request)")
                .authenticate(user: user, password: password)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for data in json["data"].arrayValue {
                            if let date = data["date"].string {
                                dateArray.append(date)
                            }
                        }  // JSON loop ends
                        if ( debug ) {
                            
                            guard let firstDate = dateArray.last else {
                                print("Warning firstDate does not exist")
                                break
                            }
                            guard let lastDate = dateArray.first else {
                                print("Warning lastDate does not exist")
                                break
                            }
                            
                            let eachPage = (ticker, i, firstDate, lastDate)
                            arrayOfPages.append(eachPage)
                            
                        }
                        completion(arrayOfPages)
                    case .failure(let error):
                        print("\n---------------------------------\n\tIntrinio Error getting \(ticker)\n-----------------------------------")
                        debugPrint(error)
                    }
            }
        }
    }
}
