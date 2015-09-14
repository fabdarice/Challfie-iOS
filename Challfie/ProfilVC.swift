//
//  ProfilVC.swift
//  Challfie
//
//  Created by fcheng on 12/25/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MobileCoreServices
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainAccess

class ProfilHeader : UICollectionReusableView {    
    @IBOutlet weak var headerMessageLabel: UILabel!
    @IBOutlet weak var headerMessageWidthConstraint: NSLayoutConstraint!
}

//UIImagePickerControllerDelegate
//UINavigationControllerDelegate

class ProfilVC : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIScrollViewDelegate, GKImagePickerDelegate {
    
    @IBOutlet weak var userInfosContainerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var blocksContainerView: UIView!
    @IBOutlet weak var selfiesNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var followersNumberLabel: UILabel!
    @IBOutlet weak var booksNumberLabel: UILabel!
    @IBOutlet weak var selfiesLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var booksLabel: UILabel!
    @IBOutlet weak var selfiesBlockView: UIView!
    @IBOutlet weak var followingBlockView: UIView!
    @IBOutlet weak var followersBlockView: UIView!
    @IBOutlet weak var booksBlockView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var selfiesCollectionView: UICollectionView!
    @IBOutlet weak var selfiesCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var user: User!
    var selfies_array: [Selfie] = []
    var is_blocked: Bool = false
    var page = 1
    var is_current_user: Bool = false
    let reuseIdentifier = "ProfilSelfieCell"
    var imagePicker: GKImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Hide tabBar
        self.tabBarController?.tabBar.hidden = true
        
        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        self.title = user.username
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        
        // Check if it's current_user
        if user.username == login {
            self.is_current_user = true
        }
        
        // Level Label
        self.levelLabel.text = self.user.book_level
        self.levelLabel.textColor = MP_HEX_RGB("FFFFFF")
        self.levelLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        
        // selfies/Following/Followers/Books Label color
        let blockLabelColor = MP_HEX_RGB("FFFFFF")
        self.selfiesLabel.textColor = blockLabelColor
        self.followersLabel.textColor = blockLabelColor
        self.followingLabel.textColor = blockLabelColor
        self.followingLabel.text = NSLocalizedString("Following", comment: "Following").uppercaseString
        self.followersLabel.text = NSLocalizedString("Followers", comment: "Followers").uppercaseString
        self.booksLabel.text = NSLocalizedString("approved", comment: "approved").uppercaseString
        self.booksLabel.textColor = blockLabelColor
        
        // number of selfies/Following/Followers/Books Label color
        let numberLabelcolor = MP_HEX_RGB("5BD9FC")
        self.selfiesNumberLabel.textColor = numberLabelcolor
        self.followingNumberLabel.textColor = numberLabelcolor
        self.followersNumberLabel.textColor = numberLabelcolor
        self.booksNumberLabel.textColor = numberLabelcolor
        
        // selfiesCollectionView background
        self.selfiesCollectionView.backgroundColor = UIColor.clearColor()
        
        // block background Image
        self.selfiesBlockView.backgroundColor = MP_HEX_RGB("104757")
        self.followingBlockView.backgroundColor = MP_HEX_RGB("104757")
        self.followersBlockView.backgroundColor = MP_HEX_RGB("104757")
        self.booksBlockView.backgroundColor = MP_HEX_RGB("104757")
        
