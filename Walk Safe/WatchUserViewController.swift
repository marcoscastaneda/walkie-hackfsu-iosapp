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

class WatchUserViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var textFieldEmailAddressToView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var isWalkingWithFriend = false
    var userObjectID:String!
    var userFullName:String!
    
    @IBOutlet var viewAddFriend: UIView!
    
    // Firebase ref
    let ref = Firebase(url: "https://walkieapp.firebaseio.com/geolocation")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
        }
        else {
            UIView.animateWithDuration(NSTimeInterval.abs(0.5), animations: { () -> Void in
                self.viewAddFriend.alpha = 0
                self.viewAddFriend.hidden = true
                
                self.mapView.hidden = false
                self.mapView.alpha = 1
            })
            
            let userRef = self.ref.childByAppendingPath(self.userObjectID)
            userRef.observeEventType(FEventType.ChildChanged, withBlock: { (snap: FDataSnapshot!) -> Void in
                print( snap.
            })
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.view.endEditing(true)
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
