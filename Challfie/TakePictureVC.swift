//
//  TakePictureVC.swift
//  Challfie
//
//  Created by fcheng on 1/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import MobileCoreServices
import Alamofire
import SwiftyJSON

//UIImagePickerControllerDelegate
//UINavigationControllerDelegate
class TakePictureVC : UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var pickChallengeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var shareFacebookSwitch: UISwitch!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var facebookShareLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var message_presence: Bool = false
    var books_array : [Book] = []
    var challenges_array: [[Challenge]] = []
    var imageToSave: UIImage!
    var isFacebookLinked: Bool = false
    var isPublishPermissionEnabled: Bool = false
    var challenge_selected: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        
        // add NavigationItem
        let backItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "cancelTakePicture")
        let doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "createSelfie")
        backItem.tintColor = MP_HEX_RGB("FFFFFF")
        doneItem.tintColor = MP_HEX_RGB("5BD9FC")
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.rightBarButtonItem = doneItem
        
        var navigationTitle : UILabel = UILabel(frame: CGRectMake(0.0, 0.0, 100.0, 40.0))
        navigationTitle.font = UIFont(name: "HelveticaNeue", size: 16.0)
        navigationTitle.text = NSLocalizedString("post_a_challfie", comment: "Post a Challfie")
        navigationTitle.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = navigationTitle
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("e9eaed")
        self.separatorView.backgroundColor = MP_HEX_RGB("F0F0F0")
        
        
        // UIView That contains the Image
        self.cameraView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.cameraView.layer.borderWidth = 1.0
        self.cameraView.contentMode = UIViewContentMode.ScaleAspectFit
        
        // UIView that contains Settings
        self.settingView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.settingView.layer.borderWidth = 1.0
        
        self.settingsLabel.textColor = MP_HEX_RGB("1A596B")
        self.settingsLabel.text = NSLocalizedString("settings", comment: "Settings")
        self.pickChallengeLabel.textColor = MP_HEX_RGB("1A596B")
        self.pickChallengeLabel.text = NSLocalizedString("pick_a_challenge", comment: "Pick a Challenge")
        
        self.privacyLabel.text = NSLocalizedString("privacy_text", comment: "Only visible to your followers")
        self.facebookShareLabel.text = NSLocalizedString("shareFacebook_text", comment: "Share on Facebook")
        
        
        // UITextView Settings
        self.messageTextView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.messageTextView.layer.borderWidth = 1.0
        self.messageTextView.delegate = self
        self.messageTextView.text = NSLocalizedString("add_message", comment: "Add a message..")
        self.messageTextView.textColor = UIColor.lightGrayColor()
        self.messageTextView.font = UIFont.italicSystemFontOfSize(13.0)
        self.messageTextView.editable = true
        
        // set searchBar textfield backgroun to white
        self.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchBarTextFieldBackground"), forState: UIControlState.Normal)
        self.searchBar.backgroundColor = MP_HEX_RGB("A7C7D1")
        self.searchBar.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.searchBar.layer.borderWidth = 1.0
        self.searchBar.placeholder = NSLocalizedString("search_a_challenge", comment: "Search a Challenge")
        
        var tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        self.view.userInteractionEnabled = true
        
        // HiddenView to cover the UITableView to dismissKeyboard when tapgesture because tapgesture doesn't work on UITableView
        var tapGesture2 : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture2.addTarget(self, action: "dismissKeyboard")
        self.hiddenView.addGestureRecognizer(tapGesture)
        self.hiddenView.userInteractionEnabled = true
        self.hiddenView.hidden = true
        
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "ChallengeTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ChallengeCell")
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.separatorColor = MP_HEX_RGB("C4C4C4")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 10.0
       
        // set action that is being used when the switch is ON
        self.shareFacebookSwitch.addTarget(self, action: "addFacebookLink", forControlEvents: UIControlEvents.ValueChanged)
        
        //activityIndicator
        //self.activityIndicator.hidesWhenStopped = true
        
        
        // Add constraints to force vertical scrolling of UIScrollView
        // Basically set the leading and trailing of contentView to the View's one (instead of the scrollView)
        // Can't be done in the Interface Builder (.xib)
        var leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        var rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)
        
        // set delegate
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)        
        // Remove the Keyboard Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Add Notification for when the Keyboard pop up  and when it is dismissed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name:UIKeyboardDidHideNotification, object: nil)
        
        // Show Status Bar because GKImagePicker hides it
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        self.cameraView.image = self.imageToSave
        self.shareFacebookSwitch.on = false
        self.message_presence = false
        self.messageTextView.text = NSLocalizedString("add_message", comment: "Add a message..")
        self.messageTextView.textColor = UIColor.lightGrayColor()
        self.messageTextView.font = UIFont.italicSystemFontOfSize(13.0)
        
        self.searchBar.text = self.challenge_selected
        
        self.books_array.removeAll(keepCapacity: false)
        self.challenges_array.removeAll(keepCapacity: false)
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardDidShow(notification: NSNotification) {
        self.hiddenView.hidden = false
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.hiddenView.hidden = true
    }
    
    
    // MARK: - Action Methods
    
    // load list of all challenges
    func loadData() {
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount as String)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData as String)!
        ]
        
        self.activityIndicator.startAnimating()
        
        
        request(.POST, ApiLink.challenges_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    self.activityIndicator.stopAnimating()
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    // Check if account is linked with Facebook
                    self.isFacebookLinked = json["meta"]["isFacebookLinked"].boolValue
                    
                    // Check if Publish Action has already been authorized
                    self.isPublishPermissionEnabled = json["meta"]["isPublishPermissionEnabled"].boolValue
                    
                    if json["challenges"].count != 0 {
                        for var i:Int = 0; i < json["challenges"].count; i++ {
                            var book = Book.init(json: json["challenges"][i])
                            if json["challenges"][i]["challenges"].count != 0 {
                                var challenge_array_tmp: [Challenge] = []
                                for var j:Int = 0; j < json["challenges"][i]["challenges"].count; j++ {
                                    var challenge = Challenge.init(json: json["challenges"][i]["challenges"][j])
                                    book.challenges_array.append(challenge)
                                    challenge_array_tmp.append(challenge)
                                }
                                self.challenges_array
                                    .append(challenge_array_tmp)
                            }
                            self.books_array.append(book)
                        }

                        
                        self.tableView.reloadData()
                        
                        // Set the height of tableView dynamically based on the height of each cell
                        // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
                        var tableView_newHeight: CGFloat = 0.0
                        for var i:Int = 0; i < self.books_array.count; i++ {
                            // Add Header Height
                            if let headerHeight = self.tableView.delegate?.tableView!(self.tableView, heightForHeaderInSection: i) {
                                tableView_newHeight += headerHeight
                            }
                            
                            for var j:Int = 0; j < self.books_array[i].challenges_array.count; j++ {
                                tableView_newHeight += self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)).size.height
                            }
                        }
                        self.tableViewHeightConstraint.constant = tableView_newHeight
                        self.activityIndicator.stopAnimating()
                        
                        if self.challenge_selected != "" {
                            self.searchBarSearchButtonClicked(self.searchBar)
                        }

                    }
                }
        }
    }
    
    // Function when Share Facebook Switch is ON
    func addFacebookLink() {
        if self.shareFacebookSwitch.on == true {
            if self.isFacebookLinked == false || self.isPublishPermissionEnabled == false {
                if self.isPublishPermissionEnabled == false && self.isFacebookLinked == true {
                    FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: {
                        (session:FBSession!, state:FBSessionState, error:NSError!) in

                        if FBSession.activeSession().isOpen {
                            if contains(FBSession.activeSession().permissions  as! [String], "publish_actions") == false {
                                FBSession.activeSession().requestNewPublishPermissions(["publish_actions"], defaultAudience: FBSessionDefaultAudience.Friends, completionHandler: {(session:FBSession!, error:NSError!) in
                                    if (error != nil) {
                                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                        self.shareFacebookSwitch.on = false
                                    } else {
                                        self.updateFacebookPublishPermissions()
                                    }
                                })
                            } else {
                                self.updateFacebookPublishPermissions()
                            }
                        }
                    })
                } else {
                    FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends", "publish_actions"], allowLoginUI: true, completionHandler: {
                        (session:FBSession!, state:FBSessionState, error:NSError!) in
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                        appDelegate.sessionStateChanged(session, state: state, error: error)
                        if FBSession.activeSession().isOpen {
                            FBRequestConnection.startForMeWithCompletionHandler({ (connection, user, error) -> Void in
                                if (error != nil) {
                                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                    self.shareFacebookSwitch.on = false
                                } else {
                                    let user_uid: String = user.objectForKey("id") as! String
                                    let user_lastname = user.objectForKey("last_name") as! String
                                    let user_firstname = user.objectForKey("first_name") as! String
                                    let user_locale = user.objectForKey("locale") as! String
                                    
                                    let fbAccessToken = FBSession.activeSession().accessTokenData.accessToken
                                    let fbTokenExpiresAt = FBSession.activeSession().accessTokenData.expirationDate.timeIntervalSince1970
                                    
                                    let parameters:[String: AnyObject] = [
                                        "login": KeychainWrapper.stringForKey(kSecAttrAccount as String)!,
                                        "auth_token": KeychainWrapper.stringForKey(kSecValueData as String)!,
                                        "uid": user_uid,
                                        "firstname": user_firstname,
                                        "lastname": user_lastname,
                                        "fbtoken": fbAccessToken,
                                        "fbtoken_expires_at": fbTokenExpiresAt,
                                        "fb_locale": user_locale,
                                        "isPublishPermissionEnabled" : true
                                    ]
                                    
                                    request(.POST, ApiLink.facebook_link_account, parameters: parameters, encoding: .JSON)
                                        .responseJSON { (_, _, mydata, _) in
                                            if (mydata == nil) {
                                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                                self.shareFacebookSwitch.on = false
                                            } else {
                                                //convert to SwiftJSON
                                                let json = JSON(mydata!)
                                                
                                                if (json["success"].intValue == 0) {
                                                    // ERROR RESPONSE FROM HTTP Request
                                                    GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)                                                                                                        
                                                    self.shareFacebookSwitch.on = false                                                                                                        
                                                } else {
                                                    self.isFacebookLinked = true
                                                    self.isPublishPermissionEnabled = true
                                                }
                                            }
                                    }
                                    
                                }
                                
                            })
                        }
                    })
                }
            }
        }
    }
    
    func updateFacebookPublishPermissions () {
        let parameters:[String: AnyObject] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount as String)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData as String)!,
            "isPublishPermissionEnabled": true
        ]
        
        request(.POST, ApiLink.update_facebook_permission, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    self.shareFacebookSwitch.on = false
                } else {
                    //convert to SwiftJSON
                    let json = JSON(mydata!)
                    
                    if (json["success"].intValue == 0) {
                        // ERROR RESPONSE FROM HTTP Request
                        GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)
                        self.shareFacebookSwitch.on = false
                    } else {
                        self.isFacebookLinked = true
                        self.isPublishPermissionEnabled = true
                    }
                }
        }
    }
    
    
    
    // Dismiss Searchbar Keyboard
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
        self.messageTextView.resignFirstResponder()
    }
    
    // Add selfie
    func createSelfie() {
        
        // Check if Selfie Image Exists or not
        if let cameraImage = self.cameraView.image {
            // Image Exists
        } else {
            // Image Not Selected
            var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_image", comment: "Please select a picture."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return ;
        }
        
        // Check if a Challenge has been selected
        let path = self.tableView.indexPathForSelectedRow()
        if (path == nil) {
            var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_challenge", comment: "Please select a picture."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return ;
        }
        
        // Retrieve selected challenge
        let selectedIndexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
        var selected_challenge: Challenge = self.books_array[selectedIndexPath.section].challenges_array[selectedIndexPath.row]
        
        let imageData = UIImageJPEGRepresentation(self.imageToSave, 0.9)

        var is_private: String = ""
        if self.privacySwitch.on {
            is_private = "1"
        } else {
            is_private = "0"
        }
        
        var is_shared_fb: String = ""
        if self.shareFacebookSwitch.on {
            is_shared_fb = "1"
        } else {
            is_shared_fb = "0"
        }
        
        var message: String = ""
        if self.message_presence == true {
            message = self.messageTextView.text
        }
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount as String)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData as String)!,
            "message": message,
            "is_private": is_private,
            "is_shared_fb": is_shared_fb,
            "challenge_id": selected_challenge.id.description
        ]
     
        // Switch to Timeline Tab
        if let viewControllers = self.tabBarController?.viewControllers,
        navController = viewControllers[0] as? UINavigationController,
        timelineVC: TimelineVC = navController.viewControllers[0] as? TimelineVC {
            
            if timelineVC.view != nil {
                timelineVC.uploadSelfieView.hidden = false
                // Background
                timelineVC.uploadSelfieView.backgroundColor = MP_HEX_RGB("FFFFFF")
                // Border color
                timelineVC.uploadSelfieView.layer.borderColor = MP_HEX_RGB("85BBCC").CGColor
                timelineVC.uploadSelfieView.layer.borderWidth = 1.0
                timelineVC.uploadSelfieImage.image = self.imageToSave
                timelineVC.tableViewTopConstraint.constant = 50.0
                timelineVC.uploadSelfieLabel.text = NSLocalizedString("uploading_selfie", comment: "Uploading Selfie...")
                timelineVC.uploadSelfieLabel.textColor = UIColor.blackColor()
                timelineVC.retryButton.hidden = true
                timelineVC.progressData = 0.1
                timelineVC.progressView.progress = 0.1
            }
            
            Alamofire.upload(Method.POST, URLString: ApiLink.create_selfie,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: parameters["login"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "login")
                    multipartFormData.appendBodyPart(data: parameters["auth_token"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "auth_token")
                    multipartFormData.appendBodyPart(data: parameters["challenge_id"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "challenge_id")
                    multipartFormData.appendBodyPart(data: parameters["message"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "message")
                    multipartFormData.appendBodyPart(data: parameters["is_private"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_private")
                    multipartFormData.appendBodyPart(data: parameters["is_shared_fb"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_shared_fb")
                    multipartFormData.appendBodyPart(data: imageData, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpg", mimeType: "image/jpeg")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { request, response, data, error in
                            
                            //convert to SwiftJSON
                            let json = JSON(data!)

                            // Check success response
                            if (json["success"].intValue == 1) {
                                self.cameraView.image = nil
                                self.messageTextView.text = NSLocalizedString("add_message", comment: "Add a message..")
                                self.messageTextView.textColor = UIColor.lightGrayColor()
                                self.messageTextView.font = UIFont.italicSystemFontOfSize(13.0)
                                self.message_presence = false
                                if timelineVC.view != nil {
                                    timelineVC.progressView.progress = 1.0
                                    timelineVC.progressData = 1.0
                                    timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_completed", comment: "Upload Completed")
                                }
                                
                                UIView.transitionWithView(timelineVC.uploadSelfieView, duration: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    timelineVC.uploadSelfieView.hidden = true
                                    }, completion: { (finished: Bool) -> Void in
                                        if timelineVC.view != nil {
                                            timelineVC.tableViewTopConstraint.constant = 0.0
                                            timelineVC.refresh(actionFromInit: false)
                                        }
                                })
                            } else {
                                if timelineVC.view != nil {
                                    timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                                    timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                                    timelineVC.retryButton.hidden = false
                                }
                            }
                        }
                    case .Failure(let encodingError):
                        if timelineVC.view != nil {
                            timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                            timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                            timelineVC.retryButton.hidden = false
                        }
                    }
                }
            )


            /*
            var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            manager.POST(ApiLink.create_selfie, parameters: parameters, constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(imageData, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpeg", mimeType: "image/jpeg")
                }, success: { (operation: AFHTTPRequestOperation!, responseObject) -> Void in
                    //convert to SwiftJSON
                    let json = JSON_SWIFTY(responseObject!)
                    
                    // Check success response
                    if (json["success"].intValue == 1) {
                        self.cameraView.image = nil
                        self.messageTextView.text = NSLocalizedString("add_message", comment: "Add a message..")
                        self.messageTextView.textColor = UIColor.lightGrayColor()
                        self.messageTextView.font = UIFont.italicSystemFontOfSize(13.0)
                        self.message_presence = false
                        if timelineVC.view != nil {
                            timelineVC.progressView.progress = 1.0
                            timelineVC.progressData = 1.0
                            timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_completed", comment: "Upload Completed")
                        }
                        
                        UIView.transitionWithView(timelineVC.uploadSelfieView, duration: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                timelineVC.uploadSelfieView.hidden = true
                            }, completion: { (finished: Bool) -> Void in
                                if timelineVC.view != nil {
                                    timelineVC.tableViewTopConstraint.constant = 0.0
                                    timelineVC.refresh(actionFromInit: false)
                                }
                        })
                    } else {
                        if timelineVC.view != nil {
                            timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                            timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                            timelineVC.retryButton.hidden = false
                        }
                    }
                }, failure: { (operation: AFHTTPRequestOperation!, error) -> Void in
                    if timelineVC.view != nil {
                        timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                        timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                        timelineVC.retryButton.hidden = false
                    }
            })
            */

            if timelineVC.view != nil {
                timelineVC.disableBackgroundRefresh = true
            }
            self.tabBarController?.selectedIndex = 0
        }
        
    }
    
    // Cancel taking a selfie
    func cancelTakePicture() {
        self.tabBarController?.selectedIndex = 0
    }
    
    

    // MARK: - UISearchBarDelegate, UISearchDisplayDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text.isEmpty {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array = self.challenges_array[i]
            }
        } else {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array.removeAll(keepCapacity: false)
                for var j = 0; j < self.challenges_array[i].count; j++
                {
                    var currentString = self.challenges_array[i][j].description as String
                    if currentString.lowercaseString.rangeOfString(searchText.lowercaseString) != nil {
                        self.books_array[i].challenges_array.append(self.challenges_array[i][j])
                    }
                }
            }
        }
        self.tableView.reloadData()
        let offset:CGPoint = CGPointMake(0, 205)
        self.scrollView.setContentOffset(offset, animated: true)
        
        // Set the height of tableView dynamically based on the height of each cell
        // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
        var tableView_newHeight: CGFloat = 0.0
        for var i:Int = 0; i < self.books_array.count; i++ {
            // Add Header Height
            if let headerHeight = self.tableView.delegate?.tableView!(self.tableView, heightForHeaderInSection: i) {
                tableView_newHeight += headerHeight
            }
            
            for var j:Int = 0; j < self.books_array[i].challenges_array.count; j++ {
                tableView_newHeight += self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)).size.height
            }
        }
        if tableView_newHeight < 400.0 {
            tableView_newHeight = 400.0
        }
        

        self.tableViewHeightConstraint.constant = tableView_newHeight
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // scroll to the SearchBar
        let offset:CGPoint = CGPointMake(0, 205)
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    // Dismiss Keyboard when Search Button has been clicked on
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        if searchBar.text.isEmpty {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array = self.challenges_array[i]
            }
        } else {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array.removeAll(keepCapacity: false)
                for var j = 0; j < self.challenges_array[i].count; j++
                {
                    var currentString = self.challenges_array[i][j].description as String
                    if currentString.lowercaseString.rangeOfString(searchBar.text.lowercaseString) != nil {
                        self.books_array[i].challenges_array.append(self.challenges_array[i][j])
                    }
                }
            }
        }
        self.tableView.reloadData()
        
        var indexPath : NSIndexPath!
        
        // Set the height of tableView dynamically based on the height of each cell
        // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
        var tableView_newHeight: CGFloat = 0.0
        for var i:Int = 0; i < self.books_array.count; i++ {
            // Add Header Height
            if let headerHeight = self.tableView.delegate?.tableView!(self.tableView, heightForHeaderInSection: i) {
                tableView_newHeight += headerHeight
            }
            
            for var j:Int = 0; j < self.books_array[i].challenges_array.count; j++ {
                indexPath = NSIndexPath(forRow: j, inSection: i)
                tableView_newHeight += self.tableView.rectForRowAtIndexPath(indexPath).size.height
            }
        }
        if tableView_newHeight < 400.0 {
            tableView_newHeight = 400.0
        }
        
        self.tableViewHeightConstraint.constant = tableView_newHeight
        
        if self.challenge_selected != "" {
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }        
    
    //MARK: - UITABLEVIEW DELEGATE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.books_array.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books_array[section].challenges_array.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Remove the header for "Following" and "Followers" Tab
        if self.books_array[section].challenges_array.count == 0 {
            return 0.0
        } else {
            return 25.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 20.0))
        headerView.backgroundColor = MP_HEX_RGB("30768A")
        var headerLabel = UILabel(frame: CGRectMake(15.0, 5.0, tableView.frame.width, 17.0))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        headerLabel.textColor = MP_HEX_RGB("FFFFFF")
        
        headerLabel.text = self.books_array[section].name
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var cell: ChallengeTVCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! ChallengeTVCell
        
        var challenge: Challenge = self.books_array[indexPath.section].challenges_array[indexPath.row]
        cell.challenge = challenge
        cell.loadItemForTakePicture()
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = MP_HEX_RGB("FAE0B1")
    }
    
    
    //MARK: - UITextView Delegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if self.message_presence == false {
            self.messageTextView.text = ""
            self.messageTextView.textColor = UIColor.blackColor()
            self.messageTextView.font = UIFont.systemFontOfSize(13.0)
            self.message_presence = true
        }
        return true
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // hide keyboard when click on the "return" key
        if(text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    // UITextFieldDelegate Delegate
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // hide keyboard when tap outside the textfield
        self.view.endEditing(true)
    }
    
    
    
}
