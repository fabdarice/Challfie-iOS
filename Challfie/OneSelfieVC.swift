//
//  OneSelfie.swift
//  Challfie
//
//  Created by fcheng on 12/3/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class OneSelfieVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
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
    
    var original_footerViewBottomConstraints: CGFloat = 0.0
    var selfie: Selfie!
    var comments_array:[Comment] = []
    var to_bottom: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        var nib = UINib(nibName: "CommentTVCell", bundle: nil)
        self.listCommentsTableView.registerNib(nib, forCellReuseIdentifier: "CommentCell")
        
        // Set the height of a cell dynamically
        self.listCommentsTableView.rowHeight = UITableViewAutomaticDimension
        self.listCommentsTableView.estimatedRowHeight = 10.0
        
        // Retrive list of comments of the selected Selfie
        self.loadData()
        
        
        // Add constraints to force vertical scrolling of UIScrollView 
        // Basically set the leading and trailing of contentView to the View's one (instead of the scrollView)
        // Can't be done in the Interface Builder (.xib)
        var leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        var rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Remove the Keyboard Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
                
    }

    
    func loadSelfie() {
        
        // Init Selfie Information
        // USERNAME STYLE
        self.usernameLabel.text = selfie.user.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        var usernametapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        usernametapGesture.addTarget(self, action: "tapGestureToProfil")
        self.usernameLabel.addGestureRecognizer(usernametapGesture)
        self.usernameLabel.userInteractionEnabled = true
        
        // Selfie Level
        self.levelLabel.text = selfie.user.book_level
        
        // Challenge
        self.challengeLabel.text = selfie.challenge.description
        self.challengeLabel.textColor = MP_HEX_RGB("30BAE3")
        
        // Selfie Creation Date
        self.dateLabel.text = selfie.creation_date
        
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
        
        
        // Number of approval
        self.numberApprovalLabel.textColor = MP_HEX_RGB("30768A")
        if selfie.nb_upvotes <= 1 {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approves", comment: "Approves")
        } else {
            self.numberApprovalLabel.text = selfie.nb_upvotes.description + NSLocalizedString("Approve", comment: "Approve")
        }
        
        
        // Number of disapproval
        self.numberRejectLabel.textColor = MP_HEX_RGB("919191")
        if selfie.nb_downvotes <= 1 {
            self.numberRejectLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Rejects", comment: "Rejects")
        } else {
            self.numberRejectLabel.text = selfie.nb_downvotes.description + NSLocalizedString("Reject", comment: "Reject")
        }
        
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
            self.profilePicImage.layer.borderColor = MP_HEX_RGB("f3c378").CGColor;
        }
        if selfie.user.book_tier == 2 {
            self.profilePicImage.layer.borderColor = MP_HEX_RGB("77797a").CGColor;
        }
        if selfie.user.book_tier == 3 {
            self.profilePicImage.layer.borderColor = MP_HEX_RGB("fff94b").CGColor;
        }
        var profilPictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        profilPictapGesture.addTarget(self, action: "tapGestureToProfil")
        self.profilePicImage.addGestureRecognizer(profilPictapGesture)
        self.profilePicImage.userInteractionEnabled = true
        
        // Selfie Image
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)
        
        // Set Selfies Challenge Status
        if self.selfie.approval_status == 0 {
            self.challengeStatusImage.image = UIImage(named: "challenge_pending.png")
        } else if selfie.approval_status == 1 {
            self.challengeStatusImage.image = UIImage(named: "challenge_approve.png")
        } else if selfie.approval_status == 2 {
            self.challengeStatusImage.image = UIImage(named: "challenge_rejected")
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.footerViewBottomConstraints.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.footerViewBottomConstraints.constant = self.original_footerViewBottomConstraints
    }
    
    // Retrive list of comments of the selected Selfie
    func loadData() {
        // add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.contentView.addSubview(loadingActivityVC.view)
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "id": self.selfie.id.description
        ]
        
        request(.POST, ApiLink.show_selfie, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    var selfie: Selfie!
                    
                    if json["selfie"].count != 0 {
                        selfie = Selfie.init(json: json["selfie"])
                        var challenge = Challenge.init(json: json["selfie"]["challenge"])
                        var user = User.init(json: json["selfie"]["user"])
                        
                        selfie.challenge = challenge
                        selfie.user = user
                        self.selfie = selfie
                    }
                    
                    self.loadSelfie()
                    
                    request(.POST, ApiLink.selfie_list_comments, parameters: parameters, encoding: .JSON)
                        .responseJSON { (_, _, mydata2, _) in
                            // Remove loadingIndicator pop-up
                            if let loadingActivityView = self.contentView.viewWithTag(21) {
                                loadingActivityView.removeFromSuperview()
                            }
                            if (mydata == nil) {
                                var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else {
                                //Convert to SwiftJSON
                                var json2 = JSON_SWIFTY(mydata2!)
                                
                                if json2["selfies"].count != 0 {
                                    for var i:Int = 0; i < json2["selfies"].count; i++ {
                                        var comment = Comment.init(json: json2["selfies"][i])
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
                                        let bottomOffset:CGPoint = CGPointMake(0, commentsTableView_newHeight + self.messageLabel.frame.height)
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
                            //self.activityIndicator.stopAnimating()
                            
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
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "selfie_id": self.selfie.id.description,
            "last_comment_id" : last_comment_id.description,
            "message": self.commentTextField.text
        ]
        
        // Hide Keyboard & clear Text in Textfield
        self.commentTextField.resignFirstResponder()
        self.commentTextField.text = ""
        
        request(.POST, ApiLink.create_comment, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    if json["comments"].count != 0 {
                        for var i:Int = 0; i < json["comments"].count; i++ {
                            var comment = Comment.init(json: json["comments"][i])
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
                        let bottomOffset:CGPoint = CGPointMake(0, commentsTableView_newHeight + self.messageLabel.frame.height)
                        self.scrollView.setContentOffset(bottomOffset, animated: false)
                    }
                }
                self.activityIndicator.stopAnimating()
        }
        
    }
    
    // tap Gesture Functions
    func tapGestureToProfil() {
        // Push to ProfilVC of the selfie's user
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = self.selfie.user
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
            
    
    // UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CommentTVCell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as CommentTVCell
        var comment:Comment = self.comments_array[indexPath.row]
        
        cell.comment = comment
        cell.oneSelfieVC = self
        cell.loadItem()
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
    
    // UITextFieldDelegate Functions
    func textFieldShouldReturn(textField: UITextField!) -> Bool {        
        self.commentSendButton(self.sendCommentButton)
        textField.resignFirstResponder()
        return true
    }
        
}