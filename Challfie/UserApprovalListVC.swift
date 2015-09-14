//
//  UserApprovalListVC.swift
//  Challfie
//
//  Created by fcheng on 8/27/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class UserApprovalListVC : UITableViewController {
    
    var selfie_id: String!
    var page = 1
    var user_array: [Friend] = []
    var is_approval_list: Bool = true
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        if self.is_approval_list == true {
            self.title = NSLocalizedString("user_list_approval", comment: "")
        } else {
            self.title = NSLocalizedString("user_list_reject", comment: "")
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
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
        var nib = UINib(nibName: "FriendTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - loadData on viewDidLoad
    func loadData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            var newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            loadingActivityVC.view.frame = newframe
            
            self.view.addSubview(loadingActivityVC.view)
        }
        
        var api_link: String!
        if self.is_approval_list == true {
            api_link = ApiLink.list_approval
        } else {
            api_link = ApiLink.list_reject
        }
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!

        
        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "page": self.page.description,
            "selfie_id": self.selfie_id
        ]
        
        request(.POST, api_link, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                // Remove loadingIndicator pop-up
                if pagination == true {
                    self.loadingIndicator.stopAnimating()
                } else {
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                }
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)

                    if json["selfies"].count != 0 {
                        for var i:Int = 0; i < json["selfies"].count; i++ {
                            var friend = Friend.init(json: json["selfies"][i])
                            self.user_array.append(friend)
                        }
                        self.page += 1
                    }
                    
                    self.tableView.reloadData()
                }
                self.display_empty_message()
                self.tableView.tableFooterView = nil
        }
    }
    
    
    // MARK: - Display Message if Empty
    func display_empty_message() {
        var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
        messageLabel.textColor = MP_HEX_RGB("000000")
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)

        if (self.user_array.count == 0) {
            // Display a message when the table is empty
            messageLabel.text = NSLocalizedString("Friends_no_results", comment: "No results found..")
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.tableView.backgroundView = messageLabel
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }

    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user_array.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTVCell
        
        // Set so it will Refresh Following Tab when visiting
        if let allTabViewControllers = self.tabBarController?.viewControllers,
            navController:UINavigationController = allTabViewControllers[3] as? UINavigationController,
            friendsVC: FriendVC = navController.viewControllers[0] as? FriendVC {
            cell.friendVC = friendsVC
        }
        
        cell.friend = self.user_array[indexPath.row]
        cell.indexPath = indexPath
        cell.tableView = self.tableView
        cell.loadItem(4)
        
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
    
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.loadingIndicator.isAnimating() == false {
            // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
            if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                
                // Load Next Page of Users
                self.loadData(true)
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FriendTVCell
        
        // Push to ProfilVC of the selected Row
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.friend
        profilVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
    
}