//
//  LogInTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit

class LogInTableController: UITableViewController {

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
    
    @IBAction func closeAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}