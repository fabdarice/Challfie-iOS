//
//  FlagContentTVCell.swift
//  Challfie
//
//  Created by fcheng on 6/26/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Haneke

class FlagContentTVCell : UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!    
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var flagNumberLabel: UILabel!
    
    func loadItem(selfie:Selfie) {
        self.flagNumberLabel.text = selfie.flag_count.description + " flags"
        self.usernameLabel.text = selfie.user.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
   
        // Profile Picture
        if selfie.user.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: selfie.user.show_profile_pic())!
            self.userProfileImageView.hnk_setImageFromURL(profilePicURL)
        } else {
            self.userProfileImageView.image = UIImage(named: "missing_user")
        }
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
        self.userProfileImageView.clipsToBounds = true
        self.userProfileImageView.layer.borderWidth = 2.0
        self.userProfileImageView.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
        if selfie.user.book_tier == 1 {
            self.userProfileImageView.layer.borderColor = MP_HEX_RGB("f3c378").CGColor
        }
        if selfie.user.book_tier == 2 {
            self.userProfileImageView.layer.borderColor = MP_HEX_RGB("77797a").CGColor
        }
        if selfie.user.book_tier == 3 {
            self.userProfileImageView.layer.borderColor = MP_HEX_RGB("fff94b").CGColor
        }        

        // load selfie image
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImageView.hnk_setImageFromURL(selfieImageURL)

    }

}