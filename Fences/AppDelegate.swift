//
//  AppDelegate.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let FencesLocationManagerDelegateInstance = FencesLocationManagerDelegate()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSLog("loading store")
        GetFenceStore()
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FencesLocationManagerDelegateInstance.locationManager.startUpdatingLocation()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        FencesLocationManagerDelegateInstance.locationManager.stopUpdatingLocation()
        FenceStore.save() {
            success in
            let msg = success ? "" : "un"
            NSLog("Enter background save \(msg)successful")
        }
    }
}

