//
//  GroupsController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class GroupsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var peopleView: PeopleController!
    var changeNameView: ChangeNameController!
    
    var refreshControl: UIRefreshControl!
    var tmp_title: String!
    
    var groups: [Group] = []
    var selectedGroup: PFObject!
    
    @IBOutlet weak var groupsTBL: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupsTBL.delegate = self
        groupsTBL.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        groupsTBL.addSubview(refreshControl)
        
        tmp_title = navigationItem.title
        
        peopleView = storyboard?.instantiateViewControllerWithIdentifier("people_controller") as PeopleController
        changeNameView = storyboard?.instantiateViewControllerWithIdentifier("change_name_controller") as ChangeNameController
        
    }
    
    class Group {
        
        var group: PFObject!
        var admin: Bool = false
        var creator: Bool = false
        
        init(){}
        
    }
    
    func loadData(){
        
//        navigationItem.title = "Loading..."
        
        var admins_done = false
        var users_done = false
        
        var tmp_groups: [Group] = []
        
        var users_query = PFQuery(className: "Groups")
        users_query.whereKey("users", containedIn: [currentUser])
        
        var admins_query = PFQuery(className: "Groups")
        admins_query.whereKey("admins", containedIn: [currentUser])
        
        users_query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil){
                
                for object in objects {
                    
                    var group = object as PFObject
                    
                    var tmp_group = Group()
                    tmp_group.group = group
                    
                    tmp_groups.append(tmp_group)
                    
                }
                
            } else {
                
                NSLog("USERS QUERY ERROR")
                
            }
            
            users_done = true
            
            if admins_done {
                
                self.setData(tmp_groups)
                
            }
            
        }
        
        admins_query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil){
                
                for object in objects {
                    
                    var group = object as PFObject
                    
                    var tmp_group = Group()
                    tmp_group.group = group
                    tmp_group.admin = true
                    
                    var creator = group["creator"] as PFUser
                    
                    if creator.objectId == currentUser.objectId {
                        
                        tmp_group.creator = true
                        
                    }
                    
                    tmp_groups.append(tmp_group)
                    
                }
                
            } else {
                
                NSLog("ADMINS QUERY ERROR")
                
            }
            
            admins_done = true
            
            if users_done {
                
                self.setData(tmp_groups)
                
            }
            
        }
        
    }
    
    func setData(tmp_groups: Array<Group>){
        
        self.groups = tmp_groups
        
        self.groupsTBL.reloadData()
        
//        self.navigationItem.title = self.tmp_title
        
        self.refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        loadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: GroupCell = tableView.dequeueReusableCellWithIdentifier("cell") as GroupCell
        
        cell.nameTXT.text = groups[indexPath.row].group["name"] as? String
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedGroup = groups[indexPath.row].group
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        peopleView.group = selectedGroup
        peopleView.loadData()
        navigationController?.pushViewController(peopleView, animated: true)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var group: Group = groups[indexPath.row] as Group
        var group_name = group.group["name"] as String
        selectedGroup = group.group
        var currentCell: GroupCell = tableView.cellForRowAtIndexPath(indexPath) as GroupCell
        
        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (eaction:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let editMenu = UIAlertController(title: "Edit", message: nil, preferredStyle: .ActionSheet)
            
            let changeName = UIAlertAction(title: "Change Name", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                tableView.setEditing(false, animated: true)
                editMenu.dismissViewControllerAnimated(false, completion: nil)
                
                self.changeNameView.group = self.selectedGroup
                self.navigationController?.pushViewController(self.changeNameView, animated: true)
            
            })
            
            let addPeople = UIAlertAction(title: "Add People", style: UIAlertActionStyle.Default, handler: nil)
            
            let leaveGroup = UIAlertAction(title: "Leave Group", style: UIAlertActionStyle.Destructive, handler: nil)
            
            let deleteGroup = UIAlertAction(title: "Delete Group", style: UIAlertActionStyle.Destructive, handler: {(alert: UIAlertAction!) in
                
                var confirmAlert: UIAlertController!
                
                confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you wish to delete \(group_name)?", preferredStyle: UIAlertControllerStyle.Alert)
                
                confirmAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    
                    currentCell.loader.startAnimating()
                    
                    group.group.deleteInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
                        
                        if !(error != nil) {
                            
                            self.groups.removeAtIndex(indexPath.row)
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            
                        } else {
                            
                            NSLog("DELETE ERROR")
                            
                        }
                        
                        currentCell.loader.startAnimating()
                        
                    })
                    
                }))
                
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    
                    
                }))
                
                self.presentViewController(confirmAlert, animated: true, completion: nil)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            if group.admin {
                
                editMenu.addAction(changeName)
                editMenu.addAction(addPeople)
                
            }
            
            if group.creator {
                
                editMenu.addAction(deleteGroup)
                
            } else {
                
                editMenu.addAction(leaveGroup)
                
            }
            
            editMenu.addAction(cancelAction)
            
            self.presentViewController(editMenu, animated: true, completion: nil)
            
        })
        
        editAction.backgroundColor = UIColor.grayColor()
        
        return [editAction]
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "group_selected") {
            
            var svc1 = segue.destinationViewController as PeopleController
            
            svc1.group = selectedGroup
            
        }
        
        if (segue.identifier == "change_group_name") {
            
            var svc = segue.destinationViewController as ChangeNameController
            
            svc.group = selectedGroup
            
        }
        
    }

}
