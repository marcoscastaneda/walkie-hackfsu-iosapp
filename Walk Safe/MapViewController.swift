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

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var startWalkButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "walkie"
    }
    
    override func viewWillAppear(animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
        
        // Button appearances
        self.startWalkButton.layer.borderWidth = 1.2
        self.startWalkButton.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (self.mapView.showsUserLocation && self.mapView.userLocation.location != nil)
        {
            let span = MKCoordinateSpanMake(0.0125, 0.0125)
            let region = MKCoordinateRegion(center: self.mapView.userLocation.location!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    
        
    }
    @IBAction func startWalkTouched(sender: AnyObject) {
        UIView.animateWithDuration(NSTimeInterval.abs(0.5)) { () -> Void in
            self.mapView.hidden = false
            self.mapView.alpha = 1
            self.startWalkButton.hidden = true
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
