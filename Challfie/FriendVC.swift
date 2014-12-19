//
//  FriendVC.swift
//  Challfie
//
//  Created by fcheng on 12/16/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire

class FriendVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    
    var friends_array: [Friend] = []
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background color for topBar (kinda NavigationBar)
        self.topBarView.backgroundColor = MP_HEX_RGB("30768A")
        
        // Set Title for friends Tab
        self.followingButton.setTitle(NSLocalizedString("Following", comment: "Following"), forState: UIControlState.Normal)
        self.followersButton.setTitle(NSLocalizedString("Followers", comment: "Followers"), forState: UIControlState.Normal)
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Initialize the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, 320, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "FriendTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        // Load Friends List
        self.loadData()

    }
    
    //func refreshInvoked(sender:AnyObject) {
     //   refresh(actionFromInit: false)
    //}
    
    func loadData() {
        self.loadingIndicator.startAnimating()
        
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "page": self.page.description
        ]
        
        Alamofire.request(.POST, ApiLink.friends_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println(mydata)
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            var friend = Friend.init(json: json["users"][i])
                            
                            self.friends_array.append(friend)                            
                        }
                        self.page += 1
                        self.tableView.reloadData()
                    }
                    
                    // Update Badge of Alert TabBarItem
                    if json["meta"]["new_alert_nb"] != 0 {
                        self.tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                    } else {
                        self.tabBarItem.badgeValue = nil
                    }
                    
                }
                self.loadingIndicator.stopAnimating()
                self.tableView.tableFooterView = nil
        }
    }
    
    
    @IBAction func suggestionsTab(sender: UIButton) {
    }
    
    @IBAction func followingTab(sender: UIButton) {
    }
    
    @IBAction func followersTab(sender: UIButton) {
    }
    
    
    // tableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendTVCell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as FriendTVCell
        var friend: Friend = self.friends_array[indexPath.row]
        cell.loadItem(friend)
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends_array.count
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            // Add Loading Indicator to footerView
            //self.tableView.tableFooterView = self.loadingIndicator
            
            // Load Next Page of Selfies for User Timeline
           // self.loadData()
        }
        
    }
}