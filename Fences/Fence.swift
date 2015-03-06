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


class Fence: NSObject, NSCoding, Equatable, Storeable {
    var createdOn: NSDate = NSDate()
    var key: String = NSUUID().UUIDString
    var internalCoordinate: CLLocationCoordinate2D!
    var range: CLLocationDistance
    var location: CLLocation {
        get {
            return CLLocation(latitude: internalCoordinate.latitude, longitude: internalCoordinate.longitude)
        }
    }
    
    var active: Bool
        
    override init() {
        self.range = 200
        self.active = false
    }
    
    init(coordinate: CLLocationCoordinate2D, range: CLLocationDistance) {
        self.internalCoordinate = coordinate;
        self.range = range
        self.active = false
    }
    
    func activate(locationManager: CLLocationManager) {
        let region = CLCircularRegion(center: internalCoordinate, radius: range, identifier: key)
        locationManager.startMonitoringForRegion(region)
        active = true
    }
    
    func deactivate(locationManager: CLLocationManager) {
        for region: CLRegion in locationManager.monitoredRegions as! Set<CLRegion> {
            if region.identifier == key {
                locationManager.stopMonitoringForRegion(region)
                active = false
                break
            }
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(createdOn, forKey: "createdOn")
        aCoder.encodeObject(key, forKey: "key")
        aCoder.encodeDouble(internalCoordinate.latitude, forKey: "internalCoordinate_latitude")
        aCoder.encodeDouble(internalCoordinate.longitude, forKey: "internalCoordinate_longitude")
        aCoder.encodeDouble(range, forKey: "range")
        aCoder.encodeBool(active, forKey: "active")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.createdOn = aDecoder.decodeObjectForKey("createdOn") as! NSDate
        self.key = aDecoder.decodeObjectForKey("key") as! String
        self.internalCoordinate = CLLocationCoordinate2DMake(
            aDecoder.decodeDoubleForKey("internalCoordinate_latitude"),
            aDecoder.decodeDoubleForKey("internalCoordinate_longitude")
        )
        self.range = aDecoder.decodeDoubleForKey("range")
        self.active = aDecoder.decodeBoolForKey("active")
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

let FenceStore = Store<Fence>(filePath: filePathInDocumentsDirectory("fences.plist")) { return Fence() }