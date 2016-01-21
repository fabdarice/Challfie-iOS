//
//  FriendVC.swift
//  Challfie
//
//  Created by fcheng on 12/16/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainAccess

class FriendVC : UIViewController, UITableViewDelegate, UITableViewDataSource, ENSideMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var suggestionsButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var linkFacebookButton: UIButton!
    @IBOutlet weak var friendsTab_FriendsTV_constraints: NSLayoutConstraint!

    var suggestions_array: [Friend] = []
    var following_array: [Friend] = []
    var followers_array: [Friend] = []
    var request_array: [Friend] = []
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var suggestions_page = 1
    var following_page = 1
    var followers_page = 1
    var friends_tab = 1
    
    var suggestions_first_time: Bool = true
    var following_first_time: Bool = true
    var followers_first_time: Bool = true
    
    var loadMoreSuggestionsData : Bool = false
    var loadMoreFollowingData : Bool = false
    var loadMoreFollowersData : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
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
        
        // Set Background of "Search for Facebook" Button
        self.linkFacebookButton.backgroundColor = MP_HEX_RGB("3f5c9a")
        self.linkFacebookButton.hidden = true
        self.friendsTab_FriendsTV_constraints.constant = 0.0
        self.linkFacebookButton.setTitle(NSLocalizedString("Search_facebook_friends", comment: "Search for your Facebook's Friends"), forState: UIControlState.Normal)
        
        // Set Title for friends Tab
        self.followingButton.setTitle(NSLocalizedString("Following", comment: "Following"), forState: UIControlState.Normal)
        self.followersButton.setTitle(NSLocalizedString("Followers", comment: "Followers"), forState: UIControlState.Normal)
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Add Bottom the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "FriendTVCell", bundle: nil)
        let nib_request = UINib(nibName: "FriendRequestTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        self.tableView.registerNib(nib_request, forCellReuseIdentifier: "FriendRequestCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        self.sideMenuController()?.sideMenu?.behindViewController = self
        
        // Set Default tab to Suggestions/Pending Request
        self.friends_tab = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Friends Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        if let tabBarItems = self.tabBarController?.tabBar.items {
            let friend_tabBarItem : UITabBarItem = tabBarItems[3]
            if friend_tabBarItem.badgeValue != nil || self.friends_tab == 1 {
                // set the suggestions Tab to be displayed by default
                self.suggestionsTab(self)
            }
        }

        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }

    
    // MARK: - function to load/fetch data from server
    func loadRequestData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            let newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
            loadingActivityVC.view.frame = newframe
            self.view.addSubview(loadingActivityVC.view)
        }
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "page": self.suggestions_page.description
        ]
        
        Alamofire.request(.POST, ApiLink.suggestions_and_request, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if pagination == true {
                    self.loadingIndicator.stopAnimating()
                } else {
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    if json["request"].count != 0 {
                        for var i:Int = 0; i < json["request"].count; i++ {
                            let friend = Friend.init(json: json["request"][i])
                            self.request_array.append(friend)
                        }
                    }
                    if json["suggestions"].count != 0 {
                        for var i:Int = 0; i < json["suggestions"].count; i++ {
                            let friend = Friend.init(json: json["suggestions"][i])
                            self.suggestions_array.append(friend)
                        }
                        self.suggestions_page += 1
                        self.loadMoreSuggestionsData = true
                    } else {
                        self.loadMoreSuggestionsData = false
                    }
                    
                    self.tableView.reloadData()
                    
                    
                    if let tabBarItems = self.tabBarController?.tabBar.items {
                        
                        // Update Badge of Alert TabBarItem
                        let alert_tabBarItem : UITabBarItem = tabBarItems[4]
                        if json["new_alert_nb"] != 0 {
                            alert_tabBarItem.badgeValue = json["new_alert_nb"].stringValue
                        } else {
                            alert_tabBarItem.badgeValue = nil
                        }
                        
                        // Update Badge of Friends TabBarItem
                        let friend_tabBarItem : UITabBarItem = tabBarItems[3]
                        if json["new_friends_request_nb"] != 0 {
                            friend_tabBarItem.badgeValue = json["new_friends_request_nb"].stringValue
                        } else {
                            friend_tabBarItem.badgeValue = nil
                        }
                    }
                    
                    
                    
                    // Display "Search for Facebook's Friend" Button if the user didn't link his account yet
                    if json["is_facebook_link"] == true {
                        self.linkFacebookButton.hidden = true
                        self.friendsTab_FriendsTV_constraints.constant = 0.0
                    } else {
                        self.linkFacebookButton.hidden = false
                        self.friendsTab_FriendsTV_constraints.constant = 40.0
                    }
                }
                self.display_empty_message()

                self.tableView.tableFooterView = nil
        }
    }
    
    func loadData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            let newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
            loadingActivityVC.view.frame = newframe

            self.view.addSubview(loadingActivityVC.view)
        }

        var api_link: String!
        var page: Int!
        
        if self.friends_tab == 2 {
            api_link = ApiLink.following_list
            page = self.following_page
            
        }
        if self.friends_tab == 3 {
            api_link = ApiLink.followers_list
            page = self.followers_page
        }
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "page": page.description
        ]
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if pagination == true {
                    self.loadingIndicator.stopAnimating()
                } else {
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                }
                
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            let friend = Friend.init(json: json["users"][i])
                            
                            if self.friends_tab == 2 {
                                self.following_array.append(friend)
                            }
                            if self.friends_tab == 3 {
                                self.followers_array.append(friend)                            }
                            
                        }
                        
                        if self.friends_tab == 2 {
                            self.loadMoreFollowingData = true
                            self.following_page += 1
                        } else {
                            self.loadMoreFollowersData = true
                           self.followers_page += 1
                        }
                    } else {
                        if self.friends_tab == 2 {
                            self.loadMoreFollowingData = false
                        } else {
                            self.loadMoreFollowersData = false
                        }
                    }
                    
                    self.tableView.reloadData()
                    
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
                    
                }
                self.display_empty_message()
                self.tableView.tableFooterView = nil
        }
    }
    
    // MARK: - action on each tab
    @IBAction func suggestionsTab(sender: AnyObject) {
        self.suggestionsButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.followingButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followersButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 1
        
        if let tabBarItems = self.tabBarController?.tabBar.items {
            let friend_tabBarItem : UITabBarItem = tabBarItems[3]
            
            if self.suggestions_first_time == true || friend_tabBarItem.badgeValue != nil {
                self.suggestions_page = 1
                self.suggestions_array.removeAll(keepCapacity: false)
                self.request_array.removeAll(keepCapacity: false)
                self.tableView.reloadData()
                self.loadRequestData(false)
                self.suggestions_first_time = false
            } else {
                self.tableView.reloadData()
            }
        } else {
            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
        }

    }
    
    @IBAction func followingTab(sender: UIButton) {
        self.followingButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.suggestionsButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followersButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 2
        
        if self.following_first_time == true {
            self.following_page = 1
            self.following_array.removeAll(keepCapacity: false)
            self.tableView.reloadData()
            self.loadData(false)
            self.following_first_time = false
            
        } else {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func followersTab(sender: UIButton) {
        self.followersButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.suggestionsButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followingButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 3
        
        if self.followers_first_time == true {
            self.followers_page = 1
            self.followers_array.removeAll(keepCapacity: false)
            self.tableView.reloadData()
            self.loadData(false)
            self.followers_first_time = false
        } else {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - action "Link Facebook" button
    @IBAction func linkFacebook(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut() //Otherwie can crash
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
            if (error != nil) {
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
            } else {
                self.linkWithFacebook()
            }
        })

    }
    
    func linkWithFacebook()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email,first_name,last_name,locale"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
            } else {
                let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let fbTokenExpiresAt = FBSDKAccessToken.currentAccessToken().expirationDate.timeIntervalSince1970
                let user_id = result.valueForKey("id") as! String
                let userProfileImage = "http://graph.facebook.com/\(user_id)/picture?type=large"
                var facebook_locale: String = "en_US"

                if result.valueForKey("locale") != nil {
                    facebook_locale = result.valueForKey("locale") as! String
                }
                
                let keychain = Keychain(service: "challfie.app.service")
                let login = keychain["login"]!
                let auth_token = keychain["auth_token"]!
                
                let parameters:[String: AnyObject] = [
                    "login": login,
                    "auth_token": auth_token,
                    "uid": user_id,
                    "firstname": result.valueForKey("first_name") as! String,
                    "lastname": result.valueForKey("last_name") as! String ,
                    "fbtoken": fbAccessToken,
                    "fbtoken_expires_at": fbTokenExpiresAt,
                    "fb_locale": facebook_locale,
                    "facebook_picture": userProfileImage
                ]
                
                Alamofire.request(.POST, ApiLink.facebook_link_account, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        case .Success(let mydata):
                            //convert to SwiftJSON
                            let json = JSON(mydata)

                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)
                            } else {
                                self.suggestions_page = 1
                                self.suggestions_array.removeAll(keepCapacity: false)
                                self.request_array.removeAll(keepCapacity: false)
                                self.loadRequestData(false)
                            }
                        }
                        
                }
            }
        })
    }
    
    
    // MARK: - Display Message if Empty
    func display_empty_message() {
        let messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
        messageLabel.textColor = MP_HEX_RGB("000000")
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        if self.friends_tab == 1 {
            if (self.suggestions_array.count == 0) {
                // Display a message when the table is empty
                
                messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found..")
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                self.tableView.backgroundView = messageLabel
            } else {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            }
        } else {
            if self.friends_tab == 2 {
                if (self.following_array.count == 0) {
                    messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found..")
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

                }
            } else {
                if (self.followers_array.count == 0) {
                    messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found..")
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                }
            }
        }
    }
    
    // MARK: - Tap Gesture to push to Search Page
    func tapGestureToSearchPage() {
        let globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: NSLocalizedString("Friends_tab", comment: "Friends"))
        
    }
    
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var numberRows: Int!
            if self.friends_tab == 1 {
                numberRows = self.request_array.count
            }
            if self.friends_tab == 2 {
                numberRows = self.following_array.count
            }
            if self.friends_tab == 3 {
                numberRows = self.followers_array.count
            }
            return numberRows
        } else {
            return self.suggestions_array.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.friends_tab == 1 {
            // Return 2 sections if "Suggestions & Pending Request Tab"
            return 2
        } else {
            // Return 1 Sections if "Followers" & "Following" Tab
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.friends_tab == 1 {
            if section == 0 {
                if self.request_array.count == 0 {
                    return 0.0
                } else {
                    return 25.0
                }
            } else {
                return 25.0
            }                       
        }
        
        // Remove the header for "Following" and "Followers" Tab
        return 0.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Add Header for the "Friends Suggestions Tab"
        // One Header for "Pending Request"
        // One HEader for "Friends Suggestions"
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 20.0))
        headerView.backgroundColor = MP_HEX_RGB("1A596B")
        let headerLabel = UILabel(frame: CGRectMake(10.0, 5.0, tableView.frame.width, 17.0))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        headerLabel.textColor = MP_HEX_RGB("FFFFFF")
        
        headerView.addSubview(headerLabel)
        
        if section == 0 {
            if self.friends_tab == 1 {
                headerLabel.text = NSLocalizedString("Friend_request", comment: "Friend Request")
            } else {
                return nil
            }
        } else {
            if self.friends_tab == 1 {
                headerLabel.text = NSLocalizedString("Friends_suggestions", comment: "Friends Suggestions")
            } else {
                return nil
            }
        }
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTVCell

        var friend: Friend!
        if self.friends_tab == 1 {
            if indexPath.section == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("FriendRequestCell") as! FriendRequestTVCell
                friend = self.request_array[indexPath.row]
            } else {
                friend = self.suggestions_array[indexPath.row]
            }
        } else {
            if self.friends_tab == 2 {
                friend = self.following_array[indexPath.row]
            }
            if self.friends_tab == 3 {
                friend = self.followers_array[indexPath.row]
            }
        }
        
        cell.friendVC = self
        cell.friend = friend
        cell.indexPath = indexPath
        cell.tableView = self.tableView
        cell.loadItem(self.friends_tab)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        if self.loadingIndicator.isAnimating() == false {
            var shouldLoadMoreData : Bool = false
            if self.friends_tab == 1 {
                if indexPath.section != 0 && (indexPath.row == self.suggestions_array.count - 1) && (self.loadMoreSuggestionsData == true) {
                    shouldLoadMoreData = true
                }
            } else {
                if self.friends_tab == 2 {
                    if (indexPath.row == self.following_array.count - 1) && (self.loadMoreFollowingData == true) {
                        shouldLoadMoreData = true
                    }
                }
                if self.friends_tab == 3 {
                    if (indexPath.row == self.followers_array.count - 1) && (self.loadMoreFollowersData == true) {
                        shouldLoadMoreData = true
                    }
                }
            }
            
            if shouldLoadMoreData == true {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                
                // Load Next Page of Selfies for User Timeline
                if self.friends_tab == 1 {
                    self.loadRequestData(true)
                } else {
                    self.loadData(true)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.friends_tab == 1 {
            // Disable "Swipe to Delete" for "Pending Request"
            if indexPath.section == 0 {
                return false
            } else {
                return true
            }
        } else {
            // Enable "Swipe to Delete" for "Followers" & "Following" Tab
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Delete Following/Follower or Decline Follower's Request
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let cell : FriendTVCell = tableView.cellForRowAtIndexPath(indexPath) as! FriendTVCell
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            var apilink: String!
            
            let parameters = [
                "login": login,
                "auth_token": auth_token,
                "user_id": cell.friend.id.description
            ]
            if self.friends_tab == 1 && (indexPath.section == 1) {
                // Swipe to remove a suggestion
                self.suggestions_array.removeAtIndex(indexPath.row)
                apilink = ApiLink.remove_suggestions
            }
            
            if self.friends_tab == 2 {
                // Swipe to remove a following relationship
                self.following_array.removeAtIndex(indexPath.row)
                apilink = ApiLink.unfollow
            }
            
            if ((self.friends_tab == 1  && indexPath.section == 0) || (self.friends_tab == 3)) {
                // Swipe to reject a pending request OR to remove a follower relationship
                if self.friends_tab == 3 {
                    self.followers_array.removeAtIndex(indexPath.row)
                } else {
                    self.request_array.removeAtIndex(indexPath.row)
                }
                
                apilink = ApiLink.remove_follower
            }
            
            Alamofire.request(.POST, apilink, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    case .Success(let mydata):
                        //Convert to SwiftJSON
                        var json = JSON(mydata)
                        if (json["success"].intValue == 0) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        }
                    }
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FriendTVCell
        
        // Push to ProfilVC of the selected Row
        let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.friend
        
        profilVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
    
    // MARK: - ENSideMenu Delegate
    func toggleSideMenu() {
        toggleSideMenuView()
    }

    
}