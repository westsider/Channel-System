//
//  Accounts.swift
//  Channel System
//
//  Created by Warren Hansen on 12/10/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Account:Object {
    
    @objc dynamic var ib = 50000.00
    @objc dynamic var tda = 280000.00
    @objc dynamic var eTrade = 250000.00
    @objc dynamic var risk = 50
    @objc dynamic var taskID = "03"
    
    func currentRisk()->Int {
        let id = "03"
        let realm = try! Realm()
        let acct = realm.objects(Account.self).filter("taskID == %@", id)
        let thisRisk = acct.first?.risk
        return thisRisk!
    }

    func textValueFor(account: String)-> String{
        let realm = try! Realm()
        let id = "03"
        let currentAcct = realm.objects(Account.self).filter("taskID == %@", id).first
        var answer = "nil"
        
        switch account {
        case "IB":
            answer =  Utilities().dollarStr(largeNumber: (currentAcct?.ib)!) 
            print("string value for IB account is \(answer)")
        case "TDA":
            answer =  Utilities().dollarStr(largeNumber: (currentAcct?.tda)!)
            print("string value for TDA account is \(answer)")
        case "E*Trade":
            answer =  Utilities().dollarStr(largeNumber: (currentAcct?.eTrade)!) 
            print("string value for  E*Trade account is \(answer)")
        case "Risk":
            answer =  Utilities().dollarStr(largeNumber: Double((currentAcct?.risk)!)) 
            print("string value for Risk account is \(answer)")
        case "Accounts":
            let total = (currentAcct?.ib)! +  (currentAcct?.tda)! + (currentAcct?.eTrade)!
            answer =  Utilities().dollarStr(largeNumber: total)
            print("string value for  accounts is \(answer)")
        default:
            print("No account founbd")
        }
        return answer
    }
    
    func updateIB(ib:Double){
        let realm = try! Realm()
        let id = "03"
        if let updateAcct = realm.objects(Account.self).filter("taskID == %@", id).first {
            try! realm.write {
                updateAcct.ib = ib
            }
        } else {
            let newAcct = Account()
            newAcct.ib = ib
            try! realm.write {
                realm.add(newAcct)
            }
        }
    }
    
    func updateTDA(tda:Double){
        let realm = try! Realm()
        let id = "03"
        if let updateAcct = realm.objects(Account.self).filter("taskID == %@", id).first {
            try! realm.write {
                updateAcct.tda = tda
            }
        } else {
            let newAcct = Account()
            newAcct.tda = tda
            try! realm.write {
                realm.add(newAcct)
            }
        }
    }
    
    func updateEtrade(eTrade:Double){
        let realm = try! Realm()
        let id = "03"
        if let updateAcct = realm.objects(Account.self).filter("taskID == %@", id).first {
            try! realm.write {
                updateAcct.eTrade = eTrade
            }
        } else {
            let newAcct = Account()
            newAcct.eTrade = eTrade
            try! realm.write {
                realm.add(newAcct)
            }
        }
    }

    func updateRisk(risk:Int){
        let realm = try! Realm()
        let id = "03"
        if let updateAcct = realm.objects(Account.self).filter("taskID == %@", id).first {
            try! realm.write {
                updateAcct.risk = risk
            }
        } else {
            let newAcct = Account()
            newAcct.risk = risk
            try! realm.write {
                realm.add(newAcct)
            }
        }
    }
    
    func debugAccount() {
        let id = "03"
        let realm = try! Realm()
        let updateAcct = realm.objects(Account.self).filter("taskID == %@", id)
        debugPrint(updateAcct)
    }
}
