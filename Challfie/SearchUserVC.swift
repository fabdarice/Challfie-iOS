//
//  SearchUserVC.swift
//  Challfie
//
//  Created by fcheng on 1/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

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
        self.searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchBarTextFieldBackground"), forState: UIControlState.Normal)
        self.searchBar.placeholder = NSLocalizedString("search_username", comment: "Search by Username or Email")
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // set delegate
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "FriendTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendCell")

        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 20.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show navigationBar
        self.navigationController?.navigationBarHidden = false
        // Don't hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    // UISearchBarDelegate, UISearchDisplayDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.users_array.removeAll(keepCapacity: false)
        searchBar.resignFirstResponder()
        if countElements(searchBar.text) >= 2 {
            // add loadingIndicator pop-up
            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            var newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
            loadingActivityVC.view.frame = newframe
            self.view.addSubview(loadingActivityVC.view)

            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "user_input": searchBar.text
            ]
            
            request(.POST, ApiLink.autocomplete_search_user, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    if (mydata == nil) {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    } else {
                        //Convert to SwiftJSON
                        var json = JSON_SWIFTY(mydata!)
                        
                        if json["users"].count != 0 {
                            for var i:Int = 0; i < json["users"].count; i++ {
                                var user = Friend.init(json: json["users"][i])
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
            var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, self.view.bounds.size.height))
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
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as FriendTVCell
        var user: Friend!
        
        user = self.users_array[indexPath.row]
        cell.friend = user
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
        var cell : FriendTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as FriendTVCell
        
        // Push to ProfilVC of the selected Row
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.friend
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
    
    
}
