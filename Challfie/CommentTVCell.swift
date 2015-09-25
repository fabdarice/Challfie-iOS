//
//  ListCommentsCell.swift
//  Challfie
//
//  Created by fcheng on 12/5/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class CommentTVCell : UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var comment: Comment!
    var oneSelfieVC: OneSelfieVC!
    
    func loadItem() {
        
        // Make Cells Non Selectable
        self.selectionStyle = UITableViewCellSelectionStyle.None
                
        // view background color
        self.backgroundColor = MP_HEX_RGB("F7F7F7")
        
        // Last Comment Username
        //self.usernameLabel.setNeedsUpdateConstraints()
        self.usernameLabel.text = self.comment.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        self.usernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        let commentUsernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        commentUsernametapGesture.addTarget(self, action: "tapGestureToCommenterProfil")
        self.usernameLabel.addGestureRecognizer(commentUsernametapGesture)
        self.usernameLabel.userInteractionEnabled = true
        
        // Message Style - Indent First Line
        let comment_message_style = NSMutableParagraphStyle()
        comment_message_style.firstLineHeadIndent = CGFloat(self.usernameLabel.frame.width + 5.0)
        comment_message_style.headIndent = 0.0
        let comment_message_indent = NSMutableAttributedString(string: self.comment.message)
        // Test if Last comment exists or not
        comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
        self.messageLabel.attributedText = comment_message_indent
        self.messageLabel.textColor = MP_HEX_RGB("000000")
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
    }
    
    func tapGestureToCommenterProfil() {
        // Push to ProfilVC of Commenter
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.comment.user_id
        ]
        
        Alamofire.request(.POST, ApiLink.show_user_profile, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.oneSelfieVC)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    var commenter: User!
                    
                    if json["user"].count != 0 {
                        commenter = User.init(json: json["user"])
                    }
                    
                    // Push to OneSelfieVC
                    let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                    profilVC.user = commenter
                    self.oneSelfieVC.navigationController?.pushViewController(profilVC, animated: true)
                }
        }
        
    }
}