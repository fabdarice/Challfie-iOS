//
//  ProfilVC.swift
//  Challfie
//
//  Created by fcheng on 12/25/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire
import MobileCoreServices

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
    var page = 1
    var is_current_user: Bool = false
    let reuseIdentifier = "ProfilSelfieCell"
    var imagePicker: GKImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        self.title = user.username
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chinacat", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
        // Check if it's current_user
        if user.username == KeychainWrapper.stringForKey(kSecAttrAccount)! {
            self.is_current_user = true
        }
        
        // Level Label
        self.levelLabel.text = self.user.book_level
        self.levelLabel.textColor = MP_HEX_RGB("FFFFFF")
        self.levelLabel.font = UIFont(name: "Chinacat", size: 14.0)
        
        // selfies/Following/Followers/Books Label color
        let blockLabelColor = MP_HEX_RGB("FFFFFF")
        self.selfiesLabel.textColor = blockLabelColor
        self.followersLabel.textColor = blockLabelColor
        self.followingLabel.textColor = blockLabelColor
        self.followingLabel.text = NSLocalizedString("Following", comment: "Following").uppercaseString
        self.followersLabel.text = NSLocalizedString("Followers", comment: "Followers").uppercaseString
        self.booksLabel.text = NSLocalizedString("Books", comment: "Books").uppercaseString
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
            self.profileImage.layer.borderColor = MP_HEX_RGB("f3c378").CGColor;
        }
        if self.user.book_tier == 2 {
            self.profileImage.layer.borderColor = MP_HEX_RGB("77797a").CGColor;
        }
        if self.user.book_tier == 3 {
            self.profileImage.layer.borderColor = MP_HEX_RGB("fff94b").CGColor;
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "log_out")
            self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
        } else {
            if self.user.is_following == false {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_follow"), style: UIBarButtonItemStyle.Plain, target: self, action: "follow_user")
                self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("5BD9FC")
                layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 60.0)
            } else {
                if self.user.is_pending == true {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_pending"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("f3c378")
                    layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 60.0)
                } else {
                    // is friend
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_is_friend"), style: UIBarButtonItemStyle.Bordered, target: self, action: nil)
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
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
   
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
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "user_id": self.user.id.description,
            "page": self.page.description
        ]
        
        request(.POST, ApiLink.user_selfies, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
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
                        //self.col.reloadData()
                        self.selfiesCollectionView.reloadData()
                    }
                    

                    self.selfiesNumberLabel.text = json["meta"]["number_selfies"].stringValue
                    self.followingNumberLabel.text = json["meta"]["number_following"].stringValue
                    self.followersNumberLabel.text = json["meta"]["number_followers"].stringValue
                    self.booksNumberLabel.text = json["meta"]["number_books"].stringValue
                    
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
    
    
    func follow_user() {
        let parameters = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "user_id": self.user.id.description
        ]
        
        request(.POST, ApiLink.follow, parameters: parameters, encoding: .JSON)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_pending"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = MP_HEX_RGB("f3c378")
        self.user.is_following = true
        self.user.is_pending = true
        self.selfiesCollectionView.reloadData()
    }
    
    func log_out() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: NSLocalizedString("Log_out", comment: "Log out"), style: UIAlertActionStyle.Destructive) { (_) in
            KeychainWrapper.removeObjectForKey(kSecAttrAccount)
            KeychainWrapper.removeObjectForKey(kSecValueData)
            if let facebookSession = FBSession.activeSession() {
                facebookSession.closeAndClearTokenInformation()
                facebookSession.close()
                FBSession.setActiveSession(nil)
            }
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var loginViewController:LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as LoginVC
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // UICollectionView Datasource and Delegate
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
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "profilHeader", forIndexPath: indexPath) as ProfilHeader
            headerView.headerMessageWidthConstraint.constant = 300.0
            if self.user.is_following == false {
                headerView.headerMessageLabel.text = NSLocalizedString("is_not_friend", comment: "Follow this user to see his selfie challenges..")
            } else {
                if self.user.is_pending == true {
                    headerView.headerMessageLabel.text = NSLocalizedString("is_pending_request", comment: "Your following request have been sent. Waiting for approval..")
                }
            }
            headerView.headerMessageLabel.textColor = MP_HEX_RGB("FFFFFF")
            headerView.headerMessageLabel.numberOfLines = 0;
            headerView.headerMessageLabel.textAlignment = NSTextAlignment.Center
            headerView.headerMessageLabel.font = UIFont(name: "Chinacat", size: 16.0)
            headerView.headerMessageLabel.sizeToFit()
        }
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: ProfilSelfieCVCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as ProfilSelfieCVCell
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
        // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset + scrollViewHeight >= (scrollContentSizeHeight - 20)) {
            // Add Loading Indicator to footerView
            self.loadData()
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
    
    
    // When the user is taking a picture from the device camera
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
            var alert = UIAlertController(title: "No Camera Found", message: "No camera was found..", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // When the user is selecting a picture from the gallery
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
        
        /*var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)*/
    }
    
    // MARK: - GKImagePicker Delegate Methods
    func imagePicker(imagePicker: GKImagePicker!, pickedImage image: UIImage!) {
        var imageToSave:UIImage!
        
        imageToSave = self.fixOrientation(image)
        if imagePicker.imagePickerController.sourceType == UIImagePickerControllerSourceType.Camera {            
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        }
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        
        let imageData = UIImageJPEGRepresentation(imageToSave, 0.6)            
        
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.POST(ApiLink.update_user, parameters: parameters, constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
            formData.appendPartWithFileData(imageData, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpeg", mimeType: "image/jpeg")
            }, success: { (operation: AFHTTPRequestOperation!, responseObject) -> Void in
                //convert to SwiftJSON
                let json = JSON_SWIFTY(responseObject!)
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
            }, failure: { (operation: AFHTTPRequestOperation!, error) -> Void in
                
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                
                var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        })
        
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
    
    
    /*
    // MARK: - UIImagePicker Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary!) {
        let mediaType = info[UIImagePickerControllerMediaType] as String
        var originalImage:UIImage?, editedImage:UIImage?, imageToSave:UIImage?
        
        // Handle a still image capture
        let compResult:CFComparisonResult = CFStringCompare(mediaType as NSString!, kUTTypeImage, CFStringCompareFlags.CompareCaseInsensitive)
        if ( compResult == CFComparisonResult.CompareEqualTo ) {
            originalImage = info[UIImagePickerControllerOriginalImage] as UIImage?
            
            if ( editedImage != nil ) {
                imageToSave = editedImage
            } else {
                imageToSave = originalImage
            }
            
            imageToSave = self.fixOrientation(imageToSave!)
            let imageData = UIImageJPEGRepresentation(imageToSave, 0.6)            
            
            // Save the new image (original or edited) to the Camera Roll
            if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil)
            }
            
            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
            ]
            
            var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            manager.POST(ApiLink.update_user, parameters: parameters, constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(imageData, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpeg", mimeType: "image/jpeg")
                }, success: { (operation: AFHTTPRequestOperation!, responseObject) -> Void in
                    //convert to SwiftJSON
                    let json = JSON(responseObject!)
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
                }, failure: { (operation: AFHTTPRequestOperation!, error) -> Void in
                    
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
        }
        
        // Dismiss Camera Preview
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // Add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        loadingActivityVC.has_navigationBar = true
        loadingActivityVC.has_tabBar = true
        self.contentView.addSubview(loadingActivityVC.view)
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

*/
    
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