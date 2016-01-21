//
//  TimelineCustomCell.swift
//  Challfie
//
//  Created by fcheng on 12/3/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import Haneke
import SwiftyJSON
import KeychainAccess

class TimelineTableViewCell : UITableViewCell {
    
    @IBOutlet weak var selfieView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profile_pic: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var selfieDateLabel: UILabel!
    @IBOutlet weak var numberApprovalLabel: UILabel!
    @IBOutlet weak var numberDisapprovalLabel: UILabel!
    @IBOutlet weak var commentUsernameLabel: UILabel!
    @IBOutlet weak var commentMessageLabel: UILabel!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var disapproveButton: UIButton!
    @IBOutlet weak var challengeStatusImage: UIImageView!
    @IBOutlet weak var numberCommentsButton: UIButton!
    @IBOutlet weak var challengeView: UIView!    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var selfieHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelImageView: UIImageView!
    @IBOutlet weak var challengeDifficultyImageView: UIImageView!
    
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentMessageHeightConstraint: NSLayoutConstraint!
    
    var selfie: Selfie!
    var timelineVC: TimelineVC!
    var indexPath: NSIndexPath!
    
    var image_button_approved: UIImage!
    var image_button_rejected: UIImage!
    
    var image_button_approved_selected: UIImage!
    var image_button_rejected_selected: UIImage!
    
    var image_button_duel: UIImage!
    
    var image_difficulty_one: UIImage!
    var image_difficulty_two: UIImage!
    var image_difficulty_three: UIImage!
    var image_difficulty_four: UIImage!
    var image_difficulty_five: UIImage!
    var image_daily_challenge: UIImage!
    var image_challfie_logo: UIImage!
    var image_matchup_challenge: UIImage!
    
    var image_challenge_pending: UIImage!
    var image_challenge_approved: UIImage!
    var image_challenge_rejected: UIImage!
    
    var image_matchup_victory: UIImage!
    var image_matchup_defeat: UIImage!
    var image_matchup_in_progress: UIImage!
    
    var image_missing_user: UIImage!
    
    var comment_message_style: NSMutableParagraphStyle!
    
    let screen_width = UIScreen.mainScreen().bounds.width - 12 - 12
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cell Background
        self.contentView.backgroundColor = MP_HEX_RGB("e9eaed")
        
        // Set Profil Pic Frame and Gesture
        self.profile_pic.layer.cornerRadius = self.profile_pic.frame.size.width / 2
        self.profile_pic.clipsToBounds = true
        self.profile_pic.layer.borderWidth = 2.0
        let profilPictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        profilPictapGesture.addTarget(self, action: "tapGestureToProfil")
        self.profile_pic.addGestureRecognizer(profilPictapGesture)
        self.profile_pic.userInteractionEnabled = true
        
        // Cache Images
        self.image_difficulty_one = UIImage(named: "challenge_difficulty_one_small")
        self.image_difficulty_two = UIImage(named: "challenge_difficulty_two_small")
        self.image_difficulty_three = UIImage(named: "challenge_difficulty_three_small")
        self.image_difficulty_four = UIImage(named: "challenge_difficulty_four_small")
        self.image_difficulty_five = UIImage(named: "challenge_difficulty_five_small")
        self.image_daily_challenge = UIImage(named: "challenge_daily_small")
        self.image_challfie_logo = UIImage(named: "challfie_difficulty")
        self.image_matchup_challenge = UIImage(named: "icon_challenge")
        self.image_challenge_pending = UIImage(named: "challenge_pending.png")
        self.image_challenge_approved = UIImage(named: "challenge_approve.png")
        self.image_challenge_rejected = UIImage(named: "challenge_rejected")
        self.image_missing_user = UIImage(named: "missing_user")
        self.image_button_approved = UIImage(named: "approve_button.png")
        self.image_button_approved_selected = UIImage(named: "approve_select_button.png")
        self.image_button_rejected = UIImage(named: "reject_button.png")
        self.image_button_rejected_selected = UIImage(named: "reject_select_button.png")
        self.image_button_duel = UIImage(named: "duel_button.png")
        self.image_matchup_victory = UIImage(named: "matchup_victory.png")
        self.image_matchup_defeat = UIImage(named: "matchup_defeat.png")
        self.image_matchup_in_progress = UIImage(named: "matchup_in_progress.png")
    
