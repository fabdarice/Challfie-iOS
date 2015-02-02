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
    @IBOutlet weak var suggestionsButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var linkFacebookButton: UIButton!    
    @IBOutlet weak var myProfilImage: UIImageView!    
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var friendsTab_FriendsTV_constraints: NSLayoutConstraint!
    
    var suggestions_array: [Friend] = []
    var following_array: [Friend] = []
    var followers_array: [Friend] = []
    var request_array: [Friend] = []
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var topIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var suggestions_page = 1
    var following_page = 1
    var followers_page = 1
    var friends_tab = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set Background color for topBar (kinda NavigationBar)
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
        
        // Add Top loading Indicator
        self.topIndicator.frame = CGRectMake(0, 30, UIScreen.mainScreen().bounds.width, 50)
        self.topIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.topIndicator.tintColor = MP_HEX_RGB("30768A")
        self.topIndicator.color = MP_HEX_RGB("30768A")
        self.topIndicator.hidesWhenStopped = true
        self.tableView.addSubview(self.topIndicator)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "FriendTVCell", bundle: nil)
        var nib_request = UINib(nibName: "FriendRequestTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        self.tableView.registerNib(nib_request, forCellReuseIdentifier: "FriendRequestCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        self.friends_tab = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigationController
        self.navigationController?.navigationBar.hidden = true
        
        var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as UITabBarItem
        
        if friend_tabBarItem.badgeValue != nil || self.friends_tab == 1 {
            // set the suggestions Tab to be displayed by default
            self.suggestionsTab(self)
        }
    }
    
    func loadRequestData() {
        self.loadingIndicator.startAnimating()
        self.topIndicator.startAnimating()
        
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "page": self.suggestions_page.description
        ]
        
        Alamofire.request(.POST, ApiLink.suggestions_and_request, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata != nil) {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["request"].count != 0 {
                        for var i:Int = 0; i < json["request"].count; i++ {
                            var friend = Friend.init(json: json["request"][i])
                            self.request_array.append(friend)
                        }
                    }
                    if json["suggestions"].count != 0 {
                        for var i:Int = 0; i < json["suggestions"].count; i++ {
                            var friend = Friend.init(json: json["suggestions"][i])
                            self.suggestions_array.append(friend)
                        }
                    }
                    self.suggestions_page += 1
                    self.tableView.reloadData()
                    
                    // Update Badge of Alert TabBarItem
                    var alert_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[4] as UITabBarItem
                    if json["new_alert_nb"] != 0 {
                        alert_tabBarItem.badgeValue = json["new_alert_nb"].stringValue
                    } else {
                        alert_tabBarItem.badgeValue = nil
                    }
                    
                    // Update Badge of Friends TabBarItem
                    var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as UITabBarItem
                    if json["new_friends_request_nb"] != 0 {
                        friend_tabBarItem.badgeValue = json["new_friends_request_nb"].stringValue
                    } else {
                        friend_tabBarItem.badgeValue = nil
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
                self.topIndicator.stopAnimating()
                self.loadingIndicator.stopAnimating()
                self.tableView.tableFooterView = nil
        }
    }
    
    func loadData() {
        self.loadingIndicator.startAnimating()
        self.topIndicator.startAnimating()
        
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
        
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "page": page.description
        ]
        
        Alamofire.request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            var friend = Friend.init(json: json["users"][i])
                            
                            if self.friends_tab == 2 {
                                self.following_array.append(friend)
                            }
                            if self.friends_tab == 3 {
                                self.followers_array.append(friend)                            }
                            
                        }
                        
                        if self.friends_tab == 2 {
                            self.following_page += 1
                        } else {
                           self.followers_page += 1
                        }
                    }
                    
                    self.tableView.reloadData()
                    
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
                    
                }
                self.display_empty_message()
                self.loadingIndicator.stopAnimating()
                self.tableView.tableFooterView = nil                
                self.topIndicator.stopAnimating()
        }
    }
    
    @IBAction func suggestionsTab(sender: AnyObject) {
        self.suggestionsButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.followingButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followersButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 1
        self.suggestions_array.removeAll(keepCapacity: false)
        self.request_array.removeAll(keepCapacity: false)
        self.suggestions_page = 1
        self.loadRequestData()
    }
    
    @IBAction func followingTab(sender: UIButton) {
        self.followingButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.suggestionsButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followersButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 2
        self.following_array.removeAll(keepCapacity: false)
        self.following_page = 1
        self.loadData()
    }
    
    @IBAction func followersTab(sender: UIButton) {
        self.followersButton.setBackgroundImage(UIImage(named: "friendsTab_selected_background"), forState: UIControlState.Normal)
        self.suggestionsButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.followingButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.friends_tab = 3
        self.followers_array.removeAll(keepCapacity: false)
        self.followers_page = 1
        self.loadData()
    }
    
    @IBAction func linkFacebook(sender: AnyObject) {
        println("ENTER HERE")
    }
    
    
    func display_empty_message() {
        var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
        messageLabel.textColor = MP_HEX_RGB("000000")
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "Chinacat", size: 16.0)
        if self.friends_tab == 1 {
            if (self.suggestions_array.count == 0) {
                // Display a message when the table is empty
                
                messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found.. Link your Facebook account if you haven't done it already to look for your Facebook's friends on Challfie.")
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                self.tableView.backgroundView = messageLabel
            } else {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            }
        } else {
            if self.friends_tab == 2 {
                if (self.following_array.count == 0) {
                    messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found.. Link your Facebook account if you haven't done it already to look for your Facebook's friends on Challfie.")
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

                }
            } else {
                if (self.followers_array.count == 0) {
                    messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found.. Link your Facebook account if you haven't done it already to look for your Facebook's friends on Challfie.")
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                }
            }
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
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: NSLocalizedString("Friends_tab", comment: "Friends"))
        
    }
    
    
    // tableView Delegate
    
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
            // Return 2 sections if "Suggestions Tab"
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
        var headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 20.0))
        headerView.backgroundColor = MP_HEX_RGB("C8DFE6")
        var headerLabel = UILabel(frame: CGRectMake(10.0, 5.0, tableView.frame.width, 17.0))
        headerLabel.font = UIFont(name: "Chinacat", size: 14.0)
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
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as FriendTVCell
        
        var friend: Friend!
        if self.friends_tab == 1 {
            if indexPath.section == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("FriendRequestCell") as FriendRequestTVCell
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.friends_tab == 1 {
            // Disable "Swipe to Delete" for "Suggestions Tab"
            return false
        } else {
            // Enable "Swipe to Delete" for "Followers" & "Following" Tab
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            var cell : FriendTVCell = tableView.cellForRowAtIndexPath(indexPath) as FriendTVCell
            let parameters = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "user_id": cell.friend.id.description
            ]
            if self.friends_tab == 1 {
                self.request_array.removeAtIndex(indexPath.row)
                Alamofire.request(.POST, ApiLink.remove_follower, parameters: parameters, encoding: .JSON)
            }
            if self.friends_tab == 2 {
                // Swipe to remove a following relationship
                self.following_array.removeAtIndex(indexPath.row)
                Alamofire.request(.POST, ApiLink.unfollow, parameters: parameters, encoding: .JSON)
            }
            if self.friends_tab == 3 {
                // Swipe to remove a follower relationship
                self.followers_array.removeAtIndex(indexPath.row)                
                Alamofire.request(.POST, ApiLink.remove_follower, parameters: parameters, encoding: .JSON)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            // Add Loading Indicator to footerView
            self.tableView.tableFooterView = self.loadingIndicator
            
            // Load Next Page of Selfies for User Timeline
            if self.friends_tab == 1 {
                self.loadRequestData()
            } else {
                self.loadData()
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as FriendTVCell
        
        // Push to ProfilVC of the selected Row
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.friend
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
}