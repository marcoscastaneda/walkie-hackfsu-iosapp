//
//  WatchUserViewController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/7/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit
import Parse
import MapKit
import Firebase

class WatchUserViewController: UIViewController, MKMapViewDelegate, UIAlertViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldEmailAddressToView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var isWalkingWithFriend = false
    var userObjectID:String!
    var userFullName:String!
    var userPhoneNumber:String!
    
    @IBOutlet var viewAddFriend: UIView!
    
    var friendPoint:MKPointAnnotation?   // hold address info
    
    // Firebase ref
    let ref = Firebase(url: "https://walkieapp.firebaseio.com/geolocation")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldEmailAddressToView.delegate = self
        self.mapView.delegate = self

        self.navigationItem.title = "WALK WITH FRIEND"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textFieldEmailAddressToView.becomeFirstResponder()
    }
    
    @IBAction func walkAction(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        let email = self.textFieldEmailAddressToView.text!.lowercaseString
        let query = PFUser.query()
        
        query?.whereKey("email", equalTo: email)
        query?.getFirstObjectInBackgroundWithBlock({ (user: PFObject?, error: NSError?) -> Void in
            if (user != nil)
            {
                self.userObjectID = user!.objectId
                self.userFullName = user?.objectForKey("fullName") as! String
                self.userPhoneNumber = user?.objectForKey("phoneNumber") as! String
        
                let firstName = self.userFullName!.componentsSeparatedByString(" ").first! as String
                self.navigationItem.title = "WALK WITH \(firstName.uppercaseString)"
                self.updateUI()
                
            } else {
                JDStatusBarNotification.showWithStatus("No user with that e-mail address found", dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
            }
        })
        
    }
    
    func updateUI()
    {
        if isWalkingWithFriend {
            
            Firebase.goOffline()
            
            self.isWalkingWithFriend = false
            
            self.navigationItem.title = "WALK WITH FRIEND"
            self.navigationItem.rightBarButtonItem!.title = "Go"
            
        }
        else {
            UIView.animateWithDuration(NSTimeInterval.abs(0.5), animations: { () -> Void in
                self.viewAddFriend.alpha = 0
                self.viewAddFriend.hidden = true
                
                self.mapView.hidden = false
                self.mapView.alpha = 1
            })
            
            // Show loading hud
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Indeterminate
            
            print("Now watching...")
            
            Firebase.goOnline()
            
            self.navigationItem.rightBarButtonItem!.title = "Stop"
            
            
//            let userRef = self.ref.childByAppendingPath(self.userObjectID)
            
            self.ref.observeEventType(FEventType.ChildChanged, withBlock: { (snap: FDataSnapshot!) -> Void in
                
                hud.hide(true)
                
                let isOnline = snap.value.objectForKey("isOnline") as! Bool
                
                // User went offline
                if (!isOnline)
                {
                    let alert = UIAlertView(title: "Connection Lost", message: "Did \(self.userFullName) finish their walk?", delegate: nil, cancelButtonTitle: "Call \(self.userFullName)", otherButtonTitles: "Dismiss")
                    alert.tag = 0
                    alert.delegate = self
                    alert.show()
                }
                
                let lat = snap.value.objectForKey("latitude") as! CLLocationDegrees
                let long = snap.value.objectForKey("longitude") as! CLLocationDegrees
                let lastSeen = snap.value.objectForKey("lastSeen")
                
                let date = NSDate(timeIntervalSince1970: lastSeen!.doubleValue/1000.0)
                
                if (self.mapView.annotations.count > 0)
                {
                    for point in self.mapView.annotations {
                        self.mapView.removeAnnotation(point)
                    }
                }

                self.friendPoint = MKPointAnnotation()
                self.friendPoint!.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.friendPoint!.title = "\(date)"
                
                self.mapView.addAnnotation(self.friendPoint!)
                
                let span = MKCoordinateSpanMake(0.0095, 0.0095)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
                self.mapView.setRegion(region, animated: true)
                
                
                self.isWalkingWithFriend = true
                
            })
//            userRef.observeEventType(FEventType.ChildChanged, withBlock: { (snap: FDataSnapshot!) -> Void in
////                print(snap.value.objectForKey("latitude"))
////                print(snap.value.objectForKey("longitude"))
//            })
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.view.endEditing(true)
    }

    
    // Custom pins
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "marker_person.png")
        
        return annotationView
    }
    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0)
        {
            callNumber(self.userPhoneNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text?.characters.count > 0)
        {
            walkAction(self)
        }
        
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
