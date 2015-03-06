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

class FencesLocationManagerDelegate: NSObject {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}

extension FencesLocationManagerDelegate: CLLocationManagerDelegate {
    func locationManager(
        manager: CLLocationManager!,
        didUpdateToLocation newLocation: CLLocation!,
        fromLocation oldLocation: CLLocation!) {
            CurrentUserLocation = newLocation
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if let fence = FenceStore.get(region.identifier) {
            let notification = UILocalNotification()
            notification.alertBody = "Approaching \(fence.key)"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
}