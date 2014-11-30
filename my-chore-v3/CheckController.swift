//
//  ViewController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit
import CoreData

class CheckController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if currentUser != nil {
            
            self.performSegueWithIdentifier("groups_from_check", sender: self)
            
        } else {
            
            if account_info == "" {
                
                self.performSegueWithIdentifier("verify_from_check", sender: self)
                
            } else {
                
                PFUser.logInWithUsernameInBackground(account_info, password: account_info) {
                    (user: PFUser!, error: NSError!) -> Void in
                    if user != nil {
                        
                        // SUCCESS
                        currentUser = PFUser.currentUser()
                        NSLog("LOGIN SUCCESSFUL")
                        println(currentUser)
                        
                    } else {
                        
                        // FAILED
                        NSLog("LOGIN FAILED")
                        
                    }
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }


}

