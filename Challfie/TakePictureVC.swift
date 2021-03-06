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
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainAccess
import Armchair

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
    var challenge_selected: String = ""
    var matchup: Matchup!
    
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
        
        let navigationTitle : UILabel = UILabel(frame: CGRectMake(0.0, 0.0, 100.0, 40.0))
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
        self.searchBar.backgroundColor = MP_HEX_RGB("A7C7D1")
        self.searchBar.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.searchBar.layer.borderWidth = 1.0
        if let searchTextField = self.searchBar.valueForKey("searchField") as? UITextField {
            searchTextField.textColor = MP_HEX_RGB("FFFFFF")
            searchTextField.contentMode = UIViewContentMode.ScaleToFill
            let attributeDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search_a_challenge", comment: "Search a Challenge"), attributes: attributeDict)
        }
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        self.view.userInteractionEnabled = true
        
        // HiddenView to cover the UITableView to dismissKeyboard when tapgesture because tapgesture doesn't work on UITableView
        let tapGesture2 : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture2.addTarget(self, action: "dismissKeyboard")
        self.hiddenView.addGestureRecognizer(tapGesture)
        self.hiddenView.userInteractionEnabled = true
        self.hiddenView.hidden = true
        
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "ChallengeTVCell", bundle: nil)
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
        let leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        let rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)
        
        // set delegate
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self

        
        // Hide Challenges's Part if it's for a matchup
        if self.matchup != nil {
            self.pickChallengeLabel.hidden = true
            self.searchBar.hidden = true
            self.tableView.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)        
        // Remove the Keyboard Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "TakeSelfie Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
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
        
        if self.matchup == nil {
            // Load Challenges List only if it's not for a Matchup
            self.loadData()
        }
        
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
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token
        ]
        
        self.activityIndicator.startAnimating()        
        
        Alamofire.request(.POST, ApiLink.challenges_list, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    self.activityIndicator.stopAnimating()
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                                    
                    // Check if account is linked with Facebook
                    self.isFacebookLinked = json["meta"]["isFacebookLinked"].boolValue

                    if json["challenges"].count != 0 {
                        for var i:Int = 0; i < json["challenges"].count; i++ {
                            let book = Book.init(json: json["challenges"][i])
                            if json["challenges"][i]["challenges"].count != 0 {
                                var challenge_array_tmp: [Challenge] = []
                                for var j:Int = 0; j < json["challenges"][i]["challenges"].count; j++ {
                                    let challenge = Challenge.init(json: json["challenges"][i]["challenges"][j])
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
            if self.isFacebookLinked == false {
                let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
                fbLoginManager.logOut() //Otherwie can crash
                fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                    if (error != nil) {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        self.shareFacebookSwitch.on = false
                    } else {
                        fbLoginManager.logInWithPublishPermissions(["publish_actions"], handler: { (result, error) -> Void in
                            if (error != nil) {
                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                self.shareFacebookSwitch.on = false
                            } else {
                                if result.isCancelled == true {
                                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("facebook_published_not_permitted", comment: "You can't share your selfie on Facebook unless 'Publish Permission' has been approved."), controller: self)
                                    self.shareFacebookSwitch.on = false
                                } else {
                                    if result.grantedPermissions.contains("publish_actions") {
                                        self.linkAccWithFacebook()
                                    } else {
                                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("facebook_published_not_permitted", comment: "You can't share your selfie on Facebook unless 'Publish Permission' has been approved."), controller: self)
                                        self.shareFacebookSwitch.on = false
                                    }
                                }
                            }
                        })
                    }
                })
            } else {
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/permissions", parameters: nil)
                    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if ((error) != nil) {
                            // Process error
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            self.shareFacebookSwitch.on = false
                        } else {
                            let json = JSON(result)
                            var publish_actions_permission_granted = false
                            for var i = 0; i < json["data"].count; i++ {
                                if json["data"][i]["permission"] == "publish_actions" {
                                    if json["data"][i]["status"] == "granted" {
                                        publish_actions_permission_granted = true
                                        self.linkAccWithFacebook()
                                    }
                                }
                            }
                            if publish_actions_permission_granted == false {
                                let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
                                fbLoginManager.logOut() //Otherwie can crash
                                fbLoginManager.logInWithPublishPermissions(["publish_actions"], handler: { (result, error) -> Void in
                                    if (error != nil) {
                                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                        self.shareFacebookSwitch.on = false
                                    } else {
                                        if result.isCancelled == true {
                                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("facebook_published_not_permitted", comment: "You can't share your selfie on Facebook unless 'Publish Permission' has been approved."), controller: self)
                                            self.shareFacebookSwitch.on = false
                                        } else {
                                            if result.grantedPermissions.contains("publish_actions") {
                                                self.linkAccWithFacebook()
                                            } else {
                                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("facebook_published_not_permitted", comment: "You can't share your selfie on Facebook unless 'Publish Permission' has been approved."), controller: self)
                                                self.shareFacebookSwitch.on = false
                                            }
                                        }
                                    }
                                })
                            }
                            
                        }
                    })
                }
            }

        }
    }
    
    func linkAccWithFacebook()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email,first_name,last_name,locale"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                self.shareFacebookSwitch.on = false
            } else {
                let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let fbTokenExpiresAt = FBSDKAccessToken.currentAccessToken().expirationDate.timeIntervalSince1970
                let user_id = result.valueForKey("id") as! String
                let userProfileImage = "http://graph.facebook.com/\(user_id)/picture?type=large"
                var facebook_locale: String = "en_US"
                
                if result.valueForKey("locale") != nil {
                    facebook_locale = result.valueForKey("locale") as! String
                }
                
                let keychain = Keychain(service: "challfie.app.service")
                let login = keychain["login"]!
                let auth_token = keychain["auth_token"]!
                
                let parameters:[String: AnyObject] = [
                    "login": login,
                    "auth_token": auth_token,
                    "uid": user_id,
                    "firstname": result.valueForKey("first_name") as! String,
                    "lastname": result.valueForKey("last_name") as! String ,
                    "fbtoken": fbAccessToken,
                    "fbtoken_expires_at": fbTokenExpiresAt,
                    "fb_locale": facebook_locale,
                    "facebook_picture": userProfileImage
                ]
                
                Alamofire.request(.POST, ApiLink.facebook_link_account, parameters: parameters, encoding: .JSON)
                    .responseJSON { _, _, result in
                        switch result {
                        case .Failure(_, _):
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        case .Success(let mydata):
                            //convert to SwiftJSON
                            let json = JSON(mydata)
                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)
                                self.shareFacebookSwitch.on = false
                            } else {
                                self.isFacebookLinked = true
                            }
                        }
                        
                }
            }
        })
    }
    
    
    // Dismiss Searchbar Keyboard
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
        self.messageTextView.resignFirstResponder()
    }
    
    // Add selfie
    func createSelfie() {
        guard let _ = self.cameraView.image else {
            // Image Not Selected
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_image", comment: "Please select a picture."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return ;
        }

        // Check if a Challenge has been selected
        let selected_challenge: Challenge!
        var matchup_id: String = ""
        
        if self.matchup == nil {
            let path = self.tableView.indexPathForSelectedRow
            if (path == nil) {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_challenge", comment: "Please select a picture."), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return ;
            }
            
            // Retrieve selected challenge
            let selectedIndexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            selected_challenge = self.books_array[selectedIndexPath.section].challenges_array[selectedIndexPath.row]
        } else {
            selected_challenge = self.matchup.challenge
            matchup_id = self.matchup.id.description
        }
        
        
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
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "message": message,
            "is_private": is_private,
            "is_shared_fb": is_shared_fb,
            "challenge_id": selected_challenge.id.description,
            "matchup_id": matchup_id
        ]

        var timelineVC: TimelineVC!
        
        if self.matchup != nil {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as! HomeTBC
            
            if let viewControllers = homeTableViewController.viewControllers, navController = viewControllers[0] as? UINavigationController {
                timelineVC = (navController.viewControllers[0] as? TimelineVC)!
                self.presentViewController(homeTableViewController, animated: true, completion: nil)
            }
        } else {
            if let viewControllers = self.tabBarController?.viewControllers, navController = viewControllers[0] as? UINavigationController {
                timelineVC = (navController.viewControllers[0] as? TimelineVC)!
                self.tabBarController?.selectedIndex = 0
            }
        }
        
        if timelineVC != nil && timelineVC.view != nil {
            timelineVC.disableBackgroundRefresh = true
            timelineVC.navigationController?.navigationBarHidden = false
            
            
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
            
                
            Alamofire.upload(Method.POST, ApiLink.create_selfie,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: parameters["login"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "login")
                    multipartFormData.appendBodyPart(data: parameters["auth_token"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "auth_token")
                    multipartFormData.appendBodyPart(data: parameters["challenge_id"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "challenge_id")
                    multipartFormData.appendBodyPart(data: parameters["matchup_id"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "matchup_id")
                    multipartFormData.appendBodyPart(data: parameters["message"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "message")
                    multipartFormData.appendBodyPart(data: parameters["is_private"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_private")
                    multipartFormData.appendBodyPart(data: parameters["is_shared_fb"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_shared_fb")
                    multipartFormData.appendBodyPart(data: imageData!, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpg", mimeType: "image/jpeg")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { request, response, result in
                            if let loadingActivityView = self.view.viewWithTag(21) {
                                loadingActivityView.removeFromSuperview()
                            }
                            switch result {
                            case .Failure(_, _):
                                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                            case .Success(let data):
                                //convert to SwiftJSON
                                let json = JSON(data)

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
                                            
                                            timelineVC.tableViewTopConstraint.constant = 0.0
                                            timelineVC.refresh(false)
                                            timelineVC.navigationController?.navigationBarHidden = false
                                            
                                            if (timelineVC.timelineTableView.numberOfSections > 0) && (timelineVC.timelineTableView.numberOfRowsInSection(0) > 0) {
                                                timelineVC.timelineTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                                            }
                                            // Tells Armchair that this is a significant Event
                                            Armchair.userDidSignificantEvent(true)
                                    })
                                } else {
                                    timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                                    timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                                    timelineVC.retryButton.hidden = false
                                }
                            }
                        }
                    case .Failure( _):
                        timelineVC.uploadSelfieLabel.text = NSLocalizedString("upload_failed", comment: "Upload Failed :(")
                        timelineVC.uploadSelfieLabel.textColor = UIColor.redColor()
                        timelineVC.retryButton.hidden = false
                    }
                }
            )

        } else {
            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
        }
        
    }
    
    // Cancel taking a selfie
    func cancelTakePicture() {
        
        if self.matchup == nil {
            self.tabBarController?.selectedIndex = 0
        } else {
            //self.navigationController?.popViewControllerAnimated(true)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
        }
        
    }

    // MARK: - UISearchBarDelegate, UISearchDisplayDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array = self.challenges_array[i]
            }
        } else {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array.removeAll(keepCapacity: false)
                for var j = 0; j < self.challenges_array[i].count; j++
                {
                    let currentString = self.challenges_array[i][j].description as String
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
        if searchBar.text!.isEmpty {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array = self.challenges_array[i]
            }
        } else {
            for var i = 0; i < self.books_array.count; i++ {
                self.books_array[i].challenges_array.removeAll(keepCapacity: false)
                for var j = 0; j < self.challenges_array[i].count; j++
                {
                    let currentString = self.challenges_array[i][j].description as String
                    if currentString.lowercaseString.rangeOfString(searchBar.text!.lowercaseString) != nil {
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
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 20.0))
        headerView.backgroundColor = MP_HEX_RGB("30768A")
        let headerLabel = UILabel(frame: CGRectMake(15.0, 5.0, tableView.frame.width, 17.0))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        headerLabel.textColor = MP_HEX_RGB("FFFFFF")
        
        headerLabel.text = self.books_array[section].name
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        let cell: ChallengeTVCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! ChallengeTVCell
        
        let challenge: Challenge = self.books_array[indexPath.section].challenges_array[indexPath.row]
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
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // hide keyboard when tap outside the textfield
        self.view.endEditing(true)
    }
    
    
    
}
