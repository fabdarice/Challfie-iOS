//
//  TimelineCustomCell.swift
//  Challfie
//
//  Created by fcheng on 12/3/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire
//import Haneke

class TimelineTableViewCell : UITableViewCell {
    
    @IBOutlet weak var selfieView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profile_pic: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var selfieDateLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var numberApprovalLabel: UILabel!
    @IBOutlet weak var numberDisapprovalLabel: UILabel!
    @IBOutlet weak var commentUsernameLabel: UILabel!
    @IBOutlet weak var commentMessageLabel: UILabel!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var disapproveButton: UIButton!
    @IBOutlet weak var challengeStatusImage: UIImageView!
    @IBOutlet weak var numberCommentsButton: UIButton!
    
    var selfie: Selfie!
    var timelineVC: TimelineVC!
    
    func loadItem(#selfie: Selfie) {
        
        self.selfie = selfie
        
        // Cell Background
        self.contentView.backgroundColor = MP_HEX_RGB("e9eaed")
        
        // Selfie Border color
        self.selfieView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.selfieView.layer.borderWidth = 1.0
        
        // Make Cells Non Selectable
        self.selectionStyle = UITableViewCellSelectionStyle.None                
        
        // USERNAME STYLE
        self.usernameLabel.text = selfie.user.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        var usernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        usernametapGesture.addTarget(self, action: "tapGestureToProfil")
        self.usernameLabel.addGestureRecognizer(usernametapGesture)
        self.usernameLabel.userInteractionEnabled = true
        
        // Selfie Level
        //self.levelLabel.text = selfie.user.book_level
        self.levelLabel.text = "Apprentice III"
        
        // Challenge
        self.challengeLabel.text = selfie.challenge.description
        self.challengeLabel.textColor = MP_HEX_RGB("30BAE3")
        // Test Daily Challenge
        if self.selfie.is_daily == true {
            self.challengeLabel.text = NSLocalizedString("daily", comment: "Daily") + " - " + self.challengeLabel.text!
        }
        
        // Selfie Creation Date
        self.selfieDateLabel.text = selfie.creation_date
        
        // Selfie Message
        self.messageLabel.text = selfie.message
        self.messageLabel.numberOfLines = 0         // For Dynamic Auto sizing Cells
        
        // Number of comments
        self.numberCommentsButton.setTitleColor(MP_HEX_RGB("30768A"), forState: UIControlState.Normal)
        if selfie.nb_comments <= 1 {
            self.numberCommentsButton.setTitle(selfie.nb_comments.description + NSLocalizedString("Comment", comment: "Comment"), forState: UIControlState.Normal)
        } else {
            self.numberCommentsButton.setTitle(selfie.nb_comments.description + NSLocalizedString("Comments", comment: "Comments"), forState: UIControlState.Normal)
        }
        
        
        // Number of approval
        self.numberApprovalLabel.textColor = MP_HEX_RGB("30768A")
        if selfie.nb_upvotes <= 1 {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
        } else {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
        }
        
        
        // Number of disapproval
        self.numberDisapprovalLabel.textColor = MP_HEX_RGB("919191")
        if selfie.nb_downvotes <= 1 {
            self.numberDisapprovalLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
        } else {
            self.numberDisapprovalLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
        }
        
        
        // Last Comment Border color
        self.bottomContentView.layer.borderColor = MP_HEX_RGB("E0E0E0").CGColor
        self.bottomContentView.layer.borderWidth = 0.5
                
        // Last Comment Username
        self.commentUsernameLabel.setNeedsUpdateConstraints()
        self.commentUsernameLabel.text = selfie.last_comment.username
        self.commentUsernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        self.commentUsernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        var commentUsernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        commentUsernametapGesture.addTarget(self, action: "tapGestureToCommenterProfil")
        self.commentUsernameLabel.addGestureRecognizer(commentUsernametapGesture)
        self.commentUsernameLabel.userInteractionEnabled = true
        
        // Last Comment Message
        let comment_message_style = NSMutableParagraphStyle()
        comment_message_style.firstLineHeadIndent = CGFloat(self.commentUsernameLabel.frame.width + 5.0)
        comment_message_style.headIndent = 0.0
        //var comment_message_indent = NSMutableAttributedString(string: "HELLOTest1\nTest Long Line so that it will break without adding the new line char to the string.")
        var comment_message_indent = NSMutableAttributedString(string: selfie.last_comment.message)
        
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
        case "iPhone 6 Plus" : sizeScale = 2.0
        default:
            sizeScale = 1.0
        }
        
        // Test if Last comment exists or not
        if comment_message_indent.length != 0 {
            self.bottomContentView.backgroundColor = MP_HEX_RGB("F7F7F7")
            comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
            self.commentMessageLabel.attributedText = comment_message_indent
            self.commentMessageLabel.font = UIFont(name: "Helvetica Neue", size: 13.0 * sizeScale)
            self.commentMessageLabel.textColor = MP_HEX_RGB("000000")
            self.commentMessageLabel.numberOfLines = 0
        } else {
            // No Last Comment - Display a proper message
            self.bottomContentView.backgroundColor = MP_HEX_RGB("FFFFFF")
            self.commentMessageLabel.text = NSLocalizedString("first_comment", comment: "Be the first one to write a comment..")
            self.commentMessageLabel.font = UIFont.italicSystemFontOfSize(13.0 * sizeScale)
            self.commentMessageLabel.textColor = MP_HEX_RGB("919191")
            
        }
        
        
        // Approve Button && Disapprove Button
        if selfie.user_vote_status == 1 {
            self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
            self.disapproveButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
        } else if selfie.user_vote_status == 2 {
            self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
            self.disapproveButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
        } else {
            self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
            self.disapproveButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
        }
        
        
        // Profile Picture
        if selfie.user.show_profile_pic() != "missing" {
            let profileImageURL:NSURL = NSURL(string: selfie.user.show_profile_pic())!
            self.profile_pic.hnk_setImageFromURL(profileImageURL)
        } else {
            self.profile_pic.image = UIImage(named: "missing_user")
        }
        