        // Initiate comment Message Style
        self.comment_message_style = NSMutableParagraphStyle()
        self.comment_message_style.headIndent = 0.0
        
        // Selfie Border color
        self.selfieView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.selfieView.layer.borderWidth = 1.0
        
        // Make Cells Non Selectable
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        // USERNAME STYLE
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        let usernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        usernametapGesture.addTarget(self, action: "tapGestureToProfil")
        self.usernameLabel.addGestureRecognizer(usernametapGesture)
        self.usernameLabel.userInteractionEnabled = true
        
        // Challenge
        self.challengeLabel.textColor = MP_HEX_RGB("FFFFFF")
        self.challengeLabel.backgroundColor = MP_HEX_RGB("658D99")
        // ChallengeView Border & Background Color
        self.challengeView.layer.borderColor = MP_HEX_RGB("2B9ABA").CGColor
        self.challengeView.layer.borderWidth = 0.5
        self.challengeView.backgroundColor = MP_HEX_RGB("658D99")
        
        
        // Comment Username
        self.commentUsernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        let commentUsernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        commentUsernametapGesture.addTarget(self, action: "tapGestureToCommenterProfil")
        self.commentUsernameLabel.addGestureRecognizer(commentUsernametapGesture)
        self.commentUsernameLabel.userInteractionEnabled = true
        
        // Last Comment Border color
        self.bottomContentView.layer.borderColor = MP_HEX_RGB("E0E0E0").CGColor
        self.bottomContentView.layer.borderWidth = 0.5
        self.bottomContentView.backgroundColor = MP_HEX_RGB("FFFFFF")
        
        // Number of Comments / Approval / Reject
        self.numberCommentsButton.setTitleColor(MP_HEX_RGB("30768A"), forState: UIControlState.Normal)
        self.numberApprovalLabel.textColor = MP_HEX_RGB("30768A")
        self.numberDisapprovalLabel.textColor = MP_HEX_RGB("919191")
        
        // Add Tap Gesture to Page to retrieve list of users who approved
        let numberApprovaltapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        numberApprovaltapGesture.addTarget(self, action: "tapGestureToUserApprovalList")
        self.numberApprovalLabel.addGestureRecognizer(numberApprovaltapGesture)
        self.numberApprovalLabel.userInteractionEnabled = true
        
        // Add Tap Gesture to Page to retrieve list of users who rejected
        let numberRejecttapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        numberRejecttapGesture.addTarget(self, action: "tapGestureToUserRejectList")
        self.numberDisapprovalLabel.addGestureRecognizer(numberRejecttapGesture)
        self.numberDisapprovalLabel.userInteractionEnabled = true
        
