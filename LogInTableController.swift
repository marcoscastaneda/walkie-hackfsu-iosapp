//
//  LogInTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit
import Parse

class LogInTableController: UITableViewController {
    
    // Firebase ref
//    let ref = Firebase(url: "https://walkieapp.firebaseio.com")

    @IBOutlet weak var textFieldEmailAddress: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Log In"
        
        // Remove seperators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Remove back button text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textFieldEmailAddress.becomeFirstResponder()
    }
    
    
    @IBAction func logInTouched(sender: AnyObject) {
    
        
        PFUser.logInWithUsernameInBackground(self.textFieldEmailAddress.text!, password: self.textFieldPassword.text!) { (user: PFUser?, error: NSError?) -> Void in
            
            if (error != nil)
            {
                JDStatusBarNotification.showWithStatus(error!.localizedDescription, dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
            }
            else
            {

                self.navigationController!.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("LoggedInRoot") as! UITabBarController, animated: true, completion: nil)
            }
        }
        /* Firebase login
        ref.authUser(self.textFieldEmailAddress.text, password: self.textFieldPassword.text,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                    
                    JDStatusBarNotification.showWithStatus(error.localizedDescription, dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
                    
                } else {
                    // Login success
                    self.navigationController!.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("LoggedInRoot") as! UITabBarController, animated: true, completion: nil)
                    
                }
        }) */
        
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}