//
//  FriendTVCell.swift
//  Challfie
//
//  Created by fcheng on 12/16/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class FriendTVCell : UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nb_mutual_friends: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    @IBOutlet weak var relationshipButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelImageView: UIImageView!
    
    
    var friends_tab: Int!
    var friend: Friend!
    var not_following: Bool!
    var tableView: UITableView!
    var indexPath: NSIndexPath!
    var friendVC: FriendVC!
    
    var image_following: UIImage!
    var image_follow: UIImage!
    var image_pending: UIImage!
    var image_missing_user: UIImage!
    
    var login: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize and loading images to cache it
        self.image_following = UIImage(named: "following_button")
        self.image_follow = UIImage(named: "follow_button")
        self.image_pending = UIImage(named: "pending_button")
        self.image_missing_user = UIImage(named: "missing_user")
        
        let keychain = Keychain(service: "challfie.app.service")
        login = keychain["login"]
    }
    
    func loadItem(friends_tab: Int) {
        // set image to nil to avoid misplaced image
        self.profilePic.image = nil
        self.levelImageView.image = nil
        
        // Username
        self.usernameLabel.text = friend.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        
        if (friends_tab == 1  || friends_tab == 4) {
            // Number of mutuals friends
            if friend.nb_mutual_friends == 1 {
                self.nb_mutual_friends.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friend", comment: " mutual friend")
            } else {
                self.nb_mutual_friends.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friends", comment: " mutual friends")
            }
        } else {
            // Number of followers
            if friend.nb_followers == 1 {
                self.nb_mutual_friends.text = friend.nb_followers.description + NSLocalizedString("Number_followers", comment: " follower")
            } else {
                self.nb_mutual_friends.text = friend.nb_followers.description + NSLocalizedString("Number_followers", comment: " followers")
            }
        }
        
        
        // Level Image
        let levelImageURL:NSURL = NSURL(string: friend.show_book_image())!
        self.levelImageView.hnk_setImageFromURL(levelImageURL)
        
        // User Profile Picture
        if friend.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: friend.show_profile_pic())!
            self.profilePic.hnk_setImageFromURL(profilePicURL)
        } else {
            self.profilePic.image = self.image_missing_user
        }
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 2.0
        self.profilePic.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
  
        if friend.book_tier == 1 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
        }
        if friend.book_tier == 2 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
        }
        if friend.book_tier == 3 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
        }
        
        self.relationshipButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Friendship relation Button
        self.friends_tab =  friends_tab
        if friends_tab == 1 {
        // SUGGESTIONS
            self.relationshipButtonHeightConstraint.constant = 60
            self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
        }

        if friends_tab == 2 {
        // FOLLOWING
            if friend.is_pending == true {
                // Pending Request
                self.relationshipButtonHeightConstraint.constant = 30
                self.relationshipButton.setImage(self.image_pending, forState: UIControlState.Normal)
            } else {
                // Following
                self.relationshipButtonHeightConstraint.constant = 30
                self.relationshipButton.setImage(self.image_following, forState: UIControlState.Normal)
            }
            
        }

        if (friends_tab == 3 || friends_tab == 4) {
        // FOR FOLLOWERS OR "SEARCH USER" OR "USERAPPROVAL LIST"
            // Check if it's current_user
            if friend.username == login {
                self.relationshipButton.hidden = true
            } else {
                self.relationshipButton.hidden = false
                if friend.is_following == true {
                    self.relationshipButtonHeightConstraint.constant = 30
                    self.relationshipButton.setImage(self.image_following, forState: UIControlState.Normal)
                    self.not_following = false
                } else {
                    self.not_following = true
                    self.relationshipButtonHeightConstraint.constant = 60
                    self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
                }
            }
        }

        
    }
    
    @IBAction func relationshipButton(sender: UIButton) {
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.friend.id.description
        ]
        
        self.relationshipButtonHeightConstraint.constant = 30
        self.relationshipButton.setImage(self.image_following, forState: UIControlState.Normal)
        self.friend.is_following = true
        self.friend.is_pending = true
        
        if friends_tab == 1 {
            // SUGGESTIONS
            Alamofire.request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                        self.relationshipButtonHeightConstraint.constant = 60
                        self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
                        self.friend.is_following = false
                        self.friend.is_pending = false
                    case .Success(let mydata):
                        //Convert to SwiftJSON
                        var json = JSON(mydata)
                        if (json["success"].intValue == 1) {
                            // Refresh all 3 tabs
                            if self.friendVC != nil {
                                self.friendVC.suggestions_first_time = true
                                self.friendVC.following_first_time = true
                                self.friendVC.followers_first_time = true
                            }
                        } else {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                            self.relationshipButtonHeightConstraint.constant = 60
                            self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
                            self.friend.is_following = false
                            self.friend.is_pending = false
                        }
                }
            }
        }
                
        if (friends_tab == 3 || friends_tab == 4) {
            // FOLLOWERS
            if self.not_following == true {
                Alamofire.request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                            self.relationshipButtonHeightConstraint.constant = 60
                            self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
                            self.friend.is_following = false
                            self.friend.is_pending = false
                        case .Success(let mydata):
                            //Convert to SwiftJSON
                            var json = JSON(mydata)
                            if (json["success"].intValue == 1) {
                                // Refresh all 3 tabs
                                if self.friendVC != nil {
                                    self.friendVC.suggestions_first_time = true
                                    self.friendVC.following_first_time = true
                                    self.friendVC.followers_first_time = true
                                }
                            } else {
                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.friendVC)
                                self.relationshipButtonHeightConstraint.constant = 60
                                self.relationshipButton.setImage(self.image_follow, forState: UIControlState.Normal)
                                self.friend.is_following = false
                                self.friend.is_pending = false
                            }
                        }
                }
   
            }
        }
        
    }
}