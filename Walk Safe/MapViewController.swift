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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    var hasLoaded = false
    var destinationSelected = false
    
    @IBOutlet weak var buttonLoading: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarDestination: UISearchBar!
    
    var destinationName: String?
    var destinationPin = MKPointAnnotation()
    
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
        
        if (hasLoaded)
        {
            self.navigationItem.rightBarButtonItem!.enabled = true
            
            self.destinationPin.coordinate = self.mapView.region.center
            self.mapView.addAnnotation(self.destinationPin)
        }
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

}
