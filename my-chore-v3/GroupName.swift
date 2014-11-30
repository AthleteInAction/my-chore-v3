//
//  GroupName.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class GroupName: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var nextBTN: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTXT.delegate = self
        nextBTN.enabled = false
        
        nameTXT.addTarget(self, action: "nameCHG", forControlEvents: UIControlEvents.EditingChanged)
        
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

    @IBAction func cancelTPD(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func nameCHG(){
        
        if nameTXT.text != "" {
            
            nextBTN.enabled = true
            
        } else {
            
            nextBTN.enabled = false
            
        }
        
    }
    
    @IBAction func nextTPD(sender: UIBarButtonItem) {
        
        if nameTXT.text != "" {
            
            self.performSegueWithIdentifier("add_people_from_new_group", sender: self)
            
        }
        
    }
    
}