        self.profile_pic.layer.cornerRadius = self.profile_pic.frame.size.width / 2
        self.profile_pic.clipsToBounds = true
        self.profile_pic.layer.borderWidth = 2.0
        if selfie.user.book_tier == 1 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("f3c378").CGColor;
        }
        if selfie.user.book_tier == 2 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("77797a").CGColor;
        }
        if selfie.user.book_tier == 3 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("fff94b").CGColor;
        }
        var profilPictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        profilPictapGesture.addTarget(self, action: "tapGestureToProfil")
        self.profile_pic.addGestureRecognizer(profilPictapGesture)
        self.profile_pic.userInteractionEnabled = true
        
        
        // Selfie Image
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)       
        
        // Set Selfies Challenge Status
        if selfie.approval_status == 0 {
            self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
        } else if selfie.approval_status == 1 {
            self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
        } else if selfie.approval_status == 2 {
            self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
        }
        
    }
    
    
    @IBAction func approveButton(sender: UIButton) {
        
        // Perform the action only if the user hasn't approved yet the Selfie
        if self.selfie.user_vote_status != 1 {
            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "id": self.selfie.id.description
            ]
            
            request(.POST, ApiLink.selfie_approve, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata == nil) {
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.timelineVC.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        //convert to SwiftJSON
                        let json = JSON_SWIFTY(mydata!)
                        
                        if (json["success"].intValue == 0) {
                            var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.timelineVC.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            if self.selfie.approval_status != json["approval_status"].intValue {
                                self.selfie.approval_status = json["approval_status"].intValue
                                // Set Selfies Challenge Status
                                if self.selfie.approval_status == 0 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
                                } else if self.selfie.approval_status == 1 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
                                } else if self.selfie.approval_status == 2 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
                                }
                            }
                            
                            
                            self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
                            
                            // Selfies was initially rejected by the user
                            if self.selfie.user_vote_status == 2 {
                                self.disapproveButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
                                self.selfie.nb_downvotes = self.selfie.nb_downvotes - 1
                                
                                if self.selfie.nb_downvotes <= 1 {
                                    self.numberDisapprovalLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
                                } else {
                                    self.numberDisapprovalLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
                                }
                            }
                            
                            self.selfie.nb_upvotes = self.selfie.nb_upvotes + 1
                            self.selfie.user_vote_status = 1
                            
                            if self.selfie.nb_upvotes <= 1 {
                                self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
                            } else {
                                self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
                            }
                        }
                        
                    }
            }
        }
    }
    
    
    @IBAction func disapproveButton(sender: UIButton) {
        // Perform the action only if the user hasn't rejected yet the Selfie
        if self.selfie.user_vote_status != 2 {
            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
                "id": self.selfie.id.description
            ]
            
            request(.POST, ApiLink.selfie_reject, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata == nil) {
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.timelineVC.presentViewController(alert, animated: true, completion: nil)
                    } else {                        
                        //convert to SwiftJSON
                        let json = JSON_SWIFTY(mydata!)
                        
                        if (json["success"].intValue == 0) {
                            var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                            self.timelineVC.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            if self.selfie.approval_status != json["approval_status"].intValue {
                                self.selfie.approval_status = json["approval_status"].intValue
                                // Set Selfies Challenge Status
                                if self.selfie.approval_status == 0 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
                                } else if self.selfie.approval_status == 1 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
                                } else if self.selfie.approval_status == 2 {
                                    self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
                                }
                            }
                            
                            self.disapproveButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
                            
                            // Selfies was initially approved by the user
                            if self.selfie.user_vote_status == 1 {
                                self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
                                self.selfie.nb_upvotes = self.selfie.nb_upvotes - 1
                                
                                if self.selfie.nb_upvotes <= 1 {
                                    self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
                                } else {
                                    self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
                                }
                            }
                            
                            self.selfie.nb_downvotes = self.selfie.nb_downvotes + 1
                            self.selfie.user_vote_status = 2
                            
                            if self.selfie.nb_downvotes <= 1 {
                                self.numberDisapprovalLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
                            } else {
                                self.numberDisapprovalLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
                            }
                        }
                    }
            }
        }
    }    
    
    
    @IBAction func commentButton(sender: UIButton) {
        // Hide TabBar when push to OneSelfie View
        self.timelineVC.hidesBottomBarWhenPushed = true
        
        // Push to OneSelfieVC
        var oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
        oneSelfieVC.selfie = self.selfie
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
    }
    
    
    @IBAction func numberCommentsButton(sender: AnyObject) {
        self.timelineVC.hidesBottomBarWhenPushed = true
        var oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
        oneSelfieVC.selfie = self.selfie
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
    }

    
    func tapGestureToProfil() {
        // Push to ProfilVC of the selfie's user
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = self.selfie.user
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(profilVC, animated: true)
        
    }
    
    func tapGestureToCommenterProfil() {
        // Push to ProfilVC of Commenter
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "user_id": self.selfie.last_comment.user_id
        ]
        
        request(.POST, ApiLink.show_user_profile, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.timelineVC.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    var last_commenter: User!
                    
                    if json["user"].count != 0 {
                        last_commenter = User.init(json: json["user"])
                    }
                    
                    // Push to OneSelfieVC
                    var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                    profilVC.user = last_commenter
                    self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                    self.timelineVC.navigationController?.pushViewController(profilVC, animated: true)
                }
        }
        
    }
    
}