//
//  Fence.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class Fence: NSObject, Equatable {
    let createdOn: NSDate = NSDate()
    let key: String = NSUUID().UUIDString
    var internalCoordinate: CLLocationCoordinate2D!
    var range: CLLocationDistance
    var location: CLLocation {
        get {
            return CLLocation(latitude: internalCoordinate.latitude, longitude: internalCoordinate.longitude)
        }
    }
    
    override init() {
        self.range = 200
    }
    
    init(coordinate: CLLocationCoordinate2D, range: CLLocationDistance) {
        self.internalCoordinate = coordinate;
        self.range = range
    }
    
    func activate(locationManager: CLLocationManager) {
        let region = CLCircularRegion(center: internalCoordinate, radius: range, identifier: key)
        locationManager.startMonitoringForRegion(region)
    }
    
    func deactivate(locationManager: CLLocationManager) {
        for region: CLRegion in locationManager.monitoredRegions as! Set<CLRegion> {
            if region.identifier == key {
                locationManager.stopMonitoringForRegion(region)
                break
            }
        }
    }
}

extension Fence: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return internalCoordinate
    }
    
    var title: String {
        return key
    }
    
    var subtitle: String {
        return "\(createdOn)"
    }
}

func ==(lhs: Fence, rhs: Fence) -> Bool {
    return false
}

let FenceStore = Store<Fence>() { return Fence() }