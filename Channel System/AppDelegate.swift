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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 11,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 11) {
                    migration.enumerateObjects(ofType: MarketCondition.className()) { oldObject, newObject in
                        let matrixCondition = ""
                        newObject?["matrixCondition"] = matrixCondition
                        let matrixResult = 0
                        newObject?["matrixResult"] = matrixResult
                }
            }
        })
        Realm.Configuration.defaultConfiguration = config
        
        // License Contract
        let licencing:String = "<LicenseContract>" +
        "<Customer>Swift Sense</Customer>" +
        "<OrderId>ABT171115-1656-88135</OrderId>" +
        "<LicenseCount>1</LicenseCount>" +
        "<IsTrialLicense>false</IsTrialLicense>" +
        "<SupportExpires>11/15/2018 00:00:00</SupportExpires>" +
        "<ProductCode>SC-IOS-2D-PRO</ProductCode>" +
        "<KeyCode>364e0b1c08ae94c831328cb783064a526d8ca335a2cb9de59ca53352ae5ed1f01092defffaafec2fbf9800261297e78b5c6e1dc909af374f2f8db8e7996b06f16d55b7dcb3a4cbe34c386396e5ec55af702b90c19eb821ba267e856d724ba4592b8ab35d9a58114583e7ba7af11d8750530bdb965c0a23be79df43b95cb0e9f4cdc7fe1787a37b09751da452cc8dd62bd5e36304ea5c82c9c54d65a9a43472aa5b066762</KeyCode>" +
        "</LicenseContract>"
        
        SCIChartSurface.setRuntimeLicenseKey(licencing)
        
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

