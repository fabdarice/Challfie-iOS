//
//  RankingTVCell.swift
//  Challfie
//
//  Created by fcheng on 4/16/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class RankingTVCell : UITableViewCell {

    @IBOutlet weak var profilPicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    var user : User!
    var index: NSIndexPath!
    
    func loadItem() {
        
        var login = KeychainWrapper.stringForKey(kSecAttrAccount)
        
        // Check if It's current_user
        if self.user.is_current_user == true {
            self.contentView.backgroundColor = MP_HEX_RGB("FCF2DE")
        } else {
            self.contentView.backgroundColor = MP_HEX_RGB("FFFFFF")
        }
        
        // Rank LAbel
        let rank = index.row + 1
        self.rankLabel.text = rank.description

        // Username        
        self.usernameLabel.text = self.user.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        
        // Level
        self.levelLabel.text = self.user.book_level
        
        // Progression
        self.progressLabel.text = self.user.progression.description + "%"
        
        // User Profile Picture
        if self.user.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: self.user.show_profile_pic())!
            self.profilPicImageView.hnk_setImageFromURL(profilePicURL)
        } else {
            self.profilPicImageView.image = UIImage(named: "missing_user")
        }
        self.profilPicImageView.layer.cornerRadius = self.profilPicImageView.frame.size.width / 2
        self.profilPicImageView.clipsToBounds = true
        self.profilPicImageView.layer.borderWidth = 2.0
        self.profilPicImageView.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
        
        if self.user.book_tier == 1 {
            self.profilPicImageView.layer.borderColor = MP_HEX_RGB("0095AE").CGColor;
            //self.levelLabel.textColor = MP_HEX_RGB("0095AE")
        }
        if self.user.book_tier == 2 {
            self.profilPicImageView.layer.borderColor = MP_HEX_RGB("63B54A").CGColor;
            //self.levelLabel.textColor = MP_HEX_RGB("63B54A")
        }
        if self.user.book_tier == 3 {
            self.profilPicImageView.layer.borderColor = MP_HEX_RGB("8258E5").CGColor;
            //self.levelLabel.textColor = MP_HEX_RGB("8258E5")
        }

    }
}