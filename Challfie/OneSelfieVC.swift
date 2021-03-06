//
//  OneSelfie.swift
//  Challfie
//
//  Created by fcheng on 12/3/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Haneke
import Alamofire
import SwiftyJSON
import KeychainAccess

class OneSelfieVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var levelImageView: UIImageView!    
    @IBOutlet weak var numberCommentsLabel: UILabel!
    @IBOutlet weak var numberApprovalLabel: UILabel!
    @IBOutlet weak var numberRejectLabel: UILabel!
    @IBOutlet weak var challengeStatusImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var listCommentsTableView: UITableView!
    @IBOutlet weak var listCommentsHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var footerViewBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var commentsListView: UIView!
    @IBOutlet weak var noCommentLabel: UILabel!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var selfieImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var viewAllCommentsButton: UIButton!    
    @IBOutlet weak var viewAllCommentsButtonHeightConstraints: NSLayoutConstraint!    
    @IBOutlet weak var challengeDifficultyView: UIImageView!
    
    var original_footerViewBottomConstraints: CGFloat = 0.0
    var selfie: Selfie!
    var selfieTimelineCell: TimelineTableViewCell!
    var comments_array:[Comment] = []
    var to_bottom: Bool = true
    var is_administrator: Bool = false
    var isMatchup: Bool = false
    var parentController: UIViewController!
    var matchupEnded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OneSelfieVC - viewDidLoad")

        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        // Hide tabBar
        self.tabBarController?.tabBar.hidden = true
        
        // starting activityIndicator and set to hide when it's not spinning
        self.activityIndicator.hidesWhenStopped = true
                
        // Add Notification for when the Keyboard pop up  and when it is dismissed
        // Move the commentTextfield above the Keyboard when it pops up so it won't be hidden
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        // Keep the Original footerView Constraints to reset it in the keyboardWillHide function
        self.original_footerViewBottomConstraints = self.footerViewBottomConstraints.constant
        // Init Placeholder
        self.commentTextField.placeholder = NSLocalizedString("Write_Comment", comment: "Write a comment..")
        
        // set Delegate - See Delegate implementations at the very end of the document
        self.listCommentsTableView.delegate = self
        self.listCommentsTableView.dataSource = self
        self.commentTextField.delegate = self
        
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "CommentTVCell", bundle: nil)
        self.listCommentsTableView.registerNib(nib, forCellReuseIdentifier: "CommentCell")
        
        // Set the height of a cell dynamically
        self.listCommentsTableView.rowHeight = UITableViewAutomaticDimension
        self.listCommentsTableView.estimatedRowHeight = 10.0
        
        // Retrive list of comments of the selected Selfie
        self.loadData()
                
        // Add constraints to force vertical scrolling of UIScrollView 
        // Basically set the leading and trailing of contentView to the View's one (instead of the scrollView)
        // Can't be done in the Interface Builder (.xib)
        let leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        let rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "One Selfie Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        
        print("OneSelfieVC - viewWillAppear")
        print(self.scrollView.contentSize)
        
