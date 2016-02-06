//
//  MapViewController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // INTIAL LOADUPS/UI BOOLEANS:
    let locationManager = CLLocationManager()
    var hasLoaded = false // has initial view loaded?
    var firstDestinationPicked = false  // prevent filling search bar w/ user location initially
    var destinationSelected = false
    
    // WALK/MONITORING-RELATED BOOLEANS:
    var isWalking = false   // is user walking/monitoring on?
    
    @IBOutlet weak var buttonLoading: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarDestination: UISearchBar!
    
    var destinationName: String?
    var destinationPin = MKPointAnnotation()
    var destinationPlacemark:CLPlacemark?   // hold address info
    
    
    // Map overlays
    var route:MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.userTrackingMode = MKUserTrackingMode.None
        self.navigationItem.title = "WALKIE"
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (self.mapView.showsUserLocation && self.mapView.userLocation.location != nil)
        {
            
            if (!hasLoaded)
            {
                UIView.animateWithDuration(NSTimeInterval.abs(0.5), animations: { () -> Void in
                    self.mapView.hidden = false
                    self.mapView.alpha = 1
                    self.buttonLoading.hidden = true
                    
                    }, completion: { (done: Bool) -> Void in
                    if done {
                        
                        let span = MKCoordinateSpanMake(0.0125, 0.0125)
                        let region = MKCoordinateRegion(center: self.mapView.userLocation.location!.coordinate, span: span)
                        
                        print("changed")
                        self.mapView.setRegion(region, animated: true)
                        
//                        self.searchBarDestination.becomeFirstResponder()
                    }
                })

                hasLoaded = !hasLoaded
            }
            
            if (destinationSelected)
            {
                let span = MKCoordinateSpanMake(0.0125, 0.0125)
                let region = MKCoordinateRegion(center: self.mapView.userLocation.location!.coordinate, span: span)
                
                print("changed")
                self.mapView.setRegion(region, animated: true)
            }
        }
    
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
        // Walking users don't need to change any pins
        if (isWalking)
        {
            return
        }
        
        if (hasLoaded)
        {
            // Prevent user's first location from filling up the search bar, flag it as true after.
            if (!firstDestinationPicked)
            {
                self.navigationItem.rightBarButtonItem?.enabled = false
                firstDestinationPicked = true
            }
            
            // Grab new location the user dragged to
            else {
                
            self.destinationPin.coordinate = self.mapView.region.center
            self.mapView.addAnnotation(self.destinationPin)
            
            // Geocode address where the user dropped pin
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude), completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                
                if let firstPlacemark = placemarks?[0] {
                    
                    let addressDictionary = firstPlacemark.addressDictionary
                    
                    if addressDictionary != nil {
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        
                        self.destinationName = ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary!, true)
                        self.searchBarDestination.text = self.destinationName
                    }
                    else
                    {
                        self.navigationItem.rightBarButtonItem?.enabled = false
                        
                        self.destinationName = "Error grabbing location name"
                    }
                }
                
                })
                
            }
        }
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                if error != nil {
//                    println("Reverse geocoder failed with error" + error.localizedDescription)
//                    return
//                }
//        }
    }
    
    // Custom pins
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = false
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "marker_green.png")
        
        return annotationView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    MARK: - Start/stop walk action
    
    
    @IBAction func startStopWalkAction(sender: AnyObject) {
        // MARK: - End walk monitoring
        if isWalking {
            
            let alert = UIAlertView(title: "End Walk?", message: "Are you sure you want to end your walking session?\n\nThis alert will close in 5 seconds.", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes, end this walk.")
//            var alert: UIAlertView = UIAlertView(title: "End Walk", message: "Are you sure you want to end your walk? Monitoring will be ended.", delegate: nil, cancelButtonTitle: "Cancel");
            alert.show()

            
            self.navigationItem.rightBarButtonItem?.title = "Start Walk"
        }
    
        // MARK: - Start walk monitoring
        // Show direction/route of walk
        else {
            self.navigationItem.rightBarButtonItem?.title = "End Walk"
            
            print(self.mapView.userLocation.location)
            print(self.destinationPlacemark)
            
            if (self.mapView.userLocation.location != nil && self.destinationPlacemark != nil)
            {
                // Get directions and overlay onto map
                let directionsRequest = MKDirectionsRequest()
                let userLocation = self.mapView.userLocation.location
                
    
                directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation!.coordinate, addressDictionary: nil))
                
                directionsRequest.destination = MKMapItem(placemark: MKPlacemark(placemark: self.destinationPlacemark!))
                directionsRequest.transportType = MKDirectionsTransportType.Walking
                
                let directions = MKDirections(request: directionsRequest)
                directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error: NSError?) -> Void in
                    if error == nil {
                        self.route = response!.routes[0] as MKRoute
                        self.mapView.addOverlay(self.route!.polyline)
                        print(response)
                    }
                    else
                    {
                        print(error)
                    }
                }
            }
            
            isWalking = true
        }
    }
    

}
