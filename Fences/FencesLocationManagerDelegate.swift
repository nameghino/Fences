//
//  FencesLocationManagerDelegate.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import CoreLocation

var CurrentUserLocation: CLLocation!
var CurrentUserHeading: CLHeading!

class FencesLocationManagerDelegate: NSObject {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}

extension FencesLocationManagerDelegate: CLLocationManagerDelegate {
    func locationManager(
        manager: CLLocationManager!,
        didUpdateToLocation newLocation: CLLocation!,
        fromLocation oldLocation: CLLocation!) {
            CurrentUserLocation = newLocation
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        CurrentUserHeading = newHeading
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if let fence = FenceStore.get(region.identifier) {
            let notification = UILocalNotification()
            notification.alertBody = "Approaching \(fence.key)"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
}