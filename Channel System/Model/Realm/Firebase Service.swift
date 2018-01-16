//
//  Firebase Service.swift
//  Channel System
//
//  Created by Warren Hansen on 12/25/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirbaseLink {

    let uid = "M4qmbWDT50ayvufas3c9zGzr1DG2"
    
    func auth() {
        let email = Utilities().getUserFireBase().user
        let password = Utilities().getUserFireBase().password
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let user = user {
                print(user)
            }
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

    func backUp(completion: @escaping () -> ()) {
        var ref: DatabaseReference!
        ref =  Database.database().reference().child("prices");
        let galaxie:[String] = SymbolLists().uniqueElementsFrom(testSet: false, of: 20)
        var counter:Int = 0
        var totalCount:Int = 1000000
        DispatchQueue.global(qos: .background).async {
            for ticker in galaxie {
                let thisPrice = Prices().sortOneTicker(ticker: ticker, debug: false)
                
                totalCount = galaxie.count * thisPrice.count
                for each in thisPrice {
                    let key = ref.childByAutoId().key
                    let onePrice = [ "ticker": each.ticker as String,
                        "dateString": each.dateString as String,
                        "date": "\(each.date!)" as String,
                        "exitDate": "\(each.exitDate)" as String,
                        "open": each.open as Double,
                        "high": each.high as Double,
                        "low": each.low as Double,
                        "close": each.close as Double,
                        "volume": each.volume as Double,
                        "movAvg10": each.movAvg10 as Double,
                        "movAvg200": each.movAvg200 as Double,
                        "wPctR": each.wPctR as Double,
                        // Manage Trade
                        "entry": each.entry as Double,
                        "stop": each.stop as Double,
                        "target": each.target as Double,
                        "risk": each.risk as Double,
                        "profit": each.profit as Double,
                        "loss": each.loss as Double,
                        "capitalReq": each.capitalReq as Double,
                        "backTestProfit": each.backTestProfit as Double,
                        "shares": each.shares as Int,
                        "stars": each.stars as Int,
                        "account": each.account as String,
                        "taskID": each.taskID as String,
                        "inTrade": each.inTrade as Bool,
                        "exitedTrade": each.exitedTrade as Bool,
                        "longEntry": each.longEntry as Bool,
                    ] as [String : Any]
                    
                    ref.child(key).setValue(onePrice)
                    counter += 1
                    print("Saved \(counter) of \(totalCount) to firebase")
                }
            }
        }
        if counter == totalCount {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func getPricesFromFireBase() {
        
    }
    
    func allData(clear:Bool) {
        if clear {
            FirebaseDatabase.Database.database().reference(withPath: "prices").removeValue()
        }
        

    }
}
