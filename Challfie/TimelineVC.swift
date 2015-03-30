//
//  TimelineVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class TimelineVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var uploadSelfieView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var uploadSelfieImage: UIImageView!
    @IBOutlet weak var uploadSelfieLabel: UILabel!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryButton: UIButton!
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    //var footerView:UIView!
    
    var selfies_array:[Selfie] = []
    var selfies_array_id:[Int] = []
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var progressTimer: NSTimer!
    var progressData:Float = 0.1
    var first_time = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")        
        self.navigationController?.navigationBar.translucent = false
        
        // navigationController Title
        let logoImageView = UIImageView(image: UIImage(named: "challfie_letter"))
        logoImageView.frame = CGRectMake(0.0, 0.0, 150.0, 35.0)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        if let navBar = self.navigationController?.navigationBar {
            self.view.bringSubviewToFront(navBar)
        }
        
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        statusBarViewBackground.tag = 22
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        // navigationController Left and Right Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
        // hide uploadSelfie View
        self.uploadSelfieView.hidden = true
        
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
        
        // Do any additional setup after loading the view, typically from a nib.
        self.timelineTableView.delegate = self
        self.timelineTableView.dataSource = self

        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "TimelineCustomCell", bundle: nil)
        timelineTableView.registerNib(nib, forCellReuseIdentifier: "TimelineCustomCell")

        // Set the height of a cell dynamically
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        timelineTableView.estimatedRowHeight = 444.0
        
        // Add right swipe gesture hide Side Menu
        var ensideNavBar = self.navigationController as MyNavigationController
        var ensideMenu :ENSideMenu = ensideNavBar.sideMenu!
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showSideMenu")
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        self.timelineTableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        let rightSwipeGestureRecognizer2 = UISwipeGestureRecognizer(target: self, action: "showSideMenu")
        rightSwipeGestureRecognizer2.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer2.delegate = self
        ensideMenu.sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer2)
        
        // Add left swipe gesture Show Side Menu
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "hideSideMenu")
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        self.timelineTableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        let leftSwipeGestureRecognizer2 = UISwipeGestureRecognizer(target: self, action: "hideSideMenu")
        leftSwipeGestureRecognizer2.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer2.delegate = self
        ensideMenu.sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer2)
        
        // Add Tap gesture to Hide Side Menu
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideSideMenu")
        self.timelineTableView.addGestureRecognizer(tapGesture)
        
        // Load Selfies for User Timeline
        self.refresh(actionFromInit: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false

        // Refresh the page if not the first time
        if self.first_time == false && self.uploadSelfieView.hidden == true {
            self.refresh(actionFromInit: false)
        }
        
        // Show Status Bar because GKImagePicker hides it (From TakePicture)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
        
        self.first_time = false
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if self.uploadSelfieView.hidden == false {
            self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
        }
    }
    
    
    func updateProgress() {
        if self.progressData < 0.9 {
            self.progressData += 0.1
            self.progressView.progress = self.progressData
        } else {
            self.progressTimer.invalidate()
        }
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
        
        
        request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
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
                    
                    var badgeNumber : Int!
                    badgeNumber = json["meta"]["new_alert_nb"].intValue + json["meta"]["new_friends_request_nb"].intValue
                    
                    UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
                    
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
        
        request(.POST, ApiLink.timeline, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
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
    
    // Function to push to Search Page
    func tapGestureToSearchPage() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: "Timeline")

    }
    
    @IBAction func closeUploadSelfieView(sender: UIButton) {
        self.uploadSelfieView.hidden = true
        self.tableViewTopConstraint.constant = 0.0
    }
    
    @IBAction func retryUploadSelfie(sender: UIButton) {
        if let viewControllers = self.tabBarController?.viewControllers {
            let navController = viewControllers[2] as UINavigationController
            var takepictureVC = navController.viewControllers[0] as TakePictureVC
            takepictureVC.createSelfie()
            self.progressData = 0.1
            self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
        }
    }
    
    
    // MARK - UITableViewDelegate Functions
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
    
    // UIGestureDelegate
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }

    func toggleSideMenu() {
        toggleSideMenuView()
    }
    
    func hideSideMenu() {
        hideSideMenuView()
    }
    
    func showSideMenu() {
        showSideMenuView()
    }
    
 
}