//
//  ListCommentsCell.swift
//  Challfie
//
//  Created by fcheng on 12/5/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

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
        
        // Custom Label Size based on Device
        let model = UIDevice.currentDevice().modelName
        var sizeScale: CGFloat!
        
        switch model {
        case "iPhone 4": sizeScale = 0.9
        case "iPhone 4S": sizeScale = 0.9
        case "iPhone 5": sizeScale = 0.9
        case "iPhone 5c": sizeScale = 0.9
        case "iPhone 5s": sizeScale = 0.9
        case "iPhone 6" : sizeScale = 1.0
        case "iPhone 6 Plus" : sizeScale = 1.1
        default:
            sizeScale = 1.0
        }
        
        // Last Comment Username
        //self.usernameLabel.setNeedsUpdateConstraints()
        self.usernameLabel.text = self.comment.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        self.usernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        var commentUsernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        commentUsernametapGesture.addTarget(self, action: "tapGestureToCommenterProfil")
        self.usernameLabel.addGestureRecognizer(commentUsernametapGesture)
        self.usernameLabel.userInteractionEnabled = true
        
        // Message Style - Indent First Line
        let comment_message_style = NSMutableParagraphStyle()
        comment_message_style.firstLineHeadIndent = CGFloat(self.usernameLabel.frame.width + 5.0)
        comment_message_style.headIndent = 0.0
        var comment_message_indent = NSMutableAttributedString(string: self.comment.message)
        // Test if Last comment exists or not
        comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
        self.messageLabel.attributedText = comment_message_indent
        self.messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0 * sizeScale)
        self.messageLabel.textColor = MP_HEX_RGB("000000")
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
    }
    
    func tapGestureToCommenterProfil() {
        // Push to ProfilVC of Commenter
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "user_id": self.comment.user_id
        ]
        
        request(.POST, ApiLink.show_user_profile, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.oneSelfieVC)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    var commenter: User!
                    
                    if json["user"].count != 0 {
                        commenter = User.init(json: json["user"])
                    }
                    
                    // Push to OneSelfieVC
                    var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                    profilVC.user = commenter
                    self.oneSelfieVC.navigationController?.pushViewController(profilVC, animated: true)
                }
        }
        
    }
}