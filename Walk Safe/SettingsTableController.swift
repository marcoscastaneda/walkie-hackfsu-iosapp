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
    
    // Firebase ref
//    let ref = Firebase(url: "https://walkieapp.firebaseio.com")
    let currentUser = PFUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        self.labelUserFullName.text = currentUser!["fullName"] as? String
        self.labelUserEmail.text = currentUser!.email
        
//        ref.observeAuthEventWithBlock { (auth: FAuthData!) -> Void in
//            
//            self.user = User(authData: auth)
//            self.labelUserFullName.text = self.user.fullName as? String
//            self.labelUserEmail.text = self.user.email as? String
//            
//
//        }
//        authData.getUid()
        
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
