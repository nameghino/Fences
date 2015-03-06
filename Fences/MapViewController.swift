//
//  MapViewController.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;

        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPressHandler:"))
    }
    
    override func viewDidAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            mapView.showsUserLocation = true;
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressHandler(lpr: UILongPressGestureRecognizer) {
        switch lpr.state {
        case .Began:
            NSLog("long press detected")
        case .Changed:
            NSLog("long press changed")
        case .Ended:
            NSLog("long press ended")
        case .Cancelled:
            NSLog("long press cancelled")
        case .Failed:
            NSLog("long press failed")
        case .Possible:
            NSLog("long press is possible")
        }
        
        if lpr.state == .Began {
            let point = lpr.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            NSLog("coordinate is \(coordinate.latitude);\(coordinate.longitude)")
            addNewFence(coordinate)
        }
    }
    
    func addNewFence(coordinate: CLLocationCoordinate2D) {
        let fence = FenceStore.create()
        fence.internalCoordinate = coordinate
        fence.range = 200
        mapView.addAnnotation(fence)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let delta = 0.035
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .AuthorizedAlways
    }
}