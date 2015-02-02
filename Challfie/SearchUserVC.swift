//
//  SearchUserVC.swift
//  Challfie
//
//  Created by fcheng on 1/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire

class SearchUserVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var users_array:[Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.loadingIndicator.hidesWhenStopped = true
        
        // set top background color
        self.topView.backgroundColor = MP_HEX_RGB("30768A")
        
        // set searchBar textfield backgroun to white
        self.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchBarTextFieldBackground"), forState: UIControlState.Normal)
        
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
    
    // UISearchBarDelegate, UISearchDisplayDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.users_array.removeAll(keepCapacity: false)
        searchBar.resignFirstResponder()
        if countElements(searchBar.text) >= 2 {
            self.loadingIndicator.startAnimating()

            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "user_input": searchBar.text
            ]
            
            Alamofire.request(.POST, ApiLink.autocomplete_search_user, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata == nil) {
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        //Convert to SwiftJSON
                        println(mydata)
                        var json = JSON(mydata!)
                        
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
                    self.loadingIndicator.stopAnimating()
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
            messageLabel.font = UIFont(name: "Chinacat", size: 16.0)
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