        // Custom Label Size based on Device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "x86_64":
            switch UIScreen.mainScreen().bounds.height {
            case 480.0 :
                commentButtonWidthConstraint.constant = 80
            case 568.0:
                commentButtonWidthConstraint.constant = 80
            case 667.0:
                commentButtonWidthConstraint.constant = 90
            case 736.0:
                commentButtonWidthConstraint.constant = 100
            default:
                commentButtonWidthConstraint.constant = 90
            }
        case "iPhone 3G":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 3GS":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 4":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 4S":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 5":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 5c":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 5s":
            commentButtonWidthConstraint.constant = 80
        case "iPhone 6" :
            commentButtonWidthConstraint.constant = 90
        case "iPhone 6 Plus" :
            commentButtonWidthConstraint.constant = 100
        default:
            commentButtonWidthConstraint.constant = 90
        }        
    }
    
    func loadItem(selfie selfie: Selfie) {
        
        self.selfie = selfie
        
        // Profile Picture
        if selfie.user.show_profile_pic() != "missing" {
            let profileImageURL:NSURL = NSURL(string: selfie.user.show_profile_pic())!
            self.profile_pic.hnk_setImageFromURL(profileImageURL)
        } else {
            self.profile_pic.image = self.image_missing_user
        }
        
        if selfie.user.book_tier == 1 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
        }
        if selfie.user.book_tier == 2 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
        }
        if selfie.user.book_tier == 3 {
            self.profile_pic.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
        }
        
        // Selfie Message
        self.messageLabel.text = selfie.message
        
        // Challenge
        self.challengeLabel.text = selfie.challenge.description

        // Username
        self.usernameLabel.text = selfie.user.username

        // Selfie Creation Date
        self.selfieDateLabel.text = selfie.creation_date
        
        // Level Image
        let levelImageURL:NSURL = NSURL(string: selfie.user.show_book_image())!
        self.levelImageView.hnk_setImageFromURL(levelImageURL)
        
        if self.selfie.matchup != nil {
            self.challengeDifficultyImageView.image = self.image_matchup_challenge
        } else {
            // Test Daily Challenge
            if self.selfie.is_daily == true {
                self.challengeDifficultyImageView.image = self.image_daily_challenge
            } else {
                // Challenge Difficulty
                switch self.selfie.challenge.difficulty {
                case -1: self.challengeDifficultyImageView.image = self.image_challfie_logo
                case 1: self.challengeDifficultyImageView.image = self.image_difficulty_one
                case 2: self.challengeDifficultyImageView.image = self.image_difficulty_two
                case 3: self.challengeDifficultyImageView.image = self.image_difficulty_three
                case 4: self.challengeDifficultyImageView.image = self.image_difficulty_four
                case 5: self.challengeDifficultyImageView.image = self.image_difficulty_five
                default : self.challengeDifficultyImageView.image = nil
                }
            }
        }
        
        // set Selfies Image + height constraint to keep ratio
        self.selfieHeightConstraint.constant =  screen_width / selfie.ratio_photo
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)
        
        // Number of comments
        if selfie.nb_comments <= 1 {
            self.numberCommentsButton.setTitle(selfie.nb_comments.description + NSLocalizedString("Comment", comment: "Comment"), forState: UIControlState.Normal)
        } else {
            self.numberCommentsButton.setTitle(selfie.nb_comments.description + NSLocalizedString("Comments", comment: "Comments"), forState: UIControlState.Normal)
        }
        
        // Number of approval
        if selfie.nb_upvotes <= 1 {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
        } else {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
        }
        
        
        // Number of disapproval
        if selfie.nb_downvotes <= 1 {
            self.numberDisapprovalLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
        } else {
            self.numberDisapprovalLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
        }
        
        // Last Comment Username
        self.commentUsernameLabel.text = selfie.last_comment.username
        self.commentUsernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        
        // Last Comment Message
        self.comment_message_style.firstLineHeadIndent = CGFloat(self.commentUsernameLabel.frame.width + 5.0)
        let comment_message_indent = NSMutableAttributedString(string: selfie.last_comment.message)
        
        // Test if Last comment exists or not
        if comment_message_indent.length != 0 {
            comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: self.comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
            self.commentMessageLabel.attributedText = comment_message_indent
            self.commentMessageLabel.textColor = MP_HEX_RGB("000000")
        } else {
            // No Last Comment - Display a proper message
            self.commentMessageLabel.text = NSLocalizedString("first_comment", comment: "Be the first one to write a comment..")
            self.commentMessageLabel.textColor = MP_HEX_RGB("919191")
        }
        
        // Set Approved/Rejected Button
        if selfie.matchup != nil {
            // Selfie from Matchup
            self.approveButton.hidden = true
            self.disapproveButton.hidden = false
            // Approve Button && Disapprove Button
            self.disapproveButton.setImage(self.image_button_duel, forState: .Normal)
            
            // Matchup's STATUS
            if selfie.matchup.status == MatchupStatus.Accepted.rawValue {
                self.challengeStatusImage.image = self.image_matchup_in_progress
            } else {
                if selfie.matchup.status == MatchupStatus.Ended.rawValue {
                    if selfie.matchup.matchup_winner != nil
                        && selfie.matchup.matchup_winner == selfie.user.username {
                        self.challengeStatusImage.image = self.image_matchup_victory
                    } else {
                        self.challengeStatusImage.image = self.image_matchup_defeat
                    }
                } else {
                    if selfie.matchup.status == MatchupStatus.EndedWithDraw.rawValue {
                        self.challengeStatusImage.image = self.image_matchup_defeat
                    }
                }
            }
        } else {
            // Set Selfies Challenge Status
            if selfie.approval_status == 0 {
                self.challengeStatusImage.image = self.image_challenge_pending
            } else if selfie.approval_status == 1 {
                self.challengeStatusImage.image = self.image_challenge_approved
            } else if selfie.approval_status == 2 {
                self.challengeStatusImage.image = self.image_challenge_rejected
            }
            
            if selfie.user.is_current_user == true {
                // Hide Approve&Disapprove Button because own selfie
                self.approveButton.hidden = true
                self.disapproveButton.hidden = true
            } else {
                // Selfie Normal - Not from Matchup
                self.approveButton.hidden = false
                self.disapproveButton.hidden = false
                // Approve Button && Disapprove Button
                if selfie.user_vote_status == 1 {
                    self.approveButton.setImage(self.image_button_approved_selected, forState: UIControlState.Normal)
                    self.disapproveButton.setImage(self.image_button_rejected, forState: .Normal)
                } else if selfie.user_vote_status == 2 {
                    self.approveButton.setImage(self.image_button_approved, forState: .Normal)
                    self.disapproveButton.setImage(self.image_button_rejected_selected, forState: .Normal)
                } else {
                    self.approveButton.setImage(self.image_button_approved, forState: .Normal)
                    self.disapproveButton.setImage(self.image_button_rejected, forState: .Normal)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Set the image to NIL to avoid misplaced image
        self.selfieImage.image = nil
        self.profile_pic.image = nil
        self.levelImageView.image = nil
    }
    
    /*
    func calculateCellHeight() -> CGFloat {
        // First number is usually height Size of the UIView,UILabel,UIImage, etc..
        // Second number is always top constraint with closest neighbor
        
        let contentViewTopBottom: CGFloat = 7.0 + 7.0
        let profileImage: CGFloat = 40.0 + 5.0
        let message: CGFloat = self.messageLabel.bounds.height + 10.0
        let challengeView: CGFloat = self.challengeView.bounds.height
        let selfieHeight: CGFloat = self.selfieHeightConstraint.constant
        let approveIcon: CGFloat = 15.0 + 8.0
        let lastCommentView: CGFloat = self.bottomContentView.bounds.height + 10.0
        let commentButtonHeight: CGFloat = self.commentButton.bounds.height + 15.0 + 16.0 // 16.0 is button constraint to Cell Content View
        
        let estimateCellheight: CGFloat = contentViewTopBottom + profileImage + message + challengeView + selfieHeight + approveIcon + lastCommentView + commentButtonHeight
        return estimateCellheight
    }
*/
    
    
    @IBAction func approveButton(sender: UIButton) {
        // Perform the action only if the user hasn't approved yet the Selfie
        if self.selfie.user_vote_status != 1 {
            
            self.approveButton.setImage(self.image_button_approved_selected, forState: .Normal)
            
            // Selfies was initially rejected by the user
            if self.selfie.user_vote_status == 2 {
                self.disapproveButton.setImage(self.image_button_rejected, forState: .Normal)
            }
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters:[String: String] = [
                "login": login,
                "auth_token": auth_token,
                "id": self.selfie.id.description
            ]
            
            Alamofire.request(.POST, ApiLink.selfie_approve, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                        self.approveButton.setImage(self.image_button_approved, forState: .Normal)
                        // Selfies was initially rejected by the user
                        if self.selfie.user_vote_status == 2 {
                            self.disapproveButton.setImage(self.image_button_rejected_selected, forState: .Normal)
                        }
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        
                        if (json["success"].intValue == 0) {
                            // FAILURE
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                            
                            self.approveButton.setImage(self.image_button_approved, forState: .Normal)
                            // Selfies was initially rejected by the user
                            if self.selfie.user_vote_status == 2 {
                                self.disapproveButton.setImage(self.image_button_rejected_selected, forState: .Normal)
                            }
                        } else {
                            if self.selfie.approval_status != json["approval_status"].intValue {
                                self.selfie.approval_status = json["approval_status"].intValue
                                // Set Selfies Challenge Status
                                if self.selfie.approval_status == 0 {
                                    self.challengeStatusImage.image = self.image_challenge_pending
                                } else if self.selfie.approval_status == 1 {
                                    self.challengeStatusImage.image = self.image_challenge_approved
                                } else if self.selfie.approval_status == 2 {
                                    self.challengeStatusImage.image = self.image_challenge_rejected
                                }
                            }
                            
                            // Selfies was initially rejected by the user
                            if self.selfie.user_vote_status == 2 {
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
        if selfie.matchup != nil {
            // Go to Selfie Matchup
            self.goToSelfieMatchup()
        } else {
            // Reject Selfie
            self.disapproveSelfie()
        }
    }
    
    func goToSelfieMatchup() {
        self.timelineVC.hidesBottomBarWhenPushed = true
        // Push to OneMatchupVC of the selected Row
        let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
        oneMatchUpVC.hidesBottomBarWhenPushed = true
        oneMatchUpVC.matchup = selfie.matchup
        
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.timelineVC.navigationController!.pushViewController(oneMatchUpVC, animated: true)
    }
    
    func disapproveSelfie() {
        // Perform the action only if the user hasn't rejected yet the Selfie
        if self.selfie.user_vote_status != 2 {
            
            // Selfies was initially approved by the user
            if self.selfie.user_vote_status == 1 {
                self.approveButton.setImage(self.image_button_approved, forState: .Normal)
            }
            self.disapproveButton.setImage(self.image_button_rejected_selected, forState: .Normal)
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters:[String: String] = [
                "login": login,
                "auth_token": auth_token,
                "id": self.selfie.id.description
            ]
            
            Alamofire.request(.POST, ApiLink.selfie_reject, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                        // Selfies was initially approved by the user
                        if self.selfie.user_vote_status == 1 {
                            self.approveButton.setImage(self.image_button_approved_selected, forState: .Normal)
                        }
                        self.disapproveButton.setImage(self.image_button_rejected, forState: .Normal)
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        
                        if (json["success"].intValue == 0) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                            
                            // Selfies was initially approved by the user
                            if self.selfie.user_vote_status == 1 {
                                self.approveButton.setImage(self.image_button_approved_selected, forState: .Normal)
                            }
                            self.disapproveButton.setImage(self.image_button_rejected, forState: .Normal)
                        } else {
                            if self.selfie.approval_status != json["approval_status"].intValue {
                                self.selfie.approval_status = json["approval_status"].intValue
                                // Set Selfies Challenge Status
                                if self.selfie.approval_status == 0 {
                                    self.challengeStatusImage.image = self.image_challenge_pending
                                } else if self.selfie.approval_status == 1 {
                                    self.challengeStatusImage.image = self.image_challenge_approved
                                } else if self.selfie.approval_status == 2 {
                                    self.challengeStatusImage.image = self.image_challenge_rejected
                                }
                            }
                            
                            // Selfies was initially approved by the user
                            if self.selfie.user_vote_status == 1 {
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
        
        if selfie.matchup != nil {
            // Push to OneMatchupVC of the selected Row
            let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
            oneMatchUpVC.hidesBottomBarWhenPushed = true
            oneMatchUpVC.matchup = selfie.matchup
            
            self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            self.timelineVC.navigationController!.pushViewController(oneMatchUpVC, animated: true)
        } else {
            // Push to OneSelfieVC
            let oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
            oneSelfieVC.selfie = self.selfie
            oneSelfieVC.selfieTimelineCell = self
            self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("tab_timeline", comment: "Timeline"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.timelineVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
        }
        
    }
    
    
    @IBAction func numberCommentsButton(sender: AnyObject) {
        self.timelineVC.hidesBottomBarWhenPushed = true
        let oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
        oneSelfieVC.selfie = self.selfie
        oneSelfieVC.selfieTimelineCell = self
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("tab_timeline", comment: "Timeline"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
    }

    
    // MARK: - Tap Gesture Functions
    func tapGestureToProfil() {
        // Push to ProfilVC of the selfie's user
        let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = self.selfie.user
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        profilVC.hidesBottomBarWhenPushed = true
        self.timelineVC.navigationController?.pushViewController(profilVC, animated: true)
        
    }
    
    func tapGestureToCommenterProfil() {
        // Push to ProfilVC of Commenter
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.selfie.last_comment.user_id
        ]
        
        Alamofire.request(.POST, ApiLink.show_user_profile, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    var last_commenter: User!
                    
                    if json["user"].count != 0 {
                        last_commenter = User.init(json: json["user"])
                    }
                    
                    // Push to ProfilVC
                    let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                    profilVC.user = last_commenter
                    profilVC.hidesBottomBarWhenPushed = true
                    self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                    self.timelineVC.navigationController?.pushViewController(profilVC, animated: true)
                }
        }
        
    }
    
    func tapGestureToUserApprovalList() {
        // Push to UserApprovalListVC
        let userApprovalListVC = UserApprovalListVC()
        userApprovalListVC.is_approval_list = true
        userApprovalListVC.selfie_id = self.selfie.id.description
        userApprovalListVC.hidesBottomBarWhenPushed = true
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(userApprovalListVC, animated: true)
    }
    
    func tapGestureToUserRejectList() {
        // Push to UserApprovalListVC
        let userApprovalListVC = UserApprovalListVC()
        userApprovalListVC.is_approval_list = false
        userApprovalListVC.selfie_id = self.selfie.id.description
        userApprovalListVC.hidesBottomBarWhenPushed = true
        self.timelineVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.timelineVC.navigationController?.pushViewController(userApprovalListVC, animated: true)

    }
    
    @IBAction func settingsButton(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        var oneAction : UIAlertAction!
        
        if self.selfie.user.username == login {
            oneAction = UIAlertAction(title: NSLocalizedString("delete_selfie", comment: "Delete selfie"), style: UIAlertActionStyle.Destructive) { (_) in
                
                let delete_confirmation = UIAlertController(title: NSLocalizedString("delete_selfie", comment: "Delete selfie"), message: NSLocalizedString("delete_selfie_confiration", comment: "Are you sure you want to delete this selfie? It will be permanently deleted from your account"), preferredStyle: UIAlertControllerStyle.Alert)
                
                let confirmationOk = UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: UIAlertActionStyle.Destructive) { (_) in
                    let parameters = [
                        "login": login,
                        "auth_token": auth_token,
                        "selfie_id": self.selfie.id.description
                    ]
                    
                    // Add loadingIndicator pop-up
                    let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                    loadingActivityVC.view.tag = 21
                    self.timelineVC.view.addSubview(loadingActivityVC.view)
                    
                    Alamofire.request(.POST, ApiLink.delete_selfie, parameters: parameters, encoding: .JSON)
                        .responseJSON { _, _, result in
                            // Remove loadingIndicator pop-up
                            if let loadingActivityView = self.timelineVC.view.viewWithTag(21) {
                                loadingActivityView.removeFromSuperview()
                            }
                            
                            switch result {
                            case .Failure(_, _):
                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                            case .Success(let mydata):
                                //convert to SwiftJSON
                                let json = JSON(mydata)
                                if (json["success"].intValue == 0) {
                                    // ERROR RESPONSE FROM HTTP Request
                                    GlobalFunctions().displayAlert(title: NSLocalizedString("delete_selfie", comment: "Delete Selfie"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                                } else {
                                    // SUCCESS RESPONSE FROM HTTP Request
                                    self.timelineVC.selfies_array.removeAtIndex(self.indexPath.row)
                                    self.timelineVC.timelineTableView.reloadData()
                                }
                            }
                            
                    }
                }
                let confirmationCancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Default, handler: nil)
                
                delete_confirmation.addAction(confirmationCancel)
                delete_confirmation.addAction(confirmationOk)
                
                self.timelineVC.presentViewController(delete_confirmation, animated: true, completion: nil)
            }

        } else {
            oneAction = UIAlertAction(title: NSLocalizedString("challenge_to_a_duel", comment: "Challenge to a duel"), style: UIAlertActionStyle.Default) { (_) in
                let createMatchupVC = CreateMatchupVC(nibName: "CreateMatchup", bundle: nil)
                createMatchupVC.opponent = self.selfie.user
                createMatchupVC.parentController = self.timelineVC
                createMatchupVC.hidesBottomBarWhenPushed = true
                self.timelineVC.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                self.timelineVC.navigationController?.pushViewController(createMatchupVC, animated: true)
            }

        }
        
        
        let twoAction = UIAlertAction(title: NSLocalizedString("report_inappropriate_content", comment: "Report Inappropriate Content"), style: UIAlertActionStyle.Default) { (_) in

            let parameters = [
                "login": login,
                "auth_token": auth_token,
                "selfie_id": self.selfie.id.description
            ]
            
            // Add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            self.timelineVC.view.addSubview(loadingActivityVC.view)
            
            Alamofire.request(.POST, ApiLink.flag_selfie, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.timelineVC.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        if (json["success"].intValue == 0) {
                            // ERROR RESPONSE FROM HTTP Request
                            GlobalFunctions().displayAlert(title: NSLocalizedString("report_selfie", comment: "Report Selfie"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.timelineVC)
                        } else {
                            // SUCCESS RESPONSE FROM HTTP Request
                            GlobalFunctions().displayAlert(title: NSLocalizedString("report_selfie", comment: "Report Selfie"), message: NSLocalizedString("flag_as_inappropriate", comment: "Thank you. This selfie has been flagged as inappropriate and will be reviewed by an administrator."), controller: self.timelineVC)
                        }
                    }
            }

        }
        let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(thirdAction)
        
        self.timelineVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Function to update cell following a background refresh
    func updateCell(updated_selfie: Selfie) {
        // Number of comments
        if updated_selfie.nb_comments <= 1 {
            self.numberCommentsButton.setTitle(updated_selfie.nb_comments.description + NSLocalizedString("Comment", comment: "Comment"), forState: UIControlState.Normal)
        } else {
            self.numberCommentsButton.setTitle(updated_selfie.nb_comments.description + NSLocalizedString("Comments", comment: "Comments"), forState: UIControlState.Normal)
        }
        
        // Number of approval
        self.numberApprovalLabel.textColor = MP_HEX_RGB("30768A")
        if updated_selfie.nb_upvotes <= 1 {
            self.numberApprovalLabel.text = updated_selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
        } else {
            self.numberApprovalLabel.text = updated_selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
        }
        
        // Number of disapproval
        self.numberDisapprovalLabel.textColor = MP_HEX_RGB("919191")
        if updated_selfie.nb_downvotes <= 1 {
            self.numberDisapprovalLabel.text = updated_selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
        } else {
            self.numberDisapprovalLabel.text = updated_selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
        }
        
        // Last Comment Username
        self.commentUsernameLabel.setNeedsUpdateConstraints()
        self.commentUsernameLabel.text = updated_selfie.last_comment.username
        self.commentUsernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        self.commentUsernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        let commentUsernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        commentUsernametapGesture.addTarget(self, action: "tapGestureToCommenterProfil")
        self.commentUsernameLabel.addGestureRecognizer(commentUsernametapGesture)
        self.commentUsernameLabel.userInteractionEnabled = true
        
        // Last Comment Message
        let comment_message_style = NSMutableParagraphStyle()
        comment_message_style.firstLineHeadIndent = CGFloat(self.commentUsernameLabel.frame.width + 5.0)
        comment_message_style.headIndent = 0.0
        //var comment_message_indent = NSMutableAttributedString(string: "HELLOTest1\nTest Long Line so that it will break without adding the new line char to the string.")
        let comment_message_indent = NSMutableAttributedString(string: updated_selfie.last_comment.message)
        
        
        // Test if Last comment exists or not
        if comment_message_indent.length != 0 {
            comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
            self.commentMessageLabel.numberOfLines = 0
            self.commentMessageLabel.attributedText = comment_message_indent
            self.commentMessageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.commentMessageLabel.textColor = MP_HEX_RGB("000000")
        } else {
            // No Last Comment - Display a proper message
            //self.bottomContentView.backgroundColor = MP_HEX_RGB("FFFFFF")
            self.commentMessageLabel.text = NSLocalizedString("first_comment", comment: "Be the first one to write a comment..")
            self.commentMessageLabel.font = UIFont.italicSystemFontOfSize(13.0)
            self.commentMessageLabel.textColor = MP_HEX_RGB("919191")
        }
        
        // Set Selfies Challenge Status
        if updated_selfie.approval_status == 0 {
            self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
        } else if updated_selfie.approval_status == 1 {
            self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
        } else if updated_selfie.approval_status == 2 {
            self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
        }
    }*/
    
}