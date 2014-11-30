//
//  ChangeNameController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/29/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class ChangeNameController: UIViewController {

    var group: PFObject!
    
    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var saveBTN: UIBarButtonItem!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTXT.addTarget(self, action: "nameCHG", forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        nameTXT.text = group["name"] as String
        nameTXT.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    func nameCHG(){
        
        if nameTXT.text != "" {
            
            saveBTN.enabled = true
            
        } else {
            
            saveBTN.enabled = false
            
        }
        
    }

    @IBAction func saveTPD(sender: UIBarButtonItem) {
        
        if nameTXT.text != "" {
            
            nameTXT.enabled = false
            nameTXT.alpha = 0.7
            loader.startAnimating()
            
            group["name"] = nameTXT.text
            
            group.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                
                if success {
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    NSLog("SAVE ERROR")
                    
                }
                
                self.nameTXT.enabled = true
                self.nameTXT.alpha = 1.0
                self.loader.stopAnimating()
                
            })
            
        }
        
    }
    
}
