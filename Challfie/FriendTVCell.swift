//
//  FriendTVCell.swift
//  Challfie
//
//  Created by fcheng on 12/16/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class FriendTVCell : UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nb_mutual_friends: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    
    func loadItem(friend: Friend) {
        self.usernameLabel.text = friend.username
        //self.profilePic.hidden = true
        //self.usernameLabel.hidden = true
        //self.nb_mutual_friends.hidden = true
        //self.relationshipButton.hidden = true
        
        if friend.nb_mutual_friends == 1 {
            self.nb_mutual_friends.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friend", comment: " mutual friend")
        } else {
            self.nb_mutual_friends.text = friend.nb_mutual_friends.description + NSLocalizedString("Mutual_friends", comment: " mutual friends")
        }
        
        let profilePicURL:NSURL = NSURL(string: friend.show_profile_pic())!
        self.profilePic.hnk_setImageFromURL(profilePicURL)
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
    }
}