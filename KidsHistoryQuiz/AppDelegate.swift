//
//  AppDelegate.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/01/16.
//  Copyright © 2016 KvanesAS. All rights reserved.
//

import UIKit
import KapabelSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    
    // Runs after logging in from Kapabel App
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Kapabel.instance.saveInfo(userInfo: url.absoluteString)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Update Kapabel information
        let YOUR_APP_ID = 15 // You create apps in the developer dashboard // TODO: Update this
        let YOUR_API_TOKEN = "f2ae5c2d3efa8ddc16b07f2cbbb09f47" // You get this when signing up
        let YOUR_APP_GROUP_NAME = "group.kapabel.kvanes.com" // Create this in Target/Capabilities
        Kapabel.instance.parentalGate(true)
        Kapabel.instance.update(id: YOUR_APP_ID, token: YOUR_API_TOKEN, appGroup: YOUR_APP_GROUP_NAME)
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
