//
//  SignUpTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit

class SignUpTableController: UITableViewController {
    
    @IBOutlet weak var textFieldUserFullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sign Up"
        
        // Remove seperators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Remove back button text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textFieldUserFullName.becomeFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass ride object information to detail table
        if (segue.identifier == "SignUpNext")
        {
            let vc = segue.destinationViewController as! SignUpFinishTableController
            vc.userFullName = textFieldUserFullName.text
        }
        
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        if (textFieldUserFullName.text?.characters.count < 3)
        {
            JDStatusBarNotification.showWithStatus("Error: The name entered is too short!", dismissAfter: NSTimeInterval.abs(3), styleName: JDStatusBarStyleError)
        }
        else
        {
            self.performSegueWithIdentifier("SignUpNext", sender: nil)
        }
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}