//
//  FriendRequestTVCell.swift
//  Challfie
//
//  Created by fcheng on 12/21/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class FriendRequestTVCell : FriendTVCell {
    @IBOutlet weak var profilePic2: UIImageView!
    @IBOutlet weak var usernameLabel2: UILabel!
    @IBOutlet weak var nb_mutual_friends2: UILabel!
    @IBOutlet weak var followButton: UIButton!    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var followButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelImageView2: UIImageView!
    
    override func loadItem(friends_tab: Int) {
        // set image to nil to avoid misplaced image
        self.profilePic2.image = nil
        self.levelImageView2.image = nil
        
        self.followButton.hidden = true
        self.acceptButton.hidden = false
        self.declineButton.hidden = false             
        
        // Username
        self.usernameLabel2.text = friend.username
        self.usernameLabel2.textColor = MP_HEX_RGB("3E9AB5")
        
        // Number of mutuals friends
        if friend.nb_mutual_friends == 1 {
            self.nb_mutual_friends2.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friend", comment: " mutual friend")
        } else {
            self.nb_mutual_friends2.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friends", comment: " mutual friends")
        }
        
        // Level Image
        let levelImageURL:NSURL = NSURL(string: friend.show_book_image())!
        self.levelImageView2.hnk_setImageFromURL(levelImageURL)
        
        
        // User Profile Picture
        if friend.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: friend.show_profile_pic())!
            self.profilePic2.hnk_setImageFromURL(profilePicURL)
        } else {
            self.profilePic2.image = UIImage(named: "missing_user")
        }
        
        self.profilePic2.layer.cornerRadius = self.profilePic2.frame.size.width / 2
        self.profilePic2.clipsToBounds = true
        self.profilePic2.layer.borderWidth = 2.0
        self.profilePic2.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
   
        if friend.book_tier == 1 {
            self.profilePic2.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
        }
        if friend.book_tier == 2 {
            self.profilePic2.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
        }
        if friend.book_tier == 3 {
            self.profilePic2.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
        }
        
        self.not_following = !friend.is_following
        
    }
    
    @IBAction func acceptRequestButton(sender: UIButton) {
        self.followButton.hidden = false
        self.acceptButton.hidden = true
        self.declineButton.hidden = true
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!

        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.friend.id.description
        ]
        Alamofire.request(.POST, ApiLink.accept_request, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                    self.followButton.hidden = true
                    self.acceptButton.hidden = false
                    self.declineButton.hidden = false
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    if (json["success"].intValue == 1) {
                        // Refresh all 3 tabs
                        self.friendVC.suggestions_first_time = true
                        self.friendVC.following_first_time = true
                        self.friendVC.followers_first_time = true
                        if self.not_following == true {
                            self.followButton.setImage(UIImage(named: "follow_button"), forState: UIControlState.Normal)
                            self.followButtonHeightConstraint.constant = 60
                        } else {
                            self.followButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
                            self.followButtonHeightConstraint.constant = 30
                        }
                    } else {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                        self.followButton.hidden = true
                        self.acceptButton.hidden = false
                        self.declineButton.hidden = false
                    }
                }
        }
    }
    
    
    @IBAction func declineRequestButton(sender: UIButton) {
        
        // Call datasource commitEditingStyle to decline and delete the row
        self.tableView.dataSource?.tableView!(self.tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: self.indexPath)
    }
    
    @IBAction func followButton(sender: UIButton) {
        self.followButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
        self.followButtonHeightConstraint.constant = 30
        
        if self.not_following == true {
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters = [
                "login": login,
                "auth_token": auth_token,
                "user_id": self.friend.id.description
            ]
            self.not_following = false
            
            Alamofire.request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                        self.followButton.setImage(UIImage(named: "follow_button"), forState: UIControlState.Normal)
                        self.not_following = true
                        self.followButtonHeightConstraint.constant = 60
                    case .Success(let mydata):
                        //Convert to SwiftJSON
                        var json = JSON(mydata)
                        if (json["success"].intValue == 1) {
                            // Refresh all 3 Tabs
                            self.friendVC.suggestions_first_time = true
                            self.friendVC.following_first_time = true
                            self.friendVC.followers_first_time = true
                        } else {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                            self.followButton.setImage(UIImage(named: "follow_button"), forState: UIControlState.Normal)
                            self.not_following = true
                            self.followButtonHeightConstraint.constant = 60
                        }
                    }
            }
            
            
            
        }
    }
    
    
}