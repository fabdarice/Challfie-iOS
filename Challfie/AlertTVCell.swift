//
//  AlertTVC.swift
//  Challfie
//
//  Created by fcheng on 12/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Haneke


class AlertTVCell : UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    func loadItem(alert:Alert) {
        
        // Change background if the alert is unread
        if alert.read == true {
            self.backgroundColor = MP_HEX_RGB("FFFFFF")
        } else {
            self.backgroundColor = MP_HEX_RGB("EDF9FC")
        }
        
        // Test if we display the username or not
        if (alert.type_notification != "selfie_status") && (alert.type_notification != "book_unlock") && (alert.type_notification != "daily_challenge") {
            // Alert Username
            self.usernameLabel.hidden = false
            self.usernameLabel.text = alert.author.username
            self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
            self.usernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
            
            // Message Style - Indent First Line
            let message_style = NSMutableParagraphStyle()
            message_style.firstLineHeadIndent = CGFloat(self.usernameLabel.frame.width + 1.0)
            message_style.headIndent = 0.0
            var message_style_indent = NSMutableAttributedString(string: alert.message)
            // Test if Last comment exists or not
            message_style_indent.addAttribute(NSParagraphStyleAttributeName, value: message_style, range: NSMakeRange(0, message_style_indent.length))
            self.messageLabel.attributedText = message_style_indent
            
        } else {
            self.messageLabel.text = alert.message
            self.usernameLabel.hidden = true
        }

        self.messageLabel.textColor = MP_HEX_RGB("000000")
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
        
        // Date creation lAbel
        self.dateLabel.text = alert.time_ago
 
        // load user image
        if alert.author != nil {
            // Profile Picture
            if alert.author.show_profile_pic() != "missing" {
                let profilePicURL:NSURL = NSURL(string: alert.author.show_profile_pic())!
                self.userImageView.hnk_setImageFromURL(profilePicURL)
            } else {
                self.userImageView.image = UIImage(named: "missing_user")
            }
            
            self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
            self.userImageView.clipsToBounds = true
            self.userImageView.layer.borderWidth = 2.0
            self.userImageView.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
            if alert.author.book_tier == 1 {
                self.userImageView.layer.borderColor = MP_HEX_RGB("f3c378").CGColor;
            }
            if alert.author.book_tier == 2 {
                self.userImageView.layer.borderColor = MP_HEX_RGB("77797a").CGColor;
            }
            if alert.author.book_tier == 3 {
                self.userImageView.layer.borderColor = MP_HEX_RGB("fff94b").CGColor;
            }
        }
        
        // load book image
        if alert.book_img != "" {
            self.rightImageView.hidden = false
            var bookImageStr = ""
            if ApiLink.host == "https://challfie.com" {
                bookImageStr = alert.book_img
            } else {
                bookImageStr = ApiLink.host + alert.book_img
            }
            
            let bookImageURL:NSURL = NSURL(string: bookImageStr)!
            self.rightImageView.hnk_setImageFromURL(bookImageURL)
        } else if alert.selfie_img != "" {
            // load selfie image
            self.rightImageView.hidden = false
            var selfieImageStr = ""
            if ApiLink.host == "https://challfie.com" {
                selfieImageStr = alert.selfie_img
            } else {
                selfieImageStr = ApiLink.host + alert.selfie_img
            }
            
            let selfieImageURL:NSURL = NSURL(string: selfieImageStr)!
            self.rightImageView.hnk_setImageFromURL(selfieImageURL)
        } else {
            self.rightImageView.hidden = true
        }
        
    }

    
}