        self.selfiesBlockView.layer.borderColor = MP_HEX_RGB("30768A").CGColor
        self.selfiesBlockView.layer.borderWidth = 1.0
        self.followingBlockView.layer.borderColor = MP_HEX_RGB("30768A").CGColor
        self.followingBlockView.layer.borderWidth = 1.0
        self.followersBlockView.layer.borderColor = MP_HEX_RGB("30768A").CGColor
        self.followersBlockView.layer.borderWidth = 1.0
        self.booksBlockView.layer.borderColor = MP_HEX_RGB("30768A").CGColor
        self.booksBlockView.layer.borderWidth = 1.0
        
        
        // User Profile Picture
        if self.user.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: self.user.show_profile_pic())!
            self.profileImage.hnk_setImageFromURL(profilePicURL)
        } else {
            self.profileImage.image = UIImage(named: "missing_user")
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 2.0;
        if self.user.book_tier == 1 {
            self.profileImage.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
        }
        if self.user.book_tier == 2 {
            self.profileImage.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
        }
        if self.user.book_tier == 3 {
            self.profileImage.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
        }
        
        if self.is_current_user == true {
            // set link to Search User xib
            var profilImagetapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
            profilImagetapGesture.addTarget(self, action: "tapGesturechangeProfilPic")
            self.profileImage.addGestureRecognizer(profilImagetapGesture)
            self.profileImage.userInteractionEnabled = true
        }
        
        // Initialize the loading Indicator
        self.loadingIndicator.tintColor = MP_HEX_RGB("FFFFFF")
        self.loadingIndicator.hidesWhenStopped = true
        
        // set datasource and delegate to this class
        self.selfiesCollectionView.dataSource = self
        self.selfiesCollectionView.delegate = self
        self.scrollView.delegate = self
        
        // Setting the Layout of UICollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width / 3 - 2, height: UIScreen.mainScreen().bounds.width / 3 - 2)
        
        // Display right button : Follow/Pending/Log Out
        if self.is_current_user == true {
            if self.user.administrator >= 4 {
                let log_out_button: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "log_out")
                let administrator_button: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_administrator"), style: UIBarButtonItemStyle.Plain, target: self, action: "btn_administrator")
                
                self.navigationItem.setRightBarButtonItems([log_out_button, administrator_button], animated: false)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "log_out")
            }
            
            self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
        } else {
            if self.user.is_following == false {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_follow"), style: UIBarButtonItemStyle.Plain, target: self, action: "follow_user")
                self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
                layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 60.0)
            } else {
                if self.user.is_pending == true {
                    var pendingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    pendingBtn.setImage(UIImage(named: "icon_pending"), forState: UIControlState.Normal)
                    pendingBtn.addTarget(self.navigationController, action: nil, forControlEvents:  UIControlEvents.TouchUpInside)
                    var pending_item = UIBarButtonItem(customView: pendingBtn)
                    self.navigationItem.rightBarButtonItem = pending_item
                    self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("f3c378")
                    layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 60.0)
                } else {
                    // is friend
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_is_friend"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("FFFFFF")
                }
            }
            
        }
        
        // assign the layout to UICollectionView
        self.selfiesCollectionView.collectionViewLayout = layout
        
        // Register the xib for the Custom CollectionViewCell
        var cell_nib = UINib(nibName: "ProfilSelfieCVCell", bundle: nil)
        self.selfiesCollectionView.registerNib(cell_nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Register the xib for the Header
        var header_nib = UINib(nibName: "ProfilHeader", bundle: nil)
        self.selfiesCollectionView.registerNib(header_nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profilHeader")
        
        
        // Add constraints to force vertical scrolling of UIScrollView
        // Basically set the leading and trailing of contentView to the View's one (instead of the scrollView)
        // Can't be done in the Interface Builder (.xib)
        var leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        var rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)
        
        // LoadData 
        if user.blocked == false {
            self.loadData()
        } else {
            layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 60.0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
   
        // Show Status Bar because GKImagePicker hides it
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    
    func loadData() {
        self.loadingIndicator.startAnimating()
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.user.id.description,
            "page": self.page.description
        ]
        
        request(.POST, ApiLink.user_selfies, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            var selfie = Selfie.init(json: json["users"][i])
                            var user = User.init(json: json["users"][i]["user"])
                            var challenge = Challenge.init(json: json["users"][i]["challenge"])
                            selfie.user = user
                            selfie.challenge = challenge
                            self.selfies_array.append(selfie)
                        }
                        self.page += 1
                        self.selfiesCollectionView.reloadData()
                    }

                    self.selfiesNumberLabel.text = json["meta"]["number_selfies"].stringValue
                    self.followingNumberLabel.text = json["meta"]["number_following"].stringValue
                    self.followersNumberLabel.text = json["meta"]["number_followers"].stringValue
                    self.booksNumberLabel.text = json["meta"]["number_approved"].stringValue
                    
                    var numberofRow = self.selfies_array.count / 3
                    if (self.selfies_array.count % 3) > 0 {
                        numberofRow += 1
                    }
                    let rowHeight = UIScreen.mainScreen().bounds.width / 3 - 1
                    
                    // 1.5 is the spacing between each lines
                    let collectionViewHeight = Double(numberofRow) * Double(rowHeight) + Double(numberofRow) * Double(1.5)
                    self.selfiesCollectionViewHeightConstraint.constant = CGFloat(collectionViewHeight)
                    
                    if (self.is_current_user == false) && ((self.user.is_following == false) || (self.user.is_pending == true)) {
                        self.selfiesCollectionViewHeightConstraint.constant += 60
                    }
                    
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    // MARK: - Follow User Button
    func follow_user() {
        var pendingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        pendingBtn.setImage(UIImage(named: "icon_pending"), forState: UIControlState.Normal)
        pendingBtn.addTarget(self.navigationController, action: nil, forControlEvents:  UIControlEvents.TouchUpInside)
        var pending_item = UIBarButtonItem(customView: pendingBtn)
        self.navigationItem.rightBarButtonItem = pending_item
        self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("f3c378")
        self.user.is_following = true
        self.user.is_pending = true
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters = [
            "login": login,
            "auth_token": auth_token,
            "user_id": self.user.id.description
        ]
        
        request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON).responseJSON { (_, _, mydata, _) in
            if (mydata == nil) {
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_follow"), style: UIBarButtonItemStyle.Plain, target: self, action: "follow_user")
                self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
                self.user.is_following = false
                self.user.is_pending = false
            } else {
                //Convert to SwiftJSON
                var json = JSON(mydata!)
                if (json["success"].intValue == 1) {
                    self.selfiesCollectionView.reloadData()
                    // Set so it will Refresh Following Tab when visiting
                    if let allTabViewControllers = self.tabBarController?.viewControllers,
                    navController:UINavigationController = allTabViewControllers[3] as? UINavigationController,
                    friendsVC: FriendVC = navController.viewControllers[0] as? FriendVC {
                        friendsVC.following_first_time = true
                        friendsVC.suggestions_first_time = true
                    }
                } else {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_follow"), style: UIBarButtonItemStyle.Plain, target: self, action: "follow_user")
                    self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
                    self.user.is_following = false
                    self.user.is_pending = false
                }
            }
        }
        
        
    }
    
    // MARK: - Log out Button
    func log_out() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: NSLocalizedString("Log_out", comment: "Log out"), style: UIAlertActionStyle.Destructive) { (_) in
            
            // Desactive Device so it can't receive push notifications
            var keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]
            let auth_token = keychain["auth_token"]
            
            if (login != nil && auth_token != nil) {
                let parameters:[String: AnyObject] = [
                    "login": login!,
                    "auth_token": auth_token!,
                    "type_device": "0",
                    "active": "0"
                ]
                // update deviceToken
                request(.POST, ApiLink.create_or_update_device, parameters: parameters, encoding: .JSON)
            }
            
            keychain["login"] = nil
            keychain["auth_token"] = nil
            var facebookManager = FBSDKLoginManager()
            facebookManager.logOut()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var loginViewController:LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
            
            // Desactive the Background Fetch Mode
           // UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
             //   UIApplicationBackgroundFetchIntervalNever)
            
            
            
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Administrator Page Button
    func btn_administrator() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: "Flag Content List", style: UIAlertActionStyle.Destructive) { (_) in
            // Push to FlagContentVC
            var flagContentVC = FlagContentVC(nibName: "FlagContent" , bundle: nil)
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Profil_tab", comment: "Profile"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(flagContentVC, animated: true)
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - UICollectionView Datasource and Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return numberofRow
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selfies_array.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var headerView: ProfilHeader!
        if kind == UICollectionElementKindSectionHeader {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "profilHeader", forIndexPath: indexPath) as! ProfilHeader
            headerView.headerMessageWidthConstraint.constant = 300.0
            if self.user.blocked == true {
                headerView.headerMessageLabel.text = NSLocalizedString("profil_blocked", comment: "Your account have been blocked by an administrator. Please contact us if this was a mistake.")
            } else {
                if self.user.is_following == false {
                    headerView.headerMessageLabel.text = NSLocalizedString("is_not_friend", comment: "Follow this user to see his selfie challenges..")
                } else {
                    if self.user.is_pending == true {
                        headerView.headerMessageLabel.text = NSLocalizedString("is_pending_request", comment: "Your following request have been sent. Waiting for approval..")
                    }
                }
            }
            
            headerView.headerMessageLabel.textColor = MP_HEX_RGB("FFFFFF")
            headerView.headerMessageLabel.numberOfLines = 0;
            headerView.headerMessageLabel.textAlignment = NSTextAlignment.Center
            headerView.headerMessageLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            headerView.headerMessageLabel.sizeToFit()
        }
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: ProfilSelfieCVCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! ProfilSelfieCVCell
        cell.backgroundColor = UIColor.blackColor()
        cell.selfie = selfies_array[indexPath.row]
        cell.profilVC = self
        cell.loadItem()
        // Configure the cell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
        
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((self.loadingIndicator.isAnimating() == false) && (self.user.blocked == false)) {
            // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
            let scrollViewHeight = scrollView.frame.size.height;
            let scrollContentSizeHeight = scrollView.contentSize.height;
            let scrollOffset = scrollView.contentOffset.y;
            
            if (scrollOffset + scrollViewHeight >= (scrollContentSizeHeight - 200)) {
                // Add Loading Indicator to footerView
                self.loadData()
            }
        }
    }
    
    // Show Pop-op to options to change profil pic
    func tapGesturechangeProfilPic() {
        var alert = UIAlertController(title: nil, message: NSLocalizedString("change_profil_pic", comment: "Change Your Profile Picture"), preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose From Your Gallery"), style: .Default) { (_) in self.showPhotoGallery() }
        let twoAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a Picture"), style: .Default) { (_) in self.showCamera()}
        let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(twoAction)
        alert.addAction(oneAction)
        alert.addAction(thirdAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - When the user is taking a picture from the device camera
    func showCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            // Add Background for status bar
            let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
            statusBarViewBackground?.hidden = true
            
            self.imagePicker = GKImagePicker()
            self.imagePicker.cropSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 30, UIScreen.mainScreen().bounds.width - 30)
            self.imagePicker.delegate = self
            
            //set the source type
            self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front        
            
            self.presentViewController(self.imagePicker.imagePickerController, animated: true, completion: nil)
        }
        else{
            GlobalFunctions().displayAlert(title: "No Camera Found", message: "No camera was found..", controller: self)
        }
    }
    
    // MARK: - When the user is selecting a picture from the gallery
    func showPhotoGallery() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        self.imagePicker = GKImagePicker()
        self.imagePicker.cropSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 30, UIScreen.mainScreen().bounds.width - 30)
        self.imagePicker.delegate = self
        
        //set the source type
        self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(self.imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - GKImagePicker Delegate Methods
    func imagePicker(imagePicker: GKImagePicker!, pickedImage image: UIImage!) {
        var imageToSave:UIImage!
        
        imageToSave = self.fixOrientation(image)
        if imagePicker.imagePickerController.sourceType == UIImagePickerControllerSourceType.Camera {            
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        }
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!

        let imageData = UIImageJPEGRepresentation(imageToSave, 0.9)
        
        Alamofire.upload(Method.POST, URLString: ApiLink.update_user,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: login.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "login")
                multipartFormData.appendBodyPart(data: auth_token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "auth_token")
                multipartFormData.appendBodyPart(data: imageData, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpg", mimeType: "image/jpeg")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, data, error in
                        let json = JSON(data!)
                        
                        self.user.profile_pic = json["user"]["avatar"].stringValue
                        
                        // User Profile Picture
                        if self.user.show_profile_pic() != "missing" {
                            let profilePicURL:NSURL = NSURL(string: self.user.show_profile_pic())!
                            self.profileImage.hnk_setImageFromURL(profilePicURL)
                        } else {
                            self.profileImage.image = UIImage(named: "missing_user")
                        }
                        
                        // Remove loadingIndicator pop-up
                        if let loadingActivityView = self.view.viewWithTag(21) {
                            loadingActivityView.removeFromSuperview()
                        }
                    }
                case .Failure(let encodingError):
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                }
            }
        )
        
        // Dismiss Camera Preview
        imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        
        // Add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        loadingActivityVC.has_navigationBar = true
        loadingActivityVC.has_tabBar = true
        self.contentView.addSubview(loadingActivityVC.view)
    }

    func imagePickerDidCancel(imagePicker: GKImagePicker!) {
        imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
        
    
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.drawInRect(rect)
        
        var normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }

    
}