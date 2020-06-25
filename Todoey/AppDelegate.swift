//
//  AppDelegate.swift
//  Todoey
//
//  Created by TomHe on 06/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //to print where it realm has stored our data. Need RealmBrowser app to open the files.
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm() //As we are not gonna use the var so use _
        } catch {
            print("Error in creating realm: \(error)")
        }
        
        return true
    }

}


