//
//  InterfaceController.swift
//  Fences WatchKit Extension
//
//  Created by Nicolas Ameghino on 3/11/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var mapView: WKInterfaceMap!
    let locationManager = CLLocationManager()
    let locationManagerDelegate = FencesLocationManagerDelegate()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        if GetFenceStore().allItems.count == 0 {
            NSLog("no fences")
        } else {
            mapView.setRegion(regionWithLocations(GetFenceStore().allItems.map({ $0.location }), padding: 0.1))
        }
        
    }
    
    func findMaxMin(items: [Double]) -> (Double, Double) {
        return (
            items.reduce(( Double.infinity), combine: { min($0, $1) }),
            items.reduce((-Double.infinity), combine: { max($0, $1) })
        )
    }
    
    func regionWithLocations(locations: [CLLocation], padding: Double) -> MKCoordinateRegion {
        
        let (minLong, maxLong) = findMaxMin(locations.map({ $0.coordinate.longitude }))
        let (minLat, maxLat) = findMaxMin(locations.map({ $0.coordinate.latitude }))
        
        let dlon = max((maxLong - minLong) * padding, 0.0125)
        let dlat = max((maxLat - minLat) * padding, 0.0125)
        
        let clon = dlon / 2.0
        let clat = dlat / 2.0
        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2DMake(clat, clon)
        region.span = MKCoordinateSpanMake(dlat, dlon)
        
        return region
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

extension InterfaceController: CLLocationManagerDelegate {
    
    func locationManager(
        manager: CLLocationManager!,
        didUpdateToLocation newLocation: CLLocation!,
        fromLocation oldLocation: CLLocation!) {
            
            let location = newLocation
            
            // Get nearest fence
            var nearest = GetFenceStore().allItems.first
            var nearestDistance = location.distanceFromLocation(nearest?.location)
            for f in GetFenceStore().allItems {
                let d = location.distanceFromLocation(f.location)
                if d < nearestDistance {
                    nearestDistance = d
                    nearest = f
                }
            }
            
            if let n = nearest {
                mapView.addAnnotation(location.coordinate, withPinColor: .Green)
                mapView.addAnnotation(n.location.coordinate, withPinColor: .Red)
                
                let region = regionWithLocations([location, n.location], padding: 0.1)
                mapView.setRegion(region)
                
            }
            
            manager.stopUpdatingLocation()
    }
}