//                self.scrollView.contentSize = CGSizeMake(320,857.5);
//        self.scrollView.sizeToFit()
//        print(self.scrollView.contentSize)

    }
    
    override func viewWillDisappear(animated: Bool) {
        // Remove the Keyboard Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
                
    }
    
    
    // MARK: - Function to initialize selfie's information
    func loadSelfie() {
        
        print("loadSelfie()")
        // Initialize Infomation only if this selfie wasn't used for a Matchup
        if self.isMatchup == false {
            
            // USERNAME STYLE
            self.usernameLabel.text = selfie.user.username
            self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
            let usernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
            usernametapGesture.addTarget(self, action: "tapGestureToProfil")
            self.usernameLabel.addGestureRecognizer(usernametapGesture)
            self.usernameLabel.userInteractionEnabled = true
            
            // Level Image
            let bookImageURL:NSURL = NSURL(string: selfie.user.show_book_image())!
            self.levelImageView.hnk_setImageFromURL(bookImageURL)
            
            // Selfie Creation Date
            self.dateLabel.text = selfie.creation_date
            
            // Profile Picture
            if self.selfie.user.show_profile_pic() != "missing" {
                let profilePicURL:NSURL = NSURL(string: selfie.user.show_profile_pic())!
                self.profilePicImage.hnk_setImageFromURL(profilePicURL)
            } else {
                self.profilePicImage.image = UIImage(named: "missing_user")
            }
            
            self.profilePicImage.layer.cornerRadius = self.profilePicImage.frame.size.width / 2;
            self.profilePicImage.clipsToBounds = true
            self.profilePicImage.layer.borderWidth = 2.0;
            
            if self.selfie.user.book_tier == 1 {
                self.profilePicImage.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
            }
            if selfie.user.book_tier == 2 {
                self.profilePicImage.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
            }
            if selfie.user.book_tier == 3 {
                self.profilePicImage.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
            }
            let profilPictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
            profilPictapGesture.addTarget(self, action: "tapGestureToProfil")
            self.profilePicImage.addGestureRecognizer(profilPictapGesture)
            self.profilePicImage.userInteractionEnabled = true
            
            // ChallengeView Border & Background Color
            self.challengeView.layer.borderColor = MP_HEX_RGB("2B9ABA").CGColor
            self.challengeView.layer.borderWidth = 0.5
            self.challengeView.backgroundColor = MP_HEX_RGB("658D99")
            
            // Challenge
            self.challengeLabel.text = selfie.challenge.description
            self.challengeLabel.textColor = MP_HEX_RGB("FFFFFF")
            self.challengeLabel.numberOfLines = 0         // For Dynamic Auto sizing Cells
            self.challengeLabel.sizeToFit()
            
            // Test Daily Challenge
            if self.selfie.is_daily == true {
                self.challengeDifficultyView.image = UIImage(named: "challenge_daily_small")
            } else {
                // Challenge Difficulty
                switch self.selfie.challenge.difficulty {
                case -1: self.challengeDifficultyView.image = UIImage(named: "challfie_difficulty")
                case 1: self.challengeDifficultyView.image = UIImage(named: "challenge_difficulty_one_small")
                case 2: self.challengeDifficultyView.image = UIImage(named: "challenge_difficulty_two_small")
                case 3: self.challengeDifficultyView.image = UIImage(named: "challenge_difficulty_three_small")
                case 4: self.challengeDifficultyView.image = UIImage(named: "challenge_difficulty_four_small")
                case 5: self.challengeDifficultyView.image = UIImage(named: "challenge_difficulty_five_small")
                default : self.challengeDifficultyView.image = nil
                }
            }
            
            // Set Selfies Challenge Status
            if self.selfie.approval_status == 0 {
                self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
            } else if selfie.approval_status == 1 {
                self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
            } else if selfie.approval_status == 2 {
                self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
            }
            
        } else {
            print("isMatchup = true")
            // Set Approved/Rejected Button
            if selfie.matchup != nil {
                print("selfie.matchup != nil")
                // Matchup's STATUS
                if selfie.matchup.status == MatchupStatus.Accepted.rawValue {
                    self.challengeStatusImage.image = UIImage(named: "matchup_in_progress.png")
                } else {
                    if selfie.matchup.status == MatchupStatus.Ended.rawValue {
                        if selfie.matchup.matchup_winner != nil
                            && selfie.matchup.matchup_winner == selfie.user.username {
                                self.challengeStatusImage.image = UIImage(named: "matchup_victory.png")
                        } else {
                            self.challengeStatusImage.image = UIImage(named: "matchup_defeat.png")
                        }
                    } else {
                        if selfie.matchup.status == MatchupStatus.EndedWithDraw.rawValue {
                            self.challengeStatusImage.image = UIImage(named: "matchup_defeat.png")
                        }
                    }
                }
            }
        }
        
        
        // Selfie Message
        self.messageLabel.text = selfie.message
        self.messageLabel.numberOfLines = 0         // For Dynamic Auto sizing Cells
        self.messageLabel.sizeToFit()
        
        // Number of comments
        self.numberCommentsLabel.textColor = MP_HEX_RGB("30768A")
        if selfie.nb_comments <= 1 {
            self.numberCommentsLabel.text = selfie.nb_comments.description + NSLocalizedString("Comment", comment: "Comment")
        } else {
            self.numberCommentsLabel.text = selfie.nb_comments.description + NSLocalizedString("Comments", comment: "Comments")
        }
        
        if selfie.nb_comments > 20 {
            // Show the Button to display all comments
            self.viewAllCommentsButton.hidden = false
            self.viewAllCommentsButtonHeightConstraints.constant = 15.0
            self.viewAllCommentsButton.setTitle(NSLocalizedString("view_all_comments", comment: "View All Comments.."), forState: UIControlState.Normal)
            self.viewAllCommentsButton.setTitleColor(MP_HEX_RGB("30768A"), forState: UIControlState.Normal)
        } else {
            self.viewAllCommentsButton.hidden = true
            self.viewAllCommentsButtonHeightConstraints.constant = 0.0
        }
        
        // Number of approval
        self.numberApprovalLabel.textColor = MP_HEX_RGB("30768A")
        if selfie.nb_upvotes <= 1 {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
        } else {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
        }
        // Add Tap Gesture to Page to retrieve list of users who approved
        let numberApprovaltapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        numberApprovaltapGesture.addTarget(self, action: "tapGestureToUserApprovalList")
        self.numberApprovalLabel.addGestureRecognizer(numberApprovaltapGesture)
        self.numberApprovalLabel.userInteractionEnabled = true
        
        // Number of disapproval
        self.numberRejectLabel.textColor = MP_HEX_RGB("919191")
        if selfie.nb_downvotes <= 1 {
            self.numberRejectLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
        } else {
            self.numberRejectLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
        }
        // Add Tap Gesture to Page to retrieve list of users who rejected
        let numberRejecttapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        numberRejecttapGesture.addTarget(self, action: "tapGestureToUserRejectList")
        self.numberRejectLabel.addGestureRecognizer(numberRejecttapGesture)
        self.numberRejectLabel.userInteractionEnabled = true
        
        
        // Selfie Image
        self.selfieImageHeightConstraint.constant = UIScreen.mainScreen().bounds.width / selfie.ratio_photo
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)
        self.selfieImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        
        
        let keychain = Keychain(service: "challfie.app.service")
        
        if self.selfie.user.username == keychain["login"]! {
            // Hide Approve&Disapprove Button because own selfie
            self.approveButton.hidden = true
            self.rejectButton.hidden = true
        } else {
            
            if self.isMatchup == true && self.matchupEnded == true {
                // Hide Approve&Disapprove Button the matchup has ended
                self.approveButton.hidden = true
                self.rejectButton.hidden = true

            } else {
                // Show Approve&Disapprove Button because own selfie
                self.approveButton.hidden = false
                self.rejectButton.hidden = false
            }
            
            // Approve Button && Disapprove Button
            if selfie.user_vote_status == 1 {
                self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
                self.rejectButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
            } else if selfie.user_vote_status == 2 {
                self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
                self.rejectButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
            } else {
                self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
                self.rejectButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
            }
        }
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.footerViewBottomConstraints.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.footerViewBottomConstraints.constant = self.original_footerViewBottomConstraints
    }
    
    // MARK: - Retrive list of comments of the selected Selfie
    func loadData() {

        // add loadingIndicator pop-up
        let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "id": self.selfie.id.description
        ]
        
        Alamofire.request(.POST, ApiLink.show_selfie, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    if json["meta"]["hidden"].boolValue == true {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("is_deleted", comment: "This selfie has been deleted."), controller: self)
                    } else {
                        var selfie: Selfie!
                        
                        if json["selfie"].count != 0 {
                            selfie = Selfie.init(json: json["selfie"])
                            //let challenge = Challenge.init(json: json["selfie"]["challenge"])
                            //let user = User.init(json: json["selfie"]["user"])
                            
                            //selfie.challenge = challenge
                            //selfie.user = user
                            self.selfie = selfie
                        }
                        
                        self.loadSelfie()
                        self.loadComments(false)
                        
                        //print(self.scrollView.contentSize)
                    }
                }
        }                
    }
    
    // MARK: - Load Comments
    func loadComments(all_comment: Bool = false) {
        // add loadingIndicator pop-up
        let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "id": self.selfie.id.description,
            "all_comment": all_comment.description
        ]
        
        self.comments_array.removeAll(keepCapacity: false)
        
        request(.POST, ApiLink.selfie_list_comments, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json2 = JSON(mydata)
                    
                    if json2["selfies"].count != 0 {
                        for var i:Int = 0; i < json2["selfies"].count; i++ {
                            let comment = Comment.init(json: json2["selfies"][i])
                            self.comments_array.append(comment)
                        }
                        self.commentsListView.backgroundColor = MP_HEX_RGB("F7F7F7")
                        self.noCommentLabel.hidden = true
                        self.listCommentsTableView.reloadData()
                        
                        // Set the height of listCommentstableView dynamically based on the height of each cell
                        // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
                        var commentsTableView_newHeight: CGFloat = 0.0
                        for var i:Int = 0; i < self.comments_array.count; i++ {
                            commentsTableView_newHeight += self.listCommentsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)).size.height
                        }
                        self.listCommentsHeightConstraints.constant = commentsTableView_newHeight
                        
                        // scroll to the bottom of the View
                        if self.to_bottom == true {
                            let bottomOffset:CGPoint = CGPointMake(0, commentsTableView_newHeight + self.messageLabel.frame.height + self.selfieImageHeightConstraint.constant)
                            self.scrollView.setContentOffset(bottomOffset, animated: false)
                            
                        }
                    } else {
                        // Set Background Color for commentsList
                        self.noCommentLabel.hidden = false
                        self.commentsListView.backgroundColor = MP_HEX_RGB("FFFFFF")
                        self.noCommentLabel.text = NSLocalizedString("first_comment", comment: "Be the first one to write a comment..")
                        self.noCommentLabel.font = UIFont.italicSystemFontOfSize(12.0)
                        self.noCommentLabel.textColor = MP_HEX_RGB("919191")
                    }
                }
        }
    }
    
    
    // MARK - : tap Gesture Functions
    func tapGestureToProfil() {
        // Push to ProfilVC of the selfie's user
        let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = self.selfie.user
        profilVC.hidesBottomBarWhenPushed = true
        if self.isMatchup == false {
            self.navigationController?.pushViewController(profilVC, animated: true)
        } else {
            self.parentController.navigationController?.pushViewController(profilVC, animated: true)
        }
        
    }
    
    func tapGestureToUserApprovalList() {
        // Push to UserApprovalListVC
        let userApprovalListVC = UserApprovalListVC()
        userApprovalListVC.is_approval_list = true
        userApprovalListVC.selfie_id = self.selfie.id.description
        userApprovalListVC.hidesBottomBarWhenPushed = true
        if self.isMatchup == false {
            self.navigationController?.pushViewController(userApprovalListVC, animated: true)
        } else {
            self.parentController.navigationController?.pushViewController(userApprovalListVC, animated: true)
        }
    }
    
    func tapGestureToUserRejectList() {
        // Push to UserApprovalListVC
        let userApprovalListVC = UserApprovalListVC()
        userApprovalListVC.is_approval_list = false
        userApprovalListVC.selfie_id = self.selfie.id.description
        userApprovalListVC.hidesBottomBarWhenPushed = true
        if self.isMatchup == false {
            self.navigationController?.pushViewController(userApprovalListVC, animated: true)
        } else {
            self.parentController.navigationController?.pushViewController(userApprovalListVC, animated: true)
        }
    }
            
    
    // MARK : - UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentTVCell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentTVCell
        let comment:Comment = self.comments_array[indexPath.row]
        
        cell.comment = comment
        cell.oneSelfieVC = self
        cell.loadItem()
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
    
    
    // // MARK : - UITextFieldDelegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {        
        self.commentSendButton(self.sendCommentButton)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - IBAction approveButton & rejectButton
    @IBAction func approveButtonAction(sender: AnyObject) {
        // Perform the action only if the user hasn't approved yet the Selfie
        if self.selfie.user_vote_status != 1 {
            
            self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
            
            if self.selfie.user_vote_status == 2 {
                self.rejectButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
            }
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters:[String: String] = [
                "login": login,
                "auth_token": auth_token,
                "id": self.selfie.id.description
            ]
            
            request(.POST, ApiLink.selfie_approve, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
                        
                        if self.selfie.user_vote_status == 2 {
                            self.rejectButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
                        }
                        
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        
                        if (json["success"].intValue == 0) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
                            if self.selfie.user_vote_status == 2 {
                                self.rejectButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
                            }
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
                            
                            // Selfies was initially rejected by the user
                            if self.selfie.user_vote_status == 2 {
                                self.selfie.nb_downvotes = self.selfie.nb_downvotes - 1
                                
                                // Made Modifications on Timeline Cell
                                if self.selfieTimelineCell != nil {
                                    self.selfieTimelineCell.disapproveButton.setImage(self.selfieTimelineCell.image_button_rejected, forState: .Normal)
                                }
                                
                                if self.selfie.nb_downvotes <= 1 {
                                    self.numberRejectLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
                                } else {
                                    self.numberRejectLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
                                }
                            }
                            
                            self.selfie.nb_upvotes = self.selfie.nb_upvotes + 1
                            self.selfie.user_vote_status = 1
                            
                            if self.selfie.nb_upvotes <= 1 {
                                self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
                            } else {
                                self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
                            }
                            
                            // Made Modifications on Timeline Cell
                            if self.selfieTimelineCell != nil {
                                self.selfieTimelineCell.approveButton.setImage(self.selfieTimelineCell.image_button_approved_selected, forState: .Normal)
                                self.selfieTimelineCell.numberDisapprovalLabel.text = self.numberRejectLabel.text
                                self.selfieTimelineCell.numberApprovalLabel.text = self.numberApprovalLabel.text
                                self.selfieTimelineCell.challengeStatusImage.image = self.challengeStatusImage.image
                                self.selfieTimelineCell.selfie = self.selfie
                            }
                        }

                    }
            }
        }
    }
    
    @IBAction func rejectButtonAction(sender: AnyObject) {
        // Perform the action only if the user hasn't rejected yet the Selfie
        if self.selfie.user_vote_status != 2 {
            
            // Selfies was initially approved by the user
            if self.selfie.user_vote_status == 1 {
                self.approveButton.setImage(UIImage(named: "approve_button.png"), forState: .Normal)
            }
            self.rejectButton.setImage(UIImage(named: "reject_select_button.png"), forState: .Normal)
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters:[String: String] = [
                "login": login,
                "auth_token": auth_token,
                "id": self.selfie.id.description
            ]
            
            request(.POST, ApiLink.selfie_reject, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        // Selfies was initially approved by the user
                        if self.selfie.user_vote_status == 1 {
                            self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
                        }
                        self.rejectButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        
                        if (json["success"].intValue == 0) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            // Selfies was initially approved by the user
                            if self.selfie.user_vote_status == 1 {
                                self.approveButton.setImage(UIImage(named: "approve_select_button.png"), forState: .Normal)
                            }
                            self.rejectButton.setImage(UIImage(named: "reject_button.png"), forState: .Normal)
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
                            
                            // Selfies was initially approved by the user
                            if self.selfie.user_vote_status == 1 {
                                self.selfie.nb_upvotes = self.selfie.nb_upvotes - 1
                                
                                // Made Modifications on Timeline Cell
                                if self.selfieTimelineCell != nil {
                                    self.selfieTimelineCell.approveButton.setImage(self.selfieTimelineCell.image_button_approved, forState: .Normal)
                                }
                                
                                if self.selfie.nb_upvotes <= 1 {
                                    self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
                                } else {
                                    self.numberApprovalLabel.text = self.selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
                                }
                            }
                            
                            self.selfie.nb_downvotes = self.selfie.nb_downvotes + 1
                            self.selfie.user_vote_status = 2
                            
                            if self.selfie.nb_downvotes <= 1 {
                                self.numberRejectLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
                            } else {
                                self.numberRejectLabel.text = self.selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
                            }
                            
                            // Made Modifications on Timeline Cell
                            if self.selfieTimelineCell != nil {
                                self.selfieTimelineCell.disapproveButton.setImage(self.selfieTimelineCell.image_button_rejected_selected, forState: .Normal)
                                self.selfieTimelineCell.numberDisapprovalLabel.text = self.numberRejectLabel.text
                                self.selfieTimelineCell.numberApprovalLabel.text = self.numberApprovalLabel.text
                                self.selfieTimelineCell.challengeStatusImage.image = self.challengeStatusImage.image
                                self.selfieTimelineCell.selfie = self.selfie
                            }
                        }
                    }
            }
        }
    }
    
    @IBAction func commentSendButton(sender: UIButton) {
        self.activityIndicator.startAnimating()
        
        var last_comment_id: Int = -1
        
        if self.comments_array.count > 0 {
            last_comment_id = self.comments_array.last!.id
        }
        
        let message = self.commentTextField.text!
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "selfie_id": self.selfie.id.description,
            "last_comment_id" : last_comment_id.description,
            "message": message
        ]
        
        // Hide Keyboard & clear Text in Textfield
        self.commentTextField.resignFirstResponder()
        self.commentTextField.text = ""
        
        request(.POST, ApiLink.create_comment, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    if json["meta"]["sucess"].boolValue == false {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("comment_empty", comment: "Comment cannot be empty"), controller: self)
                    } else {
                        if json["comments"].count != 0 {
                            for var i:Int = 0; i < json["comments"].count; i++ {
                                let comment = Comment.init(json: json["comments"][i])
                                self.comments_array.append(comment)
                            }
                            self.commentsListView.backgroundColor = MP_HEX_RGB("F7F7F7")
                            self.noCommentLabel.hidden = true
                            self.listCommentsTableView.reloadData()
                            
                            // Set the height of listCommentstableView dynamically based on the height of each cell
                            // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
                            var commentsTableView_newHeight: CGFloat = 0.0
                            for var i:Int = 0; i < self.comments_array.count; i++ {
                                commentsTableView_newHeight += self.listCommentsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)).size.height
                            }
                            self.listCommentsHeightConstraints.constant = commentsTableView_newHeight
                            
                            // scroll to the bottom of the View
                            let bottomOffset:CGPoint = CGPointMake(0, commentsTableView_newHeight + self.messageLabel.frame.height + self.selfieImageHeightConstraint.constant)
                            self.scrollView.setContentOffset(bottomOffset, animated: false)
                            
                            // Number of comments
                            self.selfie.nb_comments = self.selfie.nb_comments + 1
                            if self.selfie.nb_comments <= 1 {
                                self.numberCommentsLabel.text = self.selfie.nb_comments.description + NSLocalizedString("Comment", comment: "Comment")
                            } else {
                                self.numberCommentsLabel.text = self.selfie.nb_comments.description + NSLocalizedString("Comments", comment: "Comments")
                            }
                            
                            // Made Modifications on Timeline Cell
                            if self.selfieTimelineCell != nil {
                                self.selfieTimelineCell.numberCommentsButton.setTitle(self.numberCommentsLabel.text, forState: .Normal)
                                
                                self.selfieTimelineCell.commentUsernameLabel.text = login
                                self.selfieTimelineCell.commentUsernameLabel.sizeToFit()
                                
                                // Initiate comment Message Style
                                let comment_message_style = NSMutableParagraphStyle()
                                comment_message_style.headIndent = 0.0
                                comment_message_style.firstLineHeadIndent = CGFloat(self.selfieTimelineCell.commentUsernameLabel.frame.width + 5.0)
                                let comment_message_indent = NSMutableAttributedString(string: message)
                                
                                // Test if Last comment exists or not
                                if comment_message_indent.length != 0 {
                                    comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
                                    self.selfieTimelineCell.commentMessageLabel.attributedText = comment_message_indent
                                    self.selfieTimelineCell.commentMessageLabel.textColor = MP_HEX_RGB("000000")
                                    self.selfieTimelineCell.commentMessageLabel.sizeToFit()
                                }

                            }
                            

                        }
                    }
                }
                self.activityIndicator.stopAnimating()
        }
        
    }

    
    @IBAction func settingsButton(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        if self.is_administrator == true {
            let adminOneAction = UIAlertAction(title: "Block Selfie", style: UIAlertActionStyle.Destructive) { (_) in
                
                let parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "selfie_id": self.selfie.id.description
                ]
                
                // Add loadingIndicator pop-up
                let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                loadingActivityVC.view.tag = 21
                self.view.addSubview(loadingActivityVC.view)
                
                Alamofire.request(.POST, ApiLink.block_selfie, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        // Remove loadingIndicator pop-up
                        if let loadingActivityView = self.view.viewWithTag(21) {
                            loadingActivityView.removeFromSuperview()
                        }

                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        case .Success(let mydata):
                            //convert to SwiftJSON
                            let json = JSON(mydata)
                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("block_selfie", comment: "Block Selfie"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            } else {
                                // SUCCESS RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("block_selfie", comment: "Block Selfie"), message: NSLocalizedString("block_selfie_notification", comment: "Selfie has been blocked"), controller: self)
                            }
                        }
                }
                
            }
            let adminTwoAction = UIAlertAction(title: "Block User", style: UIAlertActionStyle.Destructive) { (_) in

                let parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "user_id": self.selfie.user.id.description
                ]
                
                // Add loadingIndicator pop-up
                let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                loadingActivityVC.view.tag = 21
                self.view.addSubview(loadingActivityVC.view)
                
                Alamofire.request(.POST, ApiLink.block_user, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        // Remove loadingIndicator pop-up
                        if let loadingActivityView = self.view.viewWithTag(21) {
                            loadingActivityView.removeFromSuperview()
                        }
                        
                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        case .Success(let mydata):
                            //convert to SwiftJSON
                            let json = JSON(mydata)
                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("block_user", comment: "Block User"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            } else {
                                // SUCCESS RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("block_user", comment: "Block User"), message: NSLocalizedString("block_user_notification", comment: "User has been blocked"), controller: self)
                            }
                        }
                }
            }
            let adminThreeAction = UIAlertAction(title: "Clear Flag", style: UIAlertActionStyle.Default) { (_) in

                let parameters = [
                    "login": login,
                    "auth_token": auth_token,
                    "selfie_id": self.selfie.id.description
                ]
                
                // Add loadingIndicator pop-up
                let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                loadingActivityVC.view.tag = 21
                self.view.addSubview(loadingActivityVC.view)
                
                Alamofire.request(.POST, ApiLink.clear_flag_selfie, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        // Remove loadingIndicator pop-up
                        if let loadingActivityView = self.view.viewWithTag(21) {
                            loadingActivityView.removeFromSuperview()
                        }
                        
                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        case .Success(let mydata):
                            //convert to SwiftJSON
                            let json = JSON(mydata)
                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("clear_flag", comment: "Clear Selfie Flag"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            } else {
                                // SUCCESS RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: NSLocalizedString("clear_flag", comment: "Clear Selfie Flag"), message: NSLocalizedString("clear_flag_notification", comment: "Flags have been cleared for this Selfie"), controller: self)
                            }
                        }
                }
            }
            
            alert.addAction(adminOneAction)
            alert.addAction(adminTwoAction)
            alert.addAction(adminThreeAction)
        }

        if self.selfie.user.username != login {
            let duelAction = UIAlertAction(title: NSLocalizedString("challenge_to_a_duel", comment: "Challenge to a duel"), style: UIAlertActionStyle.Default) { (_) in
                let createMatchupVC = CreateMatchupVC(nibName: "CreateMatchup", bundle: nil)
                createMatchupVC.opponent = self.selfie.user
                createMatchupVC.parentController = self
                createMatchupVC.hidesBottomBarWhenPushed = true
                self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                self.navigationController?.pushViewController(createMatchupVC, animated: true)
            }
            alert.addAction(duelAction)
        }
        
        
        let oneAction = UIAlertAction(title: NSLocalizedString("report_inappropriate_content", comment: "Report Inappropriate Content"), style: UIAlertActionStyle.Default) { (_) in
            
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            let auth_token = keychain["auth_token"]!
            
            let parameters = [
                "login": login,
                "auth_token": auth_token,
                "selfie_id": self.selfie.id.description
            ]
            
            // Add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            self.view.addSubview(loadingActivityVC.view)
            
            Alamofire.request(.POST, ApiLink.flag_selfie, parameters: parameters, encoding: .JSON)
                .responseJSON { _, _, result in
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    
                    switch result {
                    case .Failure(_, _):
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    case .Success(let mydata):
                        //convert to SwiftJSON
                        let json = JSON(mydata)
                        if (json["success"].intValue == 0) {
                            // ERROR RESPONSE FROM HTTP Request
                            GlobalFunctions().displayAlert(title: NSLocalizedString("report_selfie", comment: "Report Selfie"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        } else {
                            // SUCCESS RESPONSE FROM HTTP Request
                            GlobalFunctions().displayAlert(title: NSLocalizedString("report_selfie", comment: "Report Selfie"), message: NSLocalizedString("flag_as_inappropriate", comment: "Thank you. This selfie has been flagged as inappropriate and will be reviewed by an administrator."), controller: self)
                        }
                    }
            }
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }

        alert.addAction(oneAction)
        alert.addAction(twoAction)
        
        self.presentViewController(alert, animated: true, completion: nil)

    }

    
    @IBAction func viewAllCommentsButton(sender: AnyObject) {
        self.loadComments(true)
        self.viewAllCommentsButton.hidden = true
        self.viewAllCommentsButtonHeightConstraints.constant = 0.0
    }
    
    
}