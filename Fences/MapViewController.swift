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
    var firstLocation = true
    var activeOverlay: MKOverlay?
    
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
    
    override func viewWillAppear(animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(FenceStore.allItems)
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
        if firstLocation {
            firstLocation = false
            let delta = 0.035
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        if annotation.isKindOfClass(Fence) {
            let fence = annotation as! Fence
            
            let annotationView: MKPinAnnotationView
            if let av = mapView.dequeueReusableAnnotationViewWithIdentifier("FenceAnnotation") as? MKPinAnnotationView {
                annotationView = av
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "FenceAnnotation")
            }
            
            annotationView.pinColor = fence.active ? .Green : .Red
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay.isKindOfClass(MKCircle) {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
            renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            renderer.lineWidth = 4.0
            renderer.lineDashPattern = [20, 20]
            return renderer
        }
        
        return nil

    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let fence = view.annotation as! Fence
        
        if let ao = activeOverlay {
            mapView.removeOverlay(ao)
        }
        let overlay = MKCircle(centerCoordinate: fence.location.coordinate, radius: fence.range)
        mapView.addOverlay(overlay)
        activeOverlay = overlay
    }
    
    /*
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let ao = activeOverlay {
            mapView.removeOverlay(ao)
            activeOverlay = nil
        }
    }
    */
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .AuthorizedAlways
    }
}