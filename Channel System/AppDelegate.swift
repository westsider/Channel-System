//
//  AppDelegate.swift
//  Channel System
//
//  Created by Warren Hansen on 10/27/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//
/*
 Need to migrate realm?
 
 class WorkoutSet: Object {
     // Schema 0
     dynamic var exerciseName: String = ""
     dynamic var reps: Int = 0
     // Schema 0 + 1
     dynamic var setCount: Int = 0
 }
 
 let config = Realm.Configuration(
     // Set the new schema version. This must be greater than the previously used
     // version (if you've never set a schema version before, the version is 0).
     schemaVersion: 1,
 
     // Set the block which will be called automatically when opening a Realm with
     // a schema version lower than the one set above
     migrationBlock: { migration, oldSchemaVersion in
 
        if oldSchemaVersion < 1 {
            migration.enumerate(WorkoutSet.className()) { oldObject, newObject in
            newObject?["setCount"] = setCount
            }
        }
    }
 )
 Realm.Configuration.defaultConfiguration = config
 */
import UIKit
import SciChart
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 5,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Stats.className()) { oldObject, newObject in
                        let annualProfit:Double = 0.0
                        newObject?["annualProfit"] = annualProfit
                        
                        let numYears:Double = 0.0
                        newObject?["numYears"] = numYears
                        
                        let numDays:Int = 0
                        newObject?["numDays"] = numDays
                }
            }
                if (oldSchemaVersion < 4) {
                    migration.enumerateObjects(ofType: Prices.className()) { oldObject, newObject in
                        let exitPrice:Double = 0.0
                        newObject?["exitPrice"] = exitPrice
                    }
                }
                if (oldSchemaVersion < 5) {
                    migration.enumerateObjects(ofType: Prices.className()) { oldObject, newObject in
                        let trailStop:Double = 0.0
                        newObject?["trailStop"] = trailStop
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config

        let licencing:String = UserDefaults.standard.object(forKey: "scichartLicense") as! String
        
        SCIChartSurface.setRuntimeLicenseKey(licencing)
        
        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

