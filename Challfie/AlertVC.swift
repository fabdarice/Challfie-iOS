//
//  AlertVC.swift
//  Challfie
//
//  Created by fcheng on 12/4/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire

class AlertVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var alerts_array:[Alert] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero

        // Add Pull-to-refresh (UIKit Built-in)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = MP_HEX_RGB("30768A")
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull_to_refresh", comment: "Pull down to refresh"))
        self.refreshControl.addTarget(self, action: "refreshInvoked:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // Initialize the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, 320, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Set Background color for topBar
        self.topBarView.backgroundColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "AlertTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "AlertCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        // Load Alerts List
        //self.loadData()
        self.refreshControl.beginRefreshing()
        self.refresh(actionFromInit: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        Alamofire.request(.POST, ApiLink.alerts_all_read, parameters: parameters, encoding: .JSON)
        
        self.tabBarItem.badgeValue = nil
    }
    
    
    func refreshInvoked(sender:AnyObject) {
        refresh(actionFromInit: false)
    }
    
    // Pull-to-refresh function - Refresh all data
    func refresh(actionFromInit: Bool = false) {
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Refreshing_data", comment: "Refreshing data.."))
        var parameters = [String: String]()
        var api_link: String!
        
        if actionFromInit == true {
            parameters = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "page": self.page.description
            ]
            api_link = ApiLink.alerts_list
        } else {
            if self.alerts_array.count == 0 {
                parameters = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                    "last_alert_id": "-1"
                ]
            } else {
                let last_alert: Alert! = self.alerts_array.last
                parameters = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                    "last_alert_id": last_alert.id.description
                ]
            }
            api_link = ApiLink.alert_refresh
        }
        
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println(mydata)
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if actionFromInit == false {
                        self.alerts_array.removeAll(keepCapacity: false)
                    }
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            var alert = Alert.init(json: json["notifications"][i])
                            var author: User = User.init(json: json["notifications"][i]["author"])
                            alert.author = author
                            
                            self.alerts_array.append(alert)
                            
                        }
                        if actionFromInit == true {
                            self.page += 1
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                    // Update Badge of Alert TabBarItem
                    if json["meta"]["new_alert_nb"] != 0 {
                        self.tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                    } else {
                        self.tabBarItem.badgeValue = nil
                    }
                    
                }
                self.refreshControl.endRefreshing()
                self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull_to_refresh", comment: "Pull down to refresh"))
        }
        
        
    }
    
    // Retrive list of selfies to a user timeline
    func loadData() {        
        self.loadingIndicator.startAnimating()
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "page": self.page.description
        ]
        
        Alamofire.request(.POST, ApiLink.alerts_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println(mydata)
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            var alert = Alert.init(json: json["notifications"][i])
                            var author: User = User.init(json: json["notifications"][i]["author"])
                            alert.author = author
                            self.alerts_array.append(alert)
                        }
                        self.page += 1
                        self.tableView.reloadData()
                    }
                    
                    
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    // tableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var cell: AlertTVCell = tableView.dequeueReusableCellWithIdentifier("AlertCell") as AlertTVCell
        
        var alert: Alert = self.alerts_array[indexPath.row]
        cell.loadItem(alert)
        
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
        return self.alerts_array.count
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            // Add Loading Indicator to footerView
            self.tableView.tableFooterView = self.loadingIndicator
            
            // Load Next Page of Selfies for User Timeline
            self.loadData()
        }
        
    }
}