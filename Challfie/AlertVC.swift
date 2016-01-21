//
//  AlertVC.swift
//  Challfie
//
//  Created by fcheng on 12/4/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class AlertVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ENSideMenuDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var page = 1
    var refreshControl:UIRefreshControl!  // An optional variable
    var alerts_array:[Alert] = []
    var alerts_array_id:[Int] = []
    var first_time = true
    
    var popViewController : PopUpViewControllerSwift = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
    
    var loadMoreData: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        
        // Add Delegate to SideMenu
        self.sideMenuController()?.sideMenu?.delegate = self

        // navigationController Title
        let logoImageView = UIImageView(image: UIImage(named: "challfie_letter"))
        logoImageView.frame = CGRectMake(0.0, 0.0, 150.0, 35.0)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        // navigationController Left and Right Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
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
        let nib = UINib(nibName: "AlertTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "AlertCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 65.0
        
        self.sideMenuController()?.sideMenu?.behindViewController = self
        
        // Load Alerts List
        self.refresh(true)
    }
    
    override func viewWillAppear(animated: Bool) {        
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Alert's Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Refresh the page if not the first time and a badge exists
        if self.first_time == false && self.tabBarItem.badgeValue != nil {
            refresh(false)
        }
        
        self.tabBarItem.badgeValue = nil
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
        
        self.first_time = false
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let keychain = Keychain(service: "challfie.app.service")
        if keychain["login"] != nil {
            
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            var last_notification_id : String!
            
            if self.alerts_array_id.count == 0 {
                last_notification_id = "0"
            } else {
                last_notification_id = self.alerts_array_id.first?.description
            }
            
            let parameters = [
                "login": login,
                "auth_token": auth_token,
                "last_notification_id": last_notification_id
            ]
            Alamofire.request(.POST, ApiLink.alerts_all_read, parameters: parameters, encoding: .JSON)
            
            self.tabBarItem.badgeValue = nil
            
            if let tabBarItems = self.tabBarController?.tabBar.items {
                // Update App Badge Number
                let friend_tabBarItem : UITabBarItem = tabBarItems[3]
                
                var badgeNumber : Int!
                if friend_tabBarItem.badgeValue != nil {
                    badgeNumber = Int(friend_tabBarItem.badgeValue!)
                    UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
                } else {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
            }
            
        }        
        
    }
    
    // MARK: - Refresh and Initial Loading New Data
    func refreshInvoked(sender:AnyObject) {
        refresh(false)
    }
    
    //  when true : Initial Loading of Data
    //  when false : Refresh all data (not used anymore)
    func refresh(actionFromInit: Bool = false) {
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
            api_link = ApiLink.alerts_list
        } else {
            if self.alerts_array.count == 0 {
                
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_alert_id": "-1"
                ]
            } else {
                let last_alert: Alert! = self.alerts_array.last
                parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "last_alert_id": last_alert.id.description
                ]
            }
            api_link = ApiLink.alert_refresh
        }
        
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    print(json)

                    if actionFromInit == false {
                        self.alerts_array.removeAll(keepCapacity: false)
                        self.alerts_array_id.removeAll(keepCapacity: false)
                    }
                    
                    var isDisplayingPopUp: Bool = false
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            let alert = Alert.init(json: json["notifications"][i])
                            
                            // Display Pop up if alert of unlocking new Level
                            if alert.type_notification == AlertType.LevelUnlock.rawValue && alert.read == false && isDisplayingPopUp == false {
                                var popUpImage: UIImage!

                                switch alert.author.book_level {
                                case "Newbie II" : popUpImage = UIImage(named: "level_up_newbie_2")
                                case "Newbie III" : popUpImage = UIImage(named: "level_up_newbie_3")
                                case "Apprentice I" : popUpImage = UIImage(named: "level_up_apprentice_1")
                                case "Apprentice II" : popUpImage = UIImage(named: "level_up_apprentice_2")
                                case "Apprentice III" : popUpImage = UIImage(named: "level_up_apprentice_3")
                                case "Master I" : popUpImage = UIImage(named: "level_up_master_1")
                                case "Master II" : popUpImage = UIImage(named: "level_up_master_2")
                                case "Master III" : popUpImage = UIImage(named: "level_up_master_3")
                                default : popUpImage = nil
                                }

                                if popUpImage != nil {
                                    isDisplayingPopUp = true
                                    self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
                                    self.popViewController.showInView(self.navigationController?.view, withImage: popUpImage, withMessage: "", animated: true)
                                }
                                
                            }
                            
                            self.alerts_array.append(alert)
                            self.alerts_array_id.append(alert.id)
                            
                        }
                        if actionFromInit == true {
                            self.page += 1
                            self.loadMoreData = true
                        }
                        self.tableView.reloadData()
                    }
                    
                }
                self.refreshControl.endRefreshing()
                self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull_to_refresh", comment: "Pull down to refresh"))
                self.display_empty_message()
                
                if actionFromInit == true {
                    // Register for Push Notitications, if running iOS 8
                    let app = UIApplication.sharedApplication()
                    let notificationType: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
                    let settings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
                    app.registerUserNotificationSettings(settings)
                }
        }
    }
    
    // Pagination : Load next Alerts
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
        
        Alamofire.request(.POST, ApiLink.alerts_list, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    
                    if json["notifications"].count != 0 {
                        for var i:Int = 0; i < json["notifications"].count; i++ {
                            let alert = Alert.init(json: json["notifications"][i])                            
                            
                            if self.alerts_array_id.contains(alert.id) == false {
                                self.alerts_array.append(alert)
                                self.alerts_array_id.append(alert.id)
                            }
                            
                        }
                        self.page += 1
                        self.loadMoreData = true
                        self.tableView.reloadData()
                    } else {
                        self.loadMoreData = false
                    }
                    
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    func display_empty_message() {
        if (self.alerts_array.count == 0) {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
            messageLabel.text = NSLocalizedString("no_alert", comment: "No alerts found..")
            messageLabel.textColor = MP_HEX_RGB("000000")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
    }
    
    // MARK:- Function to push to Search Page
    func tapGestureToSearchPage() {
        let globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: NSLocalizedString("Alert_tab", comment: "Alert"))
        
    }
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        let cell: AlertTVCell = tableView.dequeueReusableCellWithIdentifier("AlertCell") as! AlertTVCell
        
        let alert: Alert = self.alerts_array[indexPath.row]
        cell.loadItem(alert)
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.sizeToFit()
        
        if self.loadingIndicator.isAnimating() == false {
            if (indexPath.row == self.alerts_array.count - 1) && (self.loadMoreData == true) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                
                // Load Next Page of Selfies for User Timeline
                self.loadData()
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts_array.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //var cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as FriendTVCell
        let alert: Alert = self.alerts_array[indexPath.row]
        
        // load book image
        if alert.book_img != "" {
            // Modal to Challenge Book
            self.tabBarController?.selectedIndex = 1
        } else if alert.type_notification == AlertType.Matchup.rawValue && alert.matchup != nil {
            if alert.matchup.status == MatchupStatus.Pending.rawValue {
                // Push To MatchupVC
                let matchupsVC = MatchupsVC(nibName: "Matchups" , bundle: nil)
                matchupsVC.hidesBottomBarWhenPushed = true
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                self.navigationController?.pushViewController(matchupsVC, animated: true)
            } else {
                // Push to OneMatchupVC of the selected Row
                let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
                oneMatchUpVC.matchup = alert.matchup
                oneMatchUpVC.hidesBottomBarWhenPushed = true
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                self.navigationController?.pushViewController(oneMatchUpVC, animated: true)
            }
        } else if alert.selfie_img != "" {
            // Push to OneSelfieVC
            let oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
            let selfie = Selfie.init(id: alert.selfie_id)
            oneSelfieVC.selfie = selfie
            
            // Hide TabBar when push to OneSelfie View
            self.hidesBottomBarWhenPushed = true
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Alert_tab", comment: "Alert"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(oneSelfieVC, animated: true)
            
        } else {
            // Push to Profil View(UserProfil)
            let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
            profilVC.user = alert.author
            profilVC.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(profilVC, animated: true)
        }
    }
    
    // MARK: - ENSideMenu Delegate
    func toggleSideMenu() {
       toggleSideMenuView()
    }
 
    
    // MARK: - UIGestureDelegate
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    

}