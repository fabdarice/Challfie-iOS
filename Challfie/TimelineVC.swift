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
    @IBOutlet weak var myProfilImage: UIImageView!
    @IBOutlet weak var searchImage: UIImageView!
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    //var footerView:UIView!
    
    var selfies_array:[Selfie] = []
    var selfies_array_id:[Int] = []
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var first_time = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")        
        self.navigationController?.navigationBar.translucent = false        
        
        // Remove separator line from UITableView
        self.timelineTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Add Refresh when pulling down
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = MP_HEX_RGB("30768A")
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull_to_refresh", comment: "Pull down to refresh"))
        self.refreshControl.addTarget(self, action: "refreshInvoked:", forControlEvents: UIControlEvents.ValueChanged)
        self.timelineTableView.addSubview(refreshControl)
        
        // Initialize the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Set Background color for topBar
        self.topBarView.backgroundColor = MP_HEX_RGB("30768A")
        
        // set link to my profil
        var myProfiltapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        myProfiltapGesture.addTarget(self, action: "tapGestureToProfil")
        self.myProfilImage.addGestureRecognizer(myProfiltapGesture)
        self.myProfilImage.userInteractionEnabled = true
        
        
        // set link to Search User xib
        var searchPagetapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        searchPagetapGesture.addTarget(self, action: "tapGestureToSearchPage")
        self.searchImage.addGestureRecognizer(searchPagetapGesture)
        self.searchImage.userInteractionEnabled = true
        
        
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
        self.refresh(actionFromInit: true)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Hide navigationController
        self.navigationController?.navigationBar.hidden = true
        
        // Refresh the page if not the first time
        if self.first_time == false {
            refresh(actionFromInit: false)
        }
        
        self.first_time = false
    }
    
    
    func refreshInvoked(sender:AnyObject) {
        refresh(actionFromInit: false)
    }
    
    // Pull-to-refresh function - Refresh all data
    func refresh(actionFromInit: Bool = false) {
        self.refreshControl.beginRefreshing()
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
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if actionFromInit == false {
                        self.selfies_array.removeAll(keepCapacity: false)
                        self.selfies_array_id.removeAll(keepCapacity: false)
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
                            self.selfies_array_id.append(selfie.id)
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
                    
                    // Update Badge of Friends TabBarItem
                    var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as UITabBarItem
                    if json["meta"]["new_friends_request_nb"] != 0 {
                        friend_tabBarItem.badgeValue = json["meta"]["new_friends_request_nb"].stringValue
                    } else {
                        friend_tabBarItem.badgeValue = nil
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
                            
                            if contains(self.selfies_array_id, selfie.id) == false {
                                self.selfies_array.append(selfie)
                                self.selfies_array_id.append(selfie.id)
                            }
                            
                        }
                        self.page += 1
                        self.timelineTableView.reloadData()
                    }
                    
                    
                }
                self.loadingIndicator.stopAnimating()
                self.timelineTableView.tableFooterView = nil
        }
    }
    
    // Function to display a message in case of an empty return results
    func display_empty_message() {
        if (self.selfies_array.count == 0) {
            // Display a message when the table is empty
            var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
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
    
    /// Function to push to my Profil
    func tapGestureToProfil() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToProfil(self)
    }
    
    // Function to push to Search Page
    func tapGestureToSearchPage() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: "Timeline")

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