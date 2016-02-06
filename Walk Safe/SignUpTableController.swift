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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass ride object information to detail table
        if (segue.identifier == "SignUpNext" && sender != nil)
        {
            let vc = segue.destinationViewController as! SignUpFinishTableController
            vc.userFullName = textFieldUserFullName.text
        }
        
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}