//
//  AddPeople.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class AddPeople: UITableViewController, UISearchBarDelegate {
    
    var phoneContacts: [Contact] = []
    var appContacts: [Contact] = []
    var filteredAppContacts: [Contact] = []
    var selectedContacts: [Contact] = []
    
    @IBOutlet weak var createBTN: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBTN.enabled = false
        
        searchDisplayController?.searchResultsTableView.delegate = self
        
        phoneContacts = Contacts.getContacts()!
        
        var listA: [String] = []
        var listB: [String] = []
        var listS: String = ""
        
        for c in phoneContacts {
            
            listA.append("'\(c.phone_number)'")
            listB.append(c.phone_number as String)
            
        }
        
        listS = ",".join(listA)
        
        
        var pred = NSPredicate(format:"username IN {\(listS)}")
        var query = PFQuery(className: "_User", predicate: pred)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil) {
                
                for object in objects {
                    
                    var user = object as PFUser
                    
                    var c = self.findContactByNumber(user.username as String)
                    
                    if c != nil {
                        
                        c?.db_name = object["name"] as String
                        c?.user = user
                        self.appContacts.append(c!)
                        
                    }
                    
                }
                
                NSLog("C READY")
                
            } else {
                
                NSLog("USER QUERY ERROR")
                
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if tableView == searchDisplayController?.searchResultsTableView {
            
            return 1
            
        } else {
            
            return 1
            
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == searchDisplayController?.searchResultsTableView {
            
            return filteredAppContacts.count
            
        } else {
            
            return selectedContacts.count
            
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        if cell == nil {
            
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.selectionStyle = .None
            
        }
        
        if tableView == searchDisplayController?.searchResultsTableView {
            
            cell.textLabel.text = filteredAppContacts[indexPath.row].contact_full as String
            
        } else {
            
            if selectedContacts.count > 0 {
                
                createBTN.enabled = true
                
            } else {
                
                createBTN.enabled = true
                
            }
            
            cell.textLabel.text = selectedContacts[indexPath.row].contact_full as String
            
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == searchDisplayController?.searchResultsTableView {
            
            selectedContacts.append(filteredAppContacts[indexPath.row])
            self.tableView.reloadData()
            searchDisplayController?.setActive(false, animated: false)
            
        } else {
            
            
            
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == searchDisplayController?.searchResultsTableView {
            
            
            
        } else {
            
            if editingStyle == .Delete {
                
                selectedContacts.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                if selectedContacts.count > 0 {
                    
                    createBTN.enabled = true
                    
                } else {
                    
                    createBTN.enabled = false
                    
                }
                
            }
            
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        filteredAppContacts.removeAll(keepCapacity: true)
        
        for c in appContacts {
            
            var clean = true
            for b in selectedContacts {
                
                if b.phone_number == c.phone_number {
                    
                    clean = false
                    
                }
                
            }
            
            if clean {
                
                filteredAppContacts.append(c)
                
            }
            
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredAppContacts.removeAll(keepCapacity: true)
        
        for c in appContacts {
            
            var clean = true
            for b in selectedContacts {
                
                if b.phone_number == c.phone_number {
                    
                    clean = false
                    
                }
                
            }
            
            if clean {
                
                if (c.first_name.lowercaseString as NSString).rangeOfString(searchText.lowercaseString).length != 0 ||
                    (c.last_name.lowercaseString as NSString).rangeOfString(searchText.lowercaseString).length != 0 {
                        
                        filteredAppContacts.append(c)
                        
                }
                
            }
            
        }
        
    }
    
    func findContactByNumber(number: String) -> Contact? {
        
        var contact: Contact?
        
        for c in phoneContacts {
            
            if c.phone_number == number {
                
                contact = c
                
                break
                
            }
            
        }
        
        return contact
        
    }
    
    @IBAction func createTPD(sender: UIBarButtonItem) {
        
        NSLog("CREATE")
        
        var group = PFObject(className: "Groups")
        group["creator"] = currentUser
        group["name"] = "TEST GROUP"
        
        var users: PFRelation = group.relationForKey("users")
        var admins: PFRelation = group.relationForKey("admins")
        admins.addObject(currentUser)
        
        for c in selectedContacts {
            
            users.addObject(c.user)
            
        }
        
        group.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            
            if !(error != nil) {
                
                self.performSegueWithIdentifier("groups_from_new_group", sender: self)
                
            } else {
                
                NSLog("GROUP SAVE ERROR")
                
            }
            
        }
        
    }
    
}
