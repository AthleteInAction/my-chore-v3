//
//  PhoneController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class PhoneController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTXT: UITextField!
    @IBOutlet weak var submitBTN: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTXT.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }

    @IBAction func submitTPD(sender: AnyObject) {
        
        if phoneTXT.text != "" {
            
            var phone = phoneTXT.text
            phone = phone.stringByReplacingOccurrencesOfString("\\D", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: Range(start: phone.startIndex, end: phone.endIndex))
            
            tmp_user.username = phone
            tmp_user.password = phone
            
            tryLogin()
            
        }
        
    }
    
    func tryLogin(){
        
        submitBTN.hidden = true
        loader.startAnimating()
        
        PFUser.logInWithUsernameInBackground(tmp_user.username, password: tmp_user.password) {
            (user: PFUser!, error: NSError!) -> Void in
            
            if user != nil {
                
                self.loader.stopAnimating()
                
                currentUser = PFUser.currentUser()
                account_info = currentUser.username
                
                account_info.writeToFile(info_path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
                
                self.performSegueWithIdentifier("groups_from_phone", sender: self)
                
            } else {
                
                let c = error.userInfo?["code"] as? Int
                
                if c == 101 {
                    
                    self.signup()
                    
                } else {
                    
                    println(error.userInfo)
                    
                }
                
            }
            
        }
        
    }
    
    func signup(){
        
        tmp_user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            
            if !(error != nil) {
                
                self.loader.stopAnimating()
                
                currentUser = PFUser.currentUser()
                account_info = currentUser.username
                
                var error: NSError?
                account_info.writeToFile(info_path, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
                
                self.performSegueWithIdentifier("groups_from_phone", sender: self)
                
            } else {
                
                if let e = error.userInfo?["error"] as? NSString {
                    //                        self.errorTXT.text = e
                }
                println(error.userInfo)
                
            }
            
            self.submitBTN.hidden = false
            self.loader.stopAnimating()
            
        }
        
    }
    
}
