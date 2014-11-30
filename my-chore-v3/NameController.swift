//
//  NameController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class NameController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var nextTXT: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTXT.delegate = self
        
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

    @IBAction func nextTPD(sender: AnyObject) {
        
        if nameTXT.text != "" {
            
            tmp_user["name"] = nameTXT.text
            self.performSegueWithIdentifier("phone_from_name", sender: self)
            
        }
        
    }
    
}
