//
//  PeopleController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/28/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class PeopleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var refreshControl: UIRefreshControl!
    
    var phoneContacts: [Contact] = []
    var am_i_admin: Bool = false
    
    var group: PFObject!
    var people: [Contact] = []
    
    @IBOutlet weak var peopleTBL: UITableView!
    @IBOutlet weak var addBTN: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = group["name"] as? String
        
        phoneContacts = Contacts.getContacts()!
        
        peopleTBL.delegate = self
        peopleTBL.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        peopleTBL.addSubview(refreshControl)
        
        addBTN.enabled = false
        addBTN.tintColor = UIColor.clearColor()
        
    }
    
    func loadData(){
        
        var tmp_people: [Contact] = []
        
        var users_done: Bool = false
        var admins_done: Bool = false
        
        // USERS
        var users = group["users"] as PFRelation
        var users_query: PFQuery = users.query()
        
        users_query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil) {
                
                for o in objects {
                    
                    var user = o as PFUser
                    
                    var c = self.findContactByNumber(user.username)
                    
                    if c != nil {
                        
                        c?.user = user
                        
                    } else {
                        
                        c = Contact()
                        c?.contact_name = user["name"] as String
                        
                    }
                    
                    c?.user = user
                    
                    tmp_people.append(c!)
                    
                }
                
                users_done = true
                
                if admins_done {
                    
                    self.setData(tmp_people)
                    
                }
                
            } else {
                
                NSLog("R ERROR")
                
            }
            
        }
        
        // ADMINS
        users = group["admins"] as PFRelation
        users_query = users.query()
        
        users_query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil) {
                
                for o in objects {
                    
                    var user = o as PFUser
                    
                    var c = self.findContactByNumber(user.username)
                    
                    if c != nil {
                        
                        c?.user = user
                        
                    } else {
                        
                        c = Contact()
                        c?.contact_name = user["name"] as String
                        
                    }
                    
                    c?.user = user
                    c?.admin = true
                    
                    if c?.user.username == currentUser.username {
                        
                        self.am_i_admin = true
                        
                    }
                    
                    tmp_people.append(c!)
                    
                }
                
                admins_done = true
                
                if users_done {
                    
                    self.setData(tmp_people)
                    
                }
                
            } else {
                
                NSLog("R ERROR")
                
            }
            
        }
        
    }
    
    func setData(tmp_people: Array<Contact>){
        
        if am_i_admin {
            
            addBTN.enabled = true
            addBTN.tintColor = nil
            
        }
        
        people = tmp_people
        
        orderPeople()
        
        peopleTBL.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    func orderPeople(){
        
        people.sort({$0.contact_name < $1.contact_name})
        
        for i in 0..<people.count {
            
            var p = people[i]
            
            if p.user.username == currentUser.username {
                
                p.contact_name = "Me"
                
                people.removeAtIndex(i)
                people.insert(p, atIndex: 0)
                
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        peopleTBL.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return people.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: PeopleCell = tableView.dequeueReusableCellWithIdentifier("cell") as PeopleCell
        
        var p: Contact = people[indexPath.row] as Contact
        
        var cellTXT = p.contact_name as String
        
        if p.admin {
            
            cell.adminTXT.hidden = false
            
        } else {
            
            cell.adminTXT.hidden = true
            
        }
        
        cell.labelTXT.text = cellTXT
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var G: Contact = people[indexPath.row] as Contact
        
        var currentCell: PeopleCell = tableView.cellForRowAtIndexPath(indexPath) as PeopleCell
        
        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            var editMenu = UIAlertController(title: nil, message: "Edit", preferredStyle: .ActionSheet)
            
            var makeAdmin = UIAlertAction(title: "Make Admin", style: UIAlertActionStyle.Default, handler: nil)
            
            var removeAdmin = UIAlertAction(title: "Remove Admin", style: UIAlertActionStyle.Destructive, handler: nil)
            
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            var u = self.people[indexPath.row]
            
            if u.admin {
                
                if G.user.username != currentUser.username {
                    editMenu.addAction(removeAdmin)
                }
                
            } else {
                
                editMenu.addAction(makeAdmin)
                
            }
            
            editMenu.addAction(cancelAction)
            
            self.presentViewController(editMenu, animated: true, completion: nil)
            
        })
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPathB:NSIndexPath!) -> Void in
            
            var group_name = self.group["name"] as String
            var p_name: String = self.people[indexPath.row].contact_name as String
            
            var confirmAlert: UIAlertController!
            
            if G.user.username == currentUser.username {
                
                confirmAlert = UIAlertController(title: "Unable", message: "You cannot delete yourself from a group", preferredStyle: UIAlertControllerStyle.Alert)
                
                confirmAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    
                    
                }))
                
            } else {
                
                confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete \(p_name) from \(group_name)", preferredStyle: UIAlertControllerStyle.Alert)
                
                confirmAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    
                    currentCell.loader.startAnimating()
                    
                    var users: [Contact] = self.people
                    users.removeAtIndex(indexPath.row)
                    
                    var users_rel = self.group.relationForKey("users")
                    var admins_rel = self.group.relationForKey("admin")
                    
                    if G.admin {
                        
                        admins_rel.removeObject(G.user)
                        
                    } else {
                        
                        users_rel.removeObject(G.user)
                        
                    }
                    
                    self.group.saveInBackgroundWithBlock({ (success: Bool?, error: NSError!) -> Void in
                        
                        if !(error != nil) {
                            
                            self.people.removeAtIndex(indexPath.row)
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            
                        } else {
                            
                            NSLog("GROUP SAVE ERROR")
                            
                        }
                        
                        currentCell.loader.stopAnimating()
                        
                    })
                    
                }))
                
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    
                }))
                
            }
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
            
        })
        
        editAction.backgroundColor = UIColor.grayColor()
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction,editAction]
        
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

}
