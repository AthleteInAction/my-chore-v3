//
//  GroupsController.swift
//  my-chore-v3
//
//  Created by Will Robinson on 11/26/14.
//  Copyright (c) 2014 Will Robinson. All rights reserved.
//

import UIKit

class GroupsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var refreshControl: UIRefreshControl!
    
    var groups: [PFObject] = []
    var selectedGroup: PFObject!
    
    @IBOutlet weak var groupsTBL: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupsTBL.delegate = self
        groupsTBL.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        groupsTBL.addSubview(refreshControl)
        
    }
    
    func loadData(){
        
        var tmp_groups: [PFObject] = []
        
        var query1 = PFQuery(className: "Groups")
        query1.whereKey("users", containedIn: [currentUser])
        
        var query2 = PFQuery(className: "Groups")
        query2.whereKey("admins", containedIn: [currentUser])
        
        var query = PFQuery.orQueryWithSubqueries([query1,query2])
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if !(error != nil){
                
                for object in objects {
                    
                    var group = object as PFObject
                    tmp_groups.append(group)
                    
                }
                
            } else {
                
                NSLog("QUERY ERROR")
                
            }
            
            self.groups = tmp_groups
            
            self.groupsTBL.reloadData()
            self.refreshControl.endRefreshing()
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        groupsTBL.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.textLabel.text = groups[indexPath.row]["name"] as? String
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedGroup = groups[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("group_selected", sender: self)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let editMenu = UIAlertController(title: nil, message: "Edit", preferredStyle: .ActionSheet)
            
            let changeName = UIAlertAction(title: "Change Name", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            editMenu.addAction(changeName)
            editMenu.addAction(cancelAction)
            
            self.presentViewController(editMenu, animated: true, completion: nil)
            
        })
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPathB:NSIndexPath!) -> Void in
            
            var group_name: String = self.groups[indexPath.row]["name"] as String
            
            var confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this group: \(group_name)", preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                
                self.groups.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                
                
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
            
        })
        
        editAction.backgroundColor = UIColor.grayColor()
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction,editAction]
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "group_selected") {
            
            var svc = segue.destinationViewController as PeopleController
            
            svc.group = selectedGroup
            
        }
        
    }

}
