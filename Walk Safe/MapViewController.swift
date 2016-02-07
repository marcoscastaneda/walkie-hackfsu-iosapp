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

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate {
    
    // INTIAL LOADUPS/UI BOOLEANS:
    let locationManager = CLLocationManager()
    var hasLoaded = false // has initial view loaded?
    var firstDestinationPicked = false  // prevent filling search bar w/ user location initially
    var destinationSelected = false
    
    // Device defaults
    let defaultAlertPreferences = NSUserDefaults.standardUserDefaults()
    
    // Hold for Help button
    @IBOutlet weak var buttonHoldForHelp: UIButton!
    
    // In order to prevent calling to the server every second, try to buffer each function call for routing
    var currentBuffer = 0
    
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
        
        self.locationManager.delegate = self

        self.mapView.userTrackingMode = MKUserTrackingMode.None
        self.navigationItem.title = "WALKIE"
        
        mapView.delegate = self
        
        mapView.frame = self.view.bounds;
        mapView.autoresizingMask = self.view.autoresizingMask;
        
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
                self.mapView.setRegion(region, animated: true)
            }
        }
    
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Walking users don't need to change any pins
        if isWalking
        {
            return
        }
        
        // If the map is available to the user
        if hasLoaded
        {
            // Prevent user's first location from filling up the search bar, flag it as true after.
            if (!firstDestinationPicked)
            {
                self.navigationItem.rightBarButtonItem?.enabled = false
                firstDestinationPicked = true
                return
            }
            
            // Grab new location the user dragged to
            else
            {
            
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
        
        if (annotation is MapPin)
        {
            print("Has title")
            return nil
        }
        
        if (isWalking)
        {
            return nil
        }
        
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
            alert.tag = 0
            alert.delegate = self
            alert.show()
            
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    
        // MARK: - Start walk monitoring
        // Show direction/route of walk
        else {
            isWalking = true
            
            self.searchBarDestination.userInteractionEnabled = false // disable changing of address while in walk
            
            print("DEBUG: Starting the user's walk.")
            
            // Hide tab bar
            UIView.animateWithDuration(NSTimeInterval.abs(0.5), animations: { () -> Void in
                self.tabBarController?.tabBar.hidden = true
                self.buttonHoldForHelp.hidden = false
            })
            
            self.navigationItem.title = "GETTING ETA..." // Revert title
            
            locationManager.startUpdatingLocation()
            
            self.navigationItem.rightBarButtonItem?.title = "End Walk"
            
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            
            let span = MKCoordinateSpanMake(0.0025, 0.0025)
            let region = MKCoordinateRegion(center: self.mapView.userLocation.location!.coordinate, span: span)
            
            self.mapView.setRegion(region, animated: true)
        
        }
    }
    
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MOTION DETECTED
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            
            if (self.defaultAlertPreferences.boolForKey("shakeAlert") == true)
            {
                HELPAction(self)
            }
        
        }
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        // Cancelling walk
        if (alertView.tag == 0)
        {
            // Cancel request to stop walk
            if (buttonIndex == 0)
            {
                // do nothing
            }
            
            // Yes, stop this walk
            else if (buttonIndex == 1)
            {
                print("DEBUG: Stopping the user's walk")
                
                self.navigationItem.title = "WALKIE" // Revert title
                
                // Show tab bar
                UIView.animateWithDuration(NSTimeInterval.abs(0.5), animations: { () -> Void in
                    self.tabBarController?.tabBar.hidden = false
                    self.buttonHoldForHelp.hidden = true
                })
                
                locationManager.stopUpdatingLocation()
                
                
                if (self.mapView.overlays.count > 0)
                {
                    self.mapView.removeOverlay(self.route!.polyline)
                }
                
                let span = MKCoordinateSpanMake(0.0125, 0.0125)
                let region = MKCoordinateRegion(center: self.mapView.userLocation.location!.coordinate, span: span)
                self.mapView.setRegion(region, animated: false)
                
                self.searchBarDestination.userInteractionEnabled = true
                self.searchBarDestination.text = ""
                
                self.mapView.removeAnnotation(self.destinationPin)
                
                self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
                
                self.navigationItem.rightBarButtonItem?.title = "Start Walk"
                isWalking = false
            }
        }
    }
    
    // MARK: - User's location did update
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Prevent calling this function logic so often
        if (self.currentBuffer >= 7)
        {
            self.currentBuffer = 0
        } else {
            self.currentBuffer++
            return
        }
        
        // Get directions and overlay onto map
        let directionsRequest = MKDirectionsRequest()
        
        // VERY Hacky solution to prevent pin collision
        
        let currentPlacemark = MapPin(coordinate: locations.first!.coordinate, title: "??", subtitle: "??")
//        let currentsPlacemark = MKPlacemark(coordinate: locations.first!.coordinate, addressDictionary: nil)
        let destinationPlacemark = MapPin(coordinate: self.destinationPin.coordinate, title: "??", subtitle: "??")
//        var destinationPlacemark = MKPlacemark(coordinate: self.destinationPin.coordinate, addressDictionary: nil)
//        destinationPlacemark.
        
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: currentPlacemark.coordinate, addressDictionary: nil))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationPlacemark.coordinate, addressDictionary: nil))
        directionsRequest.transportType = MKDirectionsTransportType.Walking
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error: NSError?) -> Void in
            if error == nil {
                self.route = response!.routes[0] as MKRoute
                self.mapView.addOverlay(self.route!.polyline)
                var ETA = Int(self.route!.expectedTravelTime / 60)
            
                self.navigationItem.title = "ETA: \(ETA) MIN"
            }
            else
            {
                print(error)
            }
        }
        /*
                let location = locations.last! as CLLocation
        
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
                self.mapView.setRegion(region, animated: true) */
    }
    
    // Add route line to map
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: route!.polyline)
        myLineRenderer.strokeColor = UIColor(red: 25/255, green: 138/255, blue: 242/255, alpha: 0.6)
        myLineRenderer.lineWidth = 4
        return myLineRenderer
    }
    
//    MARK: - HELP
    @IBAction func HELPAction(sender: AnyObject) {
        
        let actionSheet = UIActionSheet(title: "If you are in imminent danger, CALL 911 NOW.", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Call 911", otherButtonTitles: "Call FSU Police")
        
        if (self.defaultAlertPreferences.valueForKey("emergencyContact") != nil)
        {
            actionSheet.addButtonWithTitle("Call Emergency Contact")
        }
        
        // Check if user can open Uber app
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!) {
            actionSheet.addButtonWithTitle("Request Uber")
        }

        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(self.view)

        
        print("HELP")
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        print(buttonIndex)
        if (buttonIndex == 0)
        {
            print("911")
        }
        else if (buttonIndex == 2)
        {
            print("campus police")
        }
        else if (buttonIndex == 3)
        {
            print("emergency contact")
        }
        // Request Uber to user location
        else if (buttonIndex == 4)
        {
            UIApplication.sharedApplication().openURL(NSURL(string: "uber://?action=setPickup&pickup=my_location")!)
        }
    }
//    override func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        
//        print("Change")
//        
//        let location = locations.last as! CLLocation
//        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        self.mapView.setRegion(region, animated: true)
//    }
    

}
