//
//  SignUpFinishTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit
import Parse

class SignUpFinishTableController: UITableViewController {
    
    // Firebase ref
//    let ref = Firebase(url: "https://walkieapp.firebaseio.com")
    
    @IBOutlet weak var labelHelloName: UILabel!
    var userFullName:String?

    @IBOutlet weak var textFieldEmailAddress: UITextField!
    @IBOutlet weak var textFieldPassword1: UITextField!
    @IBOutlet weak var textFieldPassword2: UITextField!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sign Up"
        
        // Remove seperators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Remove back button text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if (userFullName != nil) {
            
            let firstName = userFullName!.componentsSeparatedByString(" ").first! as String
            self.labelHelloName.text = "Hi \(firstName)!"
        }
    }
    
    @IBAction func completeSignUpTouched(sender: AnyObject) {
        
        // Validate all text fields
        if (self.textFieldEmailAddress.text?.characters.count > 3 && self.textFieldPassword1.text?.characters.count > 3 && self.textFieldPassword2.text?.characters.count > 3 && self.textFieldPhoneNumber.text?.characters.count > 3)
        {
            // Check if password fields are the same
            if (self.textFieldPassword1.text != self.textFieldPassword2.text)
            {
                JDStatusBarNotification.showWithStatus("Error: The passwords you entered don't match!", dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
                return
            }
            
            let user = PFUser()
            user.username = self.textFieldEmailAddress.text
            user.password = self.textFieldPassword1.text
            user.email = self.textFieldEmailAddress.text
            // other fields can be set just like with PFObject
            user["fullName"] = self.userFullName
            user["phoneNumber"] = self.textFieldPhoneNumber.text
            
            user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                      self.navigationController!.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("LoggedInRoot") as! UITabBarController, animated: true, completion: nil)
                }
                else if error != nil
                {
                    JDStatusBarNotification.showWithStatus(error!.localizedDescription, dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
                }
            })

            
            /* Signup with firebase
        
            ref.createUser(self.textFieldEmailAddress.text, password: self.textFieldPassword1.text,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        // There was an error creating the account
                        JDStatusBarNotification.showWithStatus(error.localizedDescription, dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
                        
                    } else {
                        // Successfully created account
                        
                        
                        
                        let uid = result["uid"] as? String
                        
                        let usersRef = self.ref.childByAppendingPath("users").childByAppendingPath(uid)
                        usersRef.childByAppendingPath("fullName").setValue(self.userFullName)
                        usersRef.childByAppendingPath("phoneNumber").setValue(self.textFieldPhoneNumber.text)
                        
//                        usersRef.setValue(self.userFullName, forUndefinedKey: "fullName")
//                        usersRef.setValue(self.textFieldPhoneNumber.text, forUndefinedKey: "phoneNumber")
////                        usersRef.childByAppendingPath(uid)
                        
//                        usersRef.childByAppendingPath(uid).childByAppendingPath("fullName").setValue(self.userFullName)
//                        usersRef.childByAppendingPath(uid).childByAppendingPath("phoneNumber").setValue(self.textFieldPhoneNumber.text)

                        
                        self.navigationController!.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("LoggedInRoot") as! UITabBarController, animated: true, completion: nil)
                    }
            }) */
        }
        else
        {
            JDStatusBarNotification.showWithStatus("Error: Missing a required text field.", dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textFieldEmailAddress.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
