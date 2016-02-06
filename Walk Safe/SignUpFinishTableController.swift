//
//  SignUpFinishTableController.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit

class SignUpFinishTableController: UITableViewController {
    
    @IBOutlet weak var labelHelloName: UILabel!
    var userFullName:String?

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
    }
    
    override func viewDidAppear(animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
