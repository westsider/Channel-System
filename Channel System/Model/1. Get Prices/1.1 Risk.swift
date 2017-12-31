//
//  1.1 Risk.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
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

    func currentRisk()->Int {
        let id = "03"
        let realm = try! Realm()
        let acct = realm.objects(Account.self).filter("taskID == %@", id)
        var answer:Int = 50
        if let thisRisk = acct.first?.risk {
            answer = thisRisk
        }
        return answer
    }
    
    func textValueFor(account: String)-> String{
        let realm = try! Realm()
        let id = "03"
        let currentAcct = realm.objects(Account.self).filter("taskID == %@", id).first
        var answer = "nil"
        switch account {
        case "IB":
            if let ibaccount = currentAcct?.ib {
                answer =  Utilities().dollarStr(largeNumber: ibaccount)
            } else {
                answer = "Add Amount"
            }
        case "TDA":
            if let tda = currentAcct?.tda {
                answer =  Utilities().dollarStr(largeNumber: tda)
            } else {
                answer = "Add Amount"
            }
        case "E*Trade":
            if let etrade = currentAcct?.tda {
                answer =  Utilities().dollarStr(largeNumber: etrade)
            } else {
                answer = "Add Amount"
            }
        case "Risk":
            if let risk = currentAcct?.risk {
                answer =  Utilities().dollarStr(largeNumber: Double(risk))
            } else {
                answer =  "None"
            }
        case "Accounts":
            if let ib = currentAcct?.ib, let tda = currentAcct?.tda, let eTrade = currentAcct?.eTrade  {
                let total = ib + tda + eTrade
                answer =  Utilities().dollarStr(largeNumber: total)
            } else {
                answer =  "Missing IB, TDA, E*Trade totals"
            }
        default:
            print("No account found")
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
    
    func debugAccount() {
        let id = "03"
        let realm = try! Realm()
        let updateAcct = realm.objects(Account.self).filter("taskID == %@", id)
        debugPrint(updateAcct)
    }
}
