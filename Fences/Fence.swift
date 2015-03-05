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
    var range: CLLocationDistance?
    
    override init() {
        
    }
    
    init(coordinate: CLLocationCoordinate2D, range: CLLocationDistance) {
        self.internalCoordinate = coordinate;
        self.range = range
    }
}

extension Fence: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return internalCoordinate
    }
}

func ==(lhs: Fence, rhs: Fence) -> Bool {
    return false
}

let FenceStore = Store<Fence>() { return Fence() }