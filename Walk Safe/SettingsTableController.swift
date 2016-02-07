//
//  SettingsTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit
import Parse

class SettingsTableController: UITableViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var imageViewUserProfile: UIImageView!
    
    @IBOutlet weak var labelUserFullName: UILabel!
    @IBOutlet weak var labelUserEmail: UILabel!
    
    @IBOutlet weak var switchAudibleAlert: UISwitch!
    @IBOutlet weak var switchShakeAlert: UISwitch!
    @IBOutlet weak var switchHeadphoneAlert: UISwitch!
    
    // Device defaults
    let defaultAlertPreferences = NSUserDefaults.standardUserDefaults()
    
    // Firebase ref
//    let ref = Firebase(url: "https://walkieapp.firebaseio.com")
    let currentUser = PFUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        self.labelUserFullName.text = currentUser!["fullName"] as? String
        self.labelUserEmail.text = currentUser!.email
        
        if (defaultAlertPreferences.boolForKey("audibleAlert") == true)
        {
            self.switchAudibleAlert.on = true
        } else {
            self.switchAudibleAlert.on = false
        }
        
        if (defaultAlertPreferences.boolForKey("shakeAlert") == true)
        {
            self.switchShakeAlert.on = true
        } else {
            self.switchShakeAlert.on = false
        }
        
        if (defaultAlertPreferences.boolForKey("headphoneAlert") == true)
        {
            self.switchHeadphoneAlert.on = true
        } else {
            self.switchHeadphoneAlert.on = false
        }
        
        // Remove seperators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Remove back button text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        
        let alert = UIAlertView(title: "Log Out?", message: "Are you sure you want to log out?", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "Log Out")
        alert.tag = 0
        alert.delegate = self
        alert.show()
    }
    
    
    @IBAction func switchChanged(sender: AnyObject) {
        
        print("changed")
        
        self.defaultAlertPreferences.setBool(switchAudibleAlert.on, forKey: "audibleAlert")
        self.defaultAlertPreferences.setBool(switchShakeAlert.on, forKey: "shakeAlert")
        self.defaultAlertPreferences.setBool(switchHeadphoneAlert.on, forKey: "headphoneAlert")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Add emergency contact
        if (indexPath.row == 1)
        {
            let alert = UIAlertController(title: "Emergency Contact",
                message: "Enter the phone number of your emergency contact",
                preferredStyle: .Alert)
            
            let saveAction = UIAlertAction(title: "Save Contact",
                style: .Default) { (action: UIAlertAction!) -> Void in
                    
                let contactField = alert.textFields![0].text

                self.defaultAlertPreferences.setValue(contactField, forKey: "emergencyContact")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel",
                style: .Default) { (action: UIAlertAction!) -> Void in
            }
            
            alert.addTextFieldWithConfigurationHandler {
                (textEmail) -> Void in
                
                if (self.defaultAlertPreferences.valueForKey("emergencyContact") != nil)
                {
                    textEmail.placeholder = self.defaultAlertPreferences.valueForKey("emergencyContact") as? String
                }
                else { textEmail.placeholder = "Phone Number" }
                textEmail.keyboardType = UIKeyboardType.PhonePad
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            presentViewController(alert,
                animated: true,
                completion: nil)
            
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        // Log Out User
        if (alertView.tag == 0)
        {
            // Cancel request to log out
            if (buttonIndex == 0)
            {
                // do nothing
            }
                
            // Yes, log out
            else if (buttonIndex == 1)
            {
                PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
                    if (error == nil)
                    {
                        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("Root") as UIViewController
                        
                        UIView.transitionWithView(delegate.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                            delegate.window?.rootViewController = vc
                            }, completion: nil)
                    }
                }
            }
        }
    }
    

    

}
