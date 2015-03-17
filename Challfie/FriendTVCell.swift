//
//  FriendTVCell.swift
//  Challfie
//
//  Created by fcheng on 12/16/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class FriendTVCell : UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nb_mutual_friends: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    
    var friends_tab: Int!
    var friend: Friend!
    var not_following: Bool!
    var tableView: UITableView!
    var indexPath: NSIndexPath!
    
    func loadItem(friends_tab: Int) {
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
        
        
        // Level
        self.levelLabel.text = friend.book_level
        
        // User Profile Picture
        if friend.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: friend.show_profile_pic())!
            self.profilePic.hnk_setImageFromURL(profilePicURL)
        } else {
            self.profilePic.image = UIImage(named: "missing_user")
        }
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 2.0
        self.profilePic.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
        if friend.book_tier == 1 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("f3c378").CGColor;
        }
        if friend.book_tier == 2 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("77797a").CGColor;
        }
        if friend.book_tier == 3 {
            self.profilePic.layer.borderColor = MP_HEX_RGB("fff94b").CGColor;
        }
        
        
        // Friendship relation Button
        self.friends_tab =  friends_tab
        if friends_tab == 1 {
        // SUGGESTIONS
            self.relationshipButton.setImage(UIImage(named: "follow_button"), forState: UIControlState.Normal)
        }

        if friends_tab == 2 {
        // FOLLOWING
            if friend.is_pending == true {
                // Pending Request
                self.relationshipButton.setImage(UIImage(named: "pending_button"), forState: UIControlState.Normal)
            } else {
                // Following
                self.relationshipButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
            }
            
        }

        if (friends_tab == 3 || friends_tab == 4) {
        // FOLLOWERS
            // Check if it's current_user
            if friend.username == KeychainWrapper.stringForKey(kSecAttrAccount)! {
                self.relationshipButton.hidden = true
            } else {
                self.relationshipButton.hidden = false
                if friend.is_following == true {
                    self.relationshipButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
                    not_following = false
                } else {
                    not_following = true
                    self.relationshipButton.setImage(UIImage(named: "follow_button"), forState: UIControlState.Normal)
                }
            }
        }
        
        self.relationshipButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    @IBAction func relationshipButton(sender: UIButton) {
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "user_id": self.friend.id.description
        ]
        
        if friends_tab == 1 {
            // SUGGESTIONS
            request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
            self.relationshipButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
            self.friend.is_following = true
            self.friend.is_pending = true
        }
                
        if (friends_tab == 3 || friends_tab == 4) {
            // FOLLOWERS
            if not_following == true {
                request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
                self.relationshipButton.setImage(UIImage(named: "following_button"), forState: UIControlState.Normal)
                self.friend.is_following = true
                self.friend.is_pending = true
            }
        }
        
    }
}