//
//  AlertVC.swift
//  Challfie
//
//  Created by fcheng on 12/4/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class AlertVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!    
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var alerts_array:[Alert] = []
    var alerts_array_id:[Int] = []
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
        
        // navigationController Left and Right Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
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
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
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
        self.refresh(actionFromInit: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
                
        // Refresh the page if not the first time
        if self.first_time == false {
            refresh(actionFromInit: false)
        }
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
        
        self.first_time = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        request(.POST, ApiLink.alerts_all_read, parameters: parameters, encoding: .JSON)
        
        self.tabBarItem.badgeValue = nil
        
        // Update App Badge Number
        var alert_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[4] as UITabBarItem
        var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as UITabBarItem
        
        var badgeNumber : Int!
        if friend_tabBarItem.badgeValue != nil {
            badgeNumber = friend_tabBarItem.badgeValue?.toInt()
            UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    func toggleSideMenu() {
        toggleSideMenuView()
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
                        self.alerts_array.removeAll(keepCapacity: false)
                        self.alerts_array_id.removeAll(keepCapacity: false)
                    }
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            var alert = Alert.init(json: json["notifications"][i])
                            var author: User = User.init(json: json["notifications"][i]["author"])
                            alert.author = author
                            
                            self.alerts_array.append(alert)
                            self.alerts_array_id.append(alert.id)
                            
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
                self.display_empty_message()
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
        
        request(.POST, ApiLink.alerts_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            var alert = Alert.init(json: json["notifications"][i])
                            var author: User = User.init(json: json["notifications"][i]["author"])
                            alert.author = author
                            
                            if contains(self.alerts_array_id, alert.id) == false {
                                self.alerts_array.append(alert)
                                self.alerts_array_id.append(alert.id)
                            }
                            
                        }
                        self.page += 1
                        self.tableView.reloadData()
                    }
                    
                    
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    func display_empty_message() {
        if (self.alerts_array.count == 0) {
            // Display a message when the table is empty
            var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
            messageLabel.text = NSLocalizedString("no_alert", comment: "No alerts found..")
            messageLabel.textColor = MP_HEX_RGB("000000")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Chinacat", size: 16.0)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
    }
    
    // Function to push to Search Page
    func tapGestureToSearchPage() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: NSLocalizedString("Alert_tab", comment: "Alert"))
        
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
        hideSideMenuView()
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            // Add Loading Indicator to footerView
            self.tableView.tableFooterView = self.loadingIndicator
            
            // Load Next Page of Selfies for User Timeline
            self.loadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //var cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as FriendTVCell
        //println(cell.usernameLabel.text)
        var alert: Alert = self.alerts_array[indexPath.row]
        
        
        // load book image
        if alert.book_img != "" {
            // Push to Challenge Book
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            var bookVC:BookVC = mainStoryboard.instantiateViewControllerWithIdentifier("bookID") as BookVC
           
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(bookVC, animated: true)
            
        } else if alert.selfie_img != "" {
            // Push to OneSelfieVC
            var oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
            var selfie = Selfie.init(id: alert.selfie_id)
            oneSelfieVC.selfie = selfie
            
            // Hide TabBar when push to OneSelfie View
            self.hidesBottomBarWhenPushed = true
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Alert_tab", comment: "Alert"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(oneSelfieVC, animated: true)
            
            /*
            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "id": alert.selfie_id.description
            ]
            
            request(.POST, ApiLink.show_selfie, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata == nil) {
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        //Convert to SwiftJSON
                        var json = JSON_SWIFTY(mydata!)
                        var selfie: Selfie!
                        
                        if json["selfie"].count != 0 {
                            selfie = Selfie.init(json: json["selfie"])
                            var challenge = Challenge.init(json: json["selfie"]["challenge"])
                            var user = User.init(json: json["selfie"]["user"])
                            
                            selfie.challenge = challenge
                            selfie.user = user
                        }
                        
                        // Hide TabBar when push to OneSelfie View
                        self.hidesBottomBarWhenPushed = true
                        oneSelfieVC.selfie = selfie
                    }
            }
            */
        } else {
            // Push to Profil View(UserProfil)
            var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
            profilVC.user = alert.author
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(profilVC, animated: true)
        }
        
        
    }

}