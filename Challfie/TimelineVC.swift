//
//  TimelineVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class TimelineVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var uploadSelfieView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var uploadSelfieImage: UIImageView!
    @IBOutlet weak var uploadSelfieLabel: UILabel!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var newDataButton: UIButton!
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var selfies_array:[Selfie] = []
    // this is the cell height cache; obviously you don't want a static size array in production
    var itemHeights:[CGFloat] = []
    
    var updated_selfie_array: [Selfie] = []
    var updated_itemHeights: [CGFloat] = []
    
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var progressTimer: NSTimer!
    var progressData:Float = 0.1
    
    // Var to check if it's first time loading the view
    var first_time: Bool = true
    
    // Var to check if it's first time loading the cells
    var first_time_loading_cell: Bool = true
    
    // Var to set if Background refresh has new Data to display the newData Button
    var hasNewData: Bool = false
    
    // Last Content OFfset of ScrollView - To Detect if Scroll up or Down
    var lastContentOffset: CGFloat = 0
    
    // For TakePictureVC : disableBackgroundRefresh after creating a selfie to void double refresh
    var disableBackgroundRefresh: Bool = false
    
    // Var to set if there's more data to load (from pagination)
    var loadMoreData : Bool = false
    
    
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
        let nib = UINib(nibName: "TimelineCustomCell", bundle: nil)
        timelineTableView.registerNib(nib, forCellReuseIdentifier: "TimelineCustomCell")

        // Set the height of a cell dynamically
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        //timelineTableView.estimatedRowHeight = 600
        
        self.sideMenuController()?.sideMenu?.behindViewController = self
        
        // Hide New Data Button Action
        self.newDataButton.hidden = true
        
        // Load Selfies for User Timeline
        self.refresh(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Timeline Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Show Status Bar because GKImagePicker hides it (From TakePicture)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    
        // Hide on swipe & keboard Appears
        self.navigationController?.setNavigationBarHidden(false, animated: true) // Default Show
        self.navigationController?.hidesBarsOnSwipe = true

        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.uploadSelfieView.hidden == false {
            self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
        }
        
        if self.disableBackgroundRefresh == false {
            self.backgroundRefresh()
        } else {
            // Coming From TakePictureVC & Re-enable it
            self.disableBackgroundRefresh = false
        }
    }
    
    // MARK: - Update Progress Timer
    func updateProgress() {
        if self.progressData < 0.9 {
            self.progressData += 0.1
            self.progressView.progress = self.progressData
        } else {
            self.progressTimer.invalidate()
        }
        
    }
    
    // MARK: First Time Refresh
    func refreshInvoked(sender:AnyObject) {
        self.refresh(false)
    }
    
    
    // MARK: - New Data (Selfies) Button
    @IBAction func newDataAction(sender: AnyObject) {
        self.hasNewData = false
        self.newDataButton.hidden = true
        
        self.selfies_array = self.updated_selfie_array
        self.itemHeights = self.updated_itemHeights
        
        self.updated_selfie_array.removeAll(keepCapacity: false)
        self.updated_itemHeights.removeAll(keepCapacity: false)
        
        self.navigationController?.navigationBarHidden = false
        self.timelineTableView.reloadData()

        if (self.timelineTableView.numberOfSections > 0) && (self.timelineTableView.numberOfRowsInSection(0) > 0) {
            self.timelineTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
    }    
    
    // MARK: - Pull-to-refresh function - Refresh all data
    func refresh(actionFromInit: Bool = false)  {
        
        self.hasNewData = false
        self.newDataButton.hidden = true
        self.refreshControl.beginRefreshing()
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Refreshing_data", comment: "Refreshing data.."))
        var parameters = [String: String]()
        var api_link: String!        

        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        if actionFromInit == true {
            parameters = [
                "login": login,
                "auth_token": auth_token,
                "page": self.page.description
            ]
            api_link = ApiLink.timeline
        } else {
            if selfies_array.count == 0 {
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_selfie_id": "-1"
                ]
            } else {
                let last_selfie: Selfie! = self.selfies_array.last
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_selfie_id": last_selfie.id.description
                ]
            }
            api_link = ApiLink.selfies_refresh
        }
        
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)

                    if actionFromInit == false {
                        self.selfies_array.removeAll(keepCapacity: false)
                        //self.selfies_array_id.removeAll(keepCapacity: false)
                        self.itemHeights.removeAll(keepCapacity: false)
                    }
                    
                    if json["selfies"].count != 0 {
                        for var i:Int = 0; i < json["selfies"].count; i++ {
                            let selfie = Selfie.init(json: json["selfies"][i])
                            let challenge = Challenge.init(json: json["selfies"][i]["challenge"])
                            let user = User.init(json: json["selfies"][i]["user"])
                            let last_comment = Comment.init(json: json["selfies"][i]["last_comment"])
                            
                            selfie.challenge = challenge
                            selfie.user = user
                            selfie.last_comment = last_comment
                            
                            self.selfies_array.append(selfie)
                            self.itemHeights.append(UITableViewAutomaticDimension)

                            
                        }
                        if actionFromInit == true {
                            self.page += 1
                            self.loadMoreData = true
                        }
                        
                        self.timelineTableView.reloadData()
                    }
                    
                    if let tabBarItems = self.tabBarController?.tabBar.items {
                        // Update Badge of Alert TabBarItem
                        let alert_tabBarItem : UITabBarItem = tabBarItems[4]
                        if json["meta"]["new_alert_nb"] != 0 {
                            alert_tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                        } else {
                            alert_tabBarItem.badgeValue = nil
                        }
                        
                        // Update Badge of Friends TabBarItem
                        let friend_tabBarItem : UITabBarItem = tabBarItems[3]
                        if json["meta"]["new_friends_request_nb"] != 0 {
                            friend_tabBarItem.badgeValue = json["meta"]["new_friends_request_nb"].stringValue
                        } else {
                            friend_tabBarItem.badgeValue = nil
                        }
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
                self.first_time = false
        }
    }

    
    // MARK: - Retrive list of selfies to a user timeline when scrolling down
    func loadData() {
        
        self.loadingIndicator.startAnimating()
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!

        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "page": self.page.description
        ]
        
        Alamofire.request(.POST, ApiLink.timeline, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    if json["selfies"].count != 0 {
                        for var i:Int = 0; i < json["selfies"].count; i++ {
                            let selfie = Selfie.init(json: json["selfies"][i])
                            let challenge = Challenge.init(json: json["selfies"][i]["challenge"])
                            let user = User.init(json: json["selfies"][i]["user"])
                            let last_comment = Comment.init(json: json["selfies"][i]["last_comment"])
                            
                            selfie.challenge = challenge
                            selfie.user = user
                            selfie.last_comment = last_comment
                            
                            // Avoid Same Data
                            if (self.selfies_array.contains(selfie)) == false {
                                self.selfies_array.append(selfie)

                                self.itemHeights.append(UITableViewAutomaticDimension)
                            }
                        }
                        self.page += 1
                        self.loadMoreData = true
                        self.timelineTableView.reloadData()
                    } else {
                        self.loadMoreData = false
                    }
                }
                self.loadingIndicator.stopAnimating()
                self.timelineTableView.tableFooterView = nil
        }
    }
    
    // MARK: - Background Refresh (while app is still active)
    func backgroundRefresh() {
        if self.first_time == false {
            var parameters = [String: String]()
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            if self.selfies_array.count == 0 {
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_selfie_id": "-1"]
            } else {
                let last_selfie: Selfie! = self.selfies_array.last
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_selfie_id": last_selfie.id.description]
            }
            
            self.updated_selfie_array.removeAll(keepCapacity: false)
            self.updated_itemHeights.removeAll(keepCapacity: false)
            
            Alamofire.request(.POST, ApiLink.selfies_refresh, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    case .Success(let mydata):
                        //Convert to SwiftJSON
                        var json = JSON(mydata)
                        
                        if let tabBarItems = self.tabBarController?.tabBar.items {
                            // Update Badge of Alert TabBarItem
                            let alert_tabBarItem : UITabBarItem = tabBarItems[4]
                            if json["meta"]["new_alert_nb"] != 0 {
                                alert_tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                            } else {
                                alert_tabBarItem.badgeValue = nil
                            }
                            
                            // Update Badge of Friends TabBarItem
                            let friend_tabBarItem : UITabBarItem = tabBarItems[3]
                            if json["meta"]["new_friends_request_nb"] != 0 {
                                friend_tabBarItem.badgeValue = json["meta"]["new_friends_request_nb"].stringValue
                            } else {
                                friend_tabBarItem.badgeValue = nil
                            }

                        }
                        
                        var badgeNumber : Int!
                        badgeNumber = json["meta"]["new_alert_nb"].intValue + json["meta"]["new_friends_request_nb"].intValue
                        
                        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
        
                        if json["selfies"].count != 0 {
                            for var i:Int = 0; i < json["selfies"].count; i++ {
                                
                                let selfie = Selfie.init(json: json["selfies"][i])
                                let challenge = Challenge.init(json: json["selfies"][i]["challenge"])
                                let user = User.init(json: json["selfies"][i]["user"])
                                let last_comment = Comment.init(json: json["selfies"][i]["last_comment"])
                                
                                selfie.challenge = challenge
                                selfie.user = user
                                selfie.last_comment = last_comment
                                
                                self.updated_selfie_array.append(selfie)
                                self.updated_itemHeights.append(UITableViewAutomaticDimension)
                            }
                            
                            // If Timeline is empty, refresh no matter what
                            if self.selfies_array.count == 0 {
                                self.newDataAction(self)
                            } else {
                                if let newSelfieDateCreation = self.updated_selfie_array.first?.created_at,
                                    oldSelfieDateCreation = self.selfies_array.first?.created_at {
                                        let newSelfieDateMaker = NSDateFormatter()
                                        newSelfieDateMaker.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let newSelfieDate = newSelfieDateMaker.dateFromString(newSelfieDateCreation)
                                        
                                        let oldSelfieDateMaker = NSDateFormatter()
                                        oldSelfieDateMaker.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let oldSelfieDate = oldSelfieDateMaker.dateFromString(oldSelfieDateCreation)
                                        
                                        if newSelfieDate!.compare(oldSelfieDate!) == NSComparisonResult.OrderedDescending {
                                            self.hasNewData = true
                                            self.newDataButton.hidden = false
                                        } else {
                                            self.hasNewData = false
                                            self.newDataButton.hidden = true
                                        }
                                } else {
                                    self.hasNewData = false
                                    self.newDataButton.hidden = true
                                }
                                
                                // Update Selfies' last comment, number approvals, number rejections, status, number comments
                                self.updateSelfiesFromBackgroundRefresh()
                            }
                        } else {
                            self.hasNewData = false
                        }
                    }
            }
        }
    }
    
    // MARK: - Methode to update Selfies' last comment, number approvals, number rejections, status, number comments
    func updateSelfiesFromBackgroundRefresh() {
        var startIndex: Int = 0
        for var i = 0; i < self.selfies_array.count - 1; i++ {
            for var j = startIndex; j < self.updated_selfie_array.count - 1; j++ {
                if self.selfies_array[i].id == self.updated_selfie_array[j].id {
                    self.selfies_array[i] = self.updated_selfie_array[j]
                    startIndex = j + 1
                }
            }
        }
    }
    
    
    // MARK: - Fetch Data in Background Mode (App not Active anymore)
    /*
    func fetchDataInBackground(completionHandler: (UIBackgroundFetchResult -> Void)) {
        var parameters = [String: String]()
        if self.selfies_array.count == 0 {
            parameters = [
                "login": KeychainInfo.login,
                "auth_token": KeychainInfo.auth_token,
                "last_selfie_id": "-1"
            ]
        } else {
            let last_selfie: Selfie! = self.selfies_array.last
            parameters = [
                "login": KeychainInfo.login,
                "auth_token": KeychainInfo.auth_token,
                "last_selfie_id": last_selfie.id.description
            ]
        }
            
        request(.POST, ApiLink.selfies_refresh, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    completionHandler(UIBackgroundFetchResult.Failed)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    self.selfies_array.removeAll(keepCapacity: false)
                    //self.selfies_array_id.removeAll(keepCapacity: false)
                    self.itemHeights.removeAll(keepCapacity: false)
                    
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
                            //self.selfies_array_id.append(selfie.id)
                            self.itemHeights.append(UITableViewAutomaticDimension)
                        }
                        self.timelineTableView.reloadData()
                        completionHandler(UIBackgroundFetchResult.NewData)
                        
                    } else {
                        completionHandler(UIBackgroundFetchResult.NoData)
                    }
                    
                    // Update Badge of Alert TabBarItem
                    var alert_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[4] as! UITabBarItem
                    if json["meta"]["new_alert_nb"] != 0 {
                        alert_tabBarItem.badgeValue = json["meta"]["new_alert_nb"].stringValue
                    } else {
                        alert_tabBarItem.badgeValue = nil
                    }
                    
                    // Update Badge of Friends TabBarItem
                    var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as! UITabBarItem
                    if json["meta"]["new_friends_request_nb"] != 0 {
                        friend_tabBarItem.badgeValue = json["meta"]["new_friends_request_nb"].stringValue
                    } else {
                        friend_tabBarItem.badgeValue = nil
                    }
                    
                    var badgeNumber : Int!
                    badgeNumber = json["meta"]["new_alert_nb"].intValue + json["meta"]["new_friends_request_nb"].intValue
                    
                    UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
                }
            }
    }*/

    
    // MARK: - Function to display a message in case of an empty return results
    func display_empty_message() {
        if (self.selfies_array.count == 0) {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
            messageLabel.text = NSLocalizedString("no_selfie", comment: "Welcome to Challfie! Get started by adding your friends and take your first Selfie Challenge.")
            messageLabel.textColor = MP_HEX_RGB("000000")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
            messageLabel.sizeToFit()
            
            self.timelineTableView.backgroundView = messageLabel
            
        } else {
            self.timelineTableView.backgroundView = nil            
        }
    }
    
    // MARK: - Function to push to Search Page
    func tapGestureToSearchPage() {
        let globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: NSLocalizedString("tab_timeline", comment: "Timeline"))

    }
    
    // MARK: - Uploading View with Close and Retry Action
    @IBAction func closeUploadSelfieView(sender: UIButton) {
        self.uploadSelfieView.hidden = true
        self.tableViewTopConstraint.constant = 0.0
    }
    
    @IBAction func retryUploadSelfie(sender: UIButton) {
        if let viewControllers = self.tabBarController?.viewControllers,
        navController = viewControllers[2] as? UINavigationController,
        takepictureVC = navController.viewControllers[0] as? TakePictureVC {
            takepictureVC.createSelfie()
            self.progressData = 0.1
            self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
        }
    }
    
    
    // MARK: - UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selfies_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TimelineTableViewCell = tableView.dequeueReusableCellWithIdentifier("TimelineCustomCell") as! TimelineTableViewCell
        
        if indexPath.row >= self.selfies_array.count {
            tableView.reloadData()
            return cell
        } else {
            let selfie:Selfie = self.selfies_array[indexPath.row]
            cell.timelineVC = self
            cell.indexPath = indexPath
            
            cell.loadItem(selfie: selfie)
            
            if self.loadingIndicator.isAnimating() == false {
                if (indexPath.row == self.selfies_array.count - 5) && (self.loadMoreData == true) {
                    if self.first_time_loading_cell == true {
                        self.first_time_loading_cell = false
                    } else {
                        // Add Loading Indicator to footerView
                        self.timelineTableView.tableFooterView = self.loadingIndicator
                        
                        // Load Next Page of Selfies for User Timeline
                        self.loadData()
                    }
                }
            }
            
            return cell
        }
        
    }
  
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.itemHeights.count {
            if itemHeights[indexPath.row] == UITableViewAutomaticDimension {
                itemHeights[indexPath.row] = cell.bounds.height
            }
        }
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return itemHeights[indexPath.row]
    }
    
    // MARK: - UIScrollView Delegate Functions
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y + 10) {
            // move up
            if self.hasNewData == true {
                self.newDataButton.hidden = false
            }
        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            if self.newDataButton.hidden == false {
                self.newDataButton.hidden = true
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    // MARK: - UIGestureDelegate Functions
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }

    
    // MARK: - ENSideMenu Delegate
    func toggleSideMenu() {
        toggleSideMenuView()
    }
}