//
//  SearchUserVC.swift
//  Challfie
//
//  Created by fcheng on 1/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class SearchUserVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users_array:[Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // set top background color
        self.topView.backgroundColor = MP_HEX_RGB("30768A")
        
        // set searchBar textfield backgroun to white
        self.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        //self.searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchBarTextFieldBackground"), forState: UIControlState.Normal)

        if let searchTextField = self.searchBar.valueForKey("searchField") as? UITextField {
            searchTextField.textColor = MP_HEX_RGB("FFFFFF")
            searchTextField.contentMode = UIViewContentMode.ScaleToFill
            let attributeDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search_username", comment: "Search by Username or Email"), attributes: attributeDict)
        }
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // set delegate
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "FriendTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")

        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Search User Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // Show navigationBar
        self.navigationController?.navigationBarHidden = false
        // Don't hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    // UISearchBarDelegate, UISearchDisplayDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.users_array.removeAll(keepCapacity: false)
        searchBar.resignFirstResponder()
        if searchBar.text!.characters.count >= 2 {
            // add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            let newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
            loadingActivityVC.view.frame = newframe
            self.view.addSubview(loadingActivityVC.view)

            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters:[String: String] = [
                "login": login,
                "auth_token": auth_token,
                "user_input": searchBar.text!
            ]
            
            request(.POST, ApiLink.autocomplete_search_user, parameters: parameters, encoding: .JSON)
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
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            let user = Friend.init(json: json["users"][i])
                            self.users_array.append(user)
                        }
                    } else {
                        self.display_empty_message()
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Function to display a message in case of an empty return results
    func display_empty_message() {
        if (self.users_array.count == 0) {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
            messageLabel.text = NSLocalizedString("no_users_found", comment: "No Results found.")
            messageLabel.textColor = MP_HEX_RGB("000000")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    // UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTVCell
        var user: Friend!
        
        user = self.users_array[indexPath.row]
        cell.friend = user
        
        // Set so it will Refresh Following Tab when visiting
        if let allTabViewControllers = self.tabBarController?.viewControllers,
            navController = allTabViewControllers[3] as? UINavigationController ,
            friendsVC = navController.viewControllers[0] as? FriendVC {
                cell.friendVC = friendsVC
        }
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FriendTVCell
        
        // Push to ProfilVC of the selected Row
        let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.friend
        profilVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
    
    
}
