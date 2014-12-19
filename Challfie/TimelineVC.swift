//
//  TimelineVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire

class TimelineVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var topBarView: UIView!
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var footerView:UIView!
    
    var selfies_array:[Selfie] = []
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")        
        
        
        // Remove separator line from UITableView
        self.timelineTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Add Refresh when pulling down
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = MP_HEX_RGB("30768A")
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull_to_refresh", comment: "Pull down to refresh"))
        self.refreshControl.addTarget(self, action: "refreshInvoked:", forControlEvents: UIControlEvents.ValueChanged)
        self.timelineTableView.addSubview(refreshControl)
        
        // Initialize the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, 320, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Set Background color for topBar
        self.topBarView.backgroundColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.timelineTableView.delegate = self
        self.timelineTableView.dataSource = self

        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "TimelineCustomCell", bundle: nil)
        timelineTableView.registerNib(nib, forCellReuseIdentifier: "TimelineCustomCell")

        // Set the height of a cell dynamically
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        timelineTableView.estimatedRowHeight = 444.0
        
        // Load Selfies for User Timeline
        //self.loadData()
        self.refreshControl.beginRefreshing()
        self.refresh(actionFromInit: true)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
      //  if segue.identifier == "showOneSelfie" {
        //    println("ENTER PREPAREFORSEGUE")
            
          //  let oneSelfieVC = segue.destinationViewController as OneSelfieVC
//            let cell = sender as TimelineTableViewCell
  //          println(cell.selfie.message)
    //        oneSelfieVC.selfie = cell.selfie
      //  }
//    }
    
    
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
            api_link = ApiLink.timeline
        } else {
            if selfies_array.count == 0 {
                parameters = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                    "last_selfie_id": "-1"
                ]
            } else {
                let last_selfie: Selfie! = self.selfies_array.last
                parameters = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                    "last_selfie_id": last_selfie.id.description
                ]
            }
            api_link = ApiLink.selfies_refresh
        }
        
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                //println(mydata)
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if actionFromInit == false {
                        self.selfies_array.removeAll(keepCapacity: false)
                    }
                    
                    if json["selfies"].count != 0 {
                        for var i:Int = 0; i < json["selfies"].count; i++ {
                            var selfie = Selfie.init(json: json["selfies"][i])
                            var challenge = Challenge.init(json: json["selfies"][i]["challenge"])
                            var user = User.init(json: json["selfies"][i]["user"])
                            var last_comment = Comment.init(json: json["selfies"][i]["last_comment"])
                            
                            selfie.challenge = challenge
                            selfie.user = user
                            selfie.last_comment = last_comment
                            self.selfies_array.append(selfie)
                            
                        }
                        if actionFromInit == true {
                            self.page += 1
                        }
                        
                        self.timelineTableView.reloadData()
                    }
                    
                    // Update Badge of Alert TabBarItem
                    var alert_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[4] as UITabBarItem
                    if json["meta"]["new_alert_nb"] != 0 {
                        
                        alert_tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                    } else {
                        alert_tabBarItem.badgeValue = nil
                    }
                    
                    if actionFromInit == true {
                        self.display_empty_message()
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
        
        Alamofire.request(.POST, ApiLink.timeline, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["selfies"].count != 0 {
                        for var i:Int = 0; i < json["selfies"].count; i++ {
                            var selfie = Selfie.init(json: json["selfies"][i])
                            var challenge = Challenge.init(json: json["selfies"][i]["challenge"])
                            var user = User.init(json: json["selfies"][i]["user"])
                            var last_comment = Comment.init(json: json["selfies"][i]["last_comment"])
                            
                            selfie.challenge = challenge
                            selfie.user = user
                            selfie.last_comment = last_comment
                            self.selfies_array.append(selfie)
                            
                        }
                        self.page += 1
                        self.timelineTableView.reloadData()
                    }
                    
                    
                }
                self.loadingIndicator.stopAnimating()
                self.timelineTableView.tableFooterView = nil
        }
    }
    
    func display_empty_message() {
        if (self.selfies_array.count == 0) {
            // Display a message when the table is empty
            var messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = NSLocalizedString("no_selfie", comment: "Welcome to Challfie!Get started by adding your friends and take your first Selfie Challenge.")
            messageLabel.textColor = MP_HEX_RGB("000000")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Chinacat", size: 16.0)
            messageLabel.sizeToFit()
            
            self.timelineTableView.backgroundView = messageLabel
            
        } else {
            self.timelineTableView.backgroundView = nil            
        }
    }

    
    // UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selfies_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineTableViewCell = tableView.dequeueReusableCellWithIdentifier("TimelineCustomCell") as TimelineTableViewCell

        var selfie:Selfie = self.selfies_array[indexPath.row]
        cell.loadItem(selfie: selfie)
        cell.timelineVC = self

        // Update Cell Constraints        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        if (self.timelineTableView.contentOffset.y >= (self.timelineTableView.contentSize.height - self.timelineTableView.bounds.size.height)) {
            // Add Loading Indicator to footerView
            self.timelineTableView.tableFooterView = self.loadingIndicator
            
            // Load Next Page of Selfies for User Timeline
            self.loadData()
        }
    }
 

}