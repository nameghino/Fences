//
//  FencesMapController.swift
//  Fences WatchKit Extension
//
//  Created by Nicolas Ameghino on 3/11/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import WatchKit
import Foundation


class FencesMapInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var fenceTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var mapView: WKInterfaceMap!
    @IBOutlet weak var fenceDistanceLabel: WKInterfaceLabel!
    
    let locationManager = CLLocationManager()
    let locationManagerDelegate = FencesLocationManagerDelegate()
    let watchFenceStore = GetFenceStore()
    var targetFence: Fence?
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let f = context as? Fence {
            targetFence = f
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
        
        let dlon = max((maxLong - minLong) * (1 + padding), 0.0125)
        let dlat = max((maxLat - minLat) * (1 + padding), 0.0125)
        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2DMake(
            minLat + (maxLat - minLat) / 2.0,
            minLong + (maxLong - minLong) / 2.0
        )
        
        region.span = MKCoordinateSpanMake(dlat, dlon)
        
        return region
    }
    
    override func willActivate() {
        super.willActivate()
        if let fence = targetFence {
            let locations = [fence.location]
            mapView.setRegion(regionWithLocations(locations, padding: 0.1))
            for l in locations {
                mapView.addAnnotation(l.coordinate, withPinColor: .Red)
            }
            fenceTitleLabel.setText(fence.textDescription)
            let distance = round(CurrentUserLocation.distanceFromLocation(fence.location))
            fenceDistanceLabel.setText("\(distance) m away")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

extension FencesMapInterfaceController: CLLocationManagerDelegate {
    
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
                mapView.removeAllAnnotations()
                mapView.addAnnotation(location.coordinate, withPinColor: .Green)
                mapView.addAnnotation(n.location.coordinate, withPinColor: .Red)
                
                let region = regionWithLocations([location, n.location], padding: 0.15)
                mapView.setRegion(region)
            }
            
            manager.stopUpdatingLocation()
    }
}
