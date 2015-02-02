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
import AssetsLibrary

class TakePictureVC : UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UISearchBarDelegate  {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var pickChallengeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var shareFacebookSwitch: UISwitch!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var facebookShareLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var cameraViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewTopConstraint: NSLayoutConstraint!
    
    var photo_taken: Bool = false
    var message_presence: Bool = false
    var challenges_array: [Challenge] = []
    var all_challenges_array: [Challenge] = []
    var image_base64String : String!
    var use_camera: Bool = true
    var library: ALAssetsLibrary = ALAssetsLibrary()
    var albumWasFound: Bool = false
    var imageData: NSData!
    var imageToSave: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        
        // add NavigationItem
        let backItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "retakePicture")
        let doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "createSelfie")
        backItem.tintColor = MP_HEX_RGB("FFFFFF")
        doneItem.tintColor = MP_HEX_RGB("5BD9FC")
        self.navigationItem.leftBarButtonItem = backItem
        
        self.navigationItem.rightBarButtonItem = doneItem
        
        var navigationTitle : UILabel = UILabel(frame: CGRectMake(0.0, 0.0, 100.0, 40.0))
        navigationTitle.font = UIFont(name: "Chinacat", size: 16.0)
        navigationTitle.text = NSLocalizedString("post_a_challfie", comment: "Post a Challfie")
        navigationTitle.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = navigationTitle
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("C8DFE6")
        self.separatorView.backgroundColor = MP_HEX_RGB("F0F0F0")
        
        
        // UIView That contains the Image
        self.cameraView.layer.borderColor = MP_HEX_RGB("85BBCC").CGColor
        self.cameraView.layer.borderWidth = 1.0
        
        // UIView that contains Settings
        self.settingView.layer.borderColor = MP_HEX_RGB("85BBCC").CGColor
        self.settingView.layer.borderWidth = 1.0
        
        self.settingsLabel.textColor = MP_HEX_RGB("1A596B")
        self.settingsLabel.text = NSLocalizedString("settings", comment: "Settings")
        self.pickChallengeLabel.textColor = MP_HEX_RGB("1A596B")
        self.pickChallengeLabel.text = NSLocalizedString("pick_a_challenge", comment: "Pick a Challenge")
        
        self.privacyLabel.text = NSLocalizedString("privacy_text", comment: "Only visible to your followers")
        self.facebookShareLabel.text = NSLocalizedString("shareFacebook_text", comment: "Share on Facebook")
        
        
        // UITextView Settings
        self.messageTextView.layer.borderColor = MP_HEX_RGB("85BBCC").CGColor
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
        self.searchBar.layer.borderColor = MP_HEX_RGB("85BBCC").CGColor
        self.searchBar.layer.borderWidth = 1.0
        self.searchBar.placeholder = NSLocalizedString("search_a_challenge", comment: "Search a Challenge")
        
        var tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        self.view.userInteractionEnabled = true
        
        // HiddenView to cover the UIPickerView to dismissKeyboard when tapgesture because tapgesture doesn't work on UIPickerView
        var tapGesture2 : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture2.addTarget(self, action: "dismissKeyboard")
        self.hiddenView.addGestureRecognizer(tapGesture)
        self.hiddenView.userInteractionEnabled = true
        self.hiddenView.hidden = true
        
        // Hide ProgressView
        self.progressView.hidden = true
        
        // Add Notification for when the Keyboard pop up  and when it is dismissed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name:UIKeyboardDidHideNotification, object: nil)
       
        // set delegate
        self.searchBar.delegate = self
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Remove the Keyboard Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.photo_taken == false {
            if self.use_camera == true {
                self.showCamera()
            } else {
                self.showPhotoLibrary()
            }
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
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        
        Alamofire.request(.POST, ApiLink.challenges_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {                    
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
                    if json["challenges"].count != 0 {
                        for var i:Int = 0; i < json["challenges"].count; i++ {
                            var challenge = Challenge.init(json: json["challenges"][i])
                            self.challenges_array.append(challenge)
                        }
                        self.pickerView.reloadAllComponents()
                        self.all_challenges_array = self.challenges_array
                    }
                    
                    
                }
                //self.loadingIndicator.stopAnimating()
        }
    }
    
    // Dismiss Searchbar Keyboard
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    // Add selfie
    func createSelfie() {
        
        // Retrieve selected challenge
        let selected_row = self.pickerView.selectedRowInComponent(0)
        var selected_challenge: Challenge = self.challenges_array[selected_row]
        
        
        if let cameraImage = self.cameraView.image {
            // Image Exists
        } else {
            // Image Not Selected
            var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_image", comment: "Please select a picture."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return ;
        }

        self.progressView.hidden = false
        
        self.progressView.progress = 0.05
        self.cameraViewTopConstraint.constant = 35
        self.messageViewTopConstraint.constant = 35
        

        self.imageData = UIImagePNGRepresentation(self.imageToSave)
        self.image_base64String = imageData.base64EncodedStringWithOptions(.allZeros)

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
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "message": message,
            "is_private": is_private,
            "is_shared_fb": is_shared_fb,
            "challenge_id": selected_challenge.id.description,
            "image_base64String": self.image_base64String
        ]

        Alamofire.request(.POST, ApiLink.create_selfie, parameters: parameters, encoding: .JSON)
            .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                println("ENTER .PROGRESSS")
                println("\(totalBytesRead) of \(totalBytesExpectedToRead)")
                //println(Float(totalBytesExpectedToRead))
                self.progressView.setProgress(Float(totalBytesRead) / Float(totalBytesExpectedToRead), animated: true)
            }
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //convert to SwiftJSON
                    let json = JSON(mydata!)
                    
                    // Check success response
                    if (json["success"].intValue == 1) {
                        self.cameraView.image = nil
                        self.messageTextView.text = NSLocalizedString("add_message", comment: "Add a message..")
                        self.messageTextView.textColor = UIColor.lightGrayColor()
                        self.messageTextView.font = UIFont.italicSystemFontOfSize(13.0)
                        self.message_presence = false
                        
                        // Switch to Timeline Tab
                        self.tabBarController?.selectedIndex = 0
                    }  else {
                        // ERROR RESPONSE FROM HTTP Request
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    }
                }
                self.progressView.hidden = true
                self.cameraViewTopConstraint.constant = 10
                self.messageViewTopConstraint.constant = 10
        }
    }
    
    // Cancel selfie and retake Picture
    func retakePicture() {
        self.photo_taken = false
        if self.use_camera {
            self.showCamera()
        } else {
            self.showPhotoLibrary()
        }
        
    }
    
    // When the user is taking a picture from the device camera
    func showCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            var mediaTypes: Array<AnyObject> = [kUTTypeImage]
            picker.mediaTypes = mediaTypes
            picker.allowsEditing = true
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else{
            var alert = UIAlertController(title: "No Camera Found", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // When the user is selecting a picture from the gallery
    func showPhotoLibrary() {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    

    // MARK: - UISearchBarDelegate, UISearchDisplayDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text.isEmpty {
            self.challenges_array = self.all_challenges_array
        } else {
            self.challenges_array.removeAll(keepCapacity: false)
            for var index = 0; index < self.all_challenges_array.count; index++
            {
                var currentString = self.all_challenges_array[index].description as String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString) != nil {
                    self.challenges_array.append(self.all_challenges_array[index])
                    
                }
            }
        }
        self.pickerView.reloadAllComponents()
    }
    
    // Dismiss Keyboard when Search Button has been clicked on
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    
    // MARK: - UIImagePicker Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary!) {
        self.photo_taken = true
        let mediaType = info[UIImagePickerControllerMediaType] as String
        var originalImage:UIImage?, editedImage:UIImage?
        
        // Handle a still image capture
        let compResult:CFComparisonResult = CFStringCompare(mediaType as NSString!, kUTTypeImage, CFStringCompareFlags.CompareCaseInsensitive)
        if ( compResult == CFComparisonResult.CompareEqualTo ) {
            editedImage = info[UIImagePickerControllerEditedImage] as UIImage?
            originalImage = info[UIImagePickerControllerOriginalImage] as UIImage?
            
            if ( editedImage == nil ) {
                self.imageToSave = editedImage
            } else {
                self.imageToSave = originalImage
            }

            self.cameraView.image = imageToSave
            
            if self.use_camera == true {
                self.imageToSave = self.fixOrientation(imageToSave!)
                UIImageWriteToSavedPhotosAlbum(self.imageToSave, nil, nil, nil)
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.tabBarController?.selectedIndex = 0
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
    
    //MARK: - UIPickerView Delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.challenges_array.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.challenges_array[row].description
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = self.challenges_array[row].description
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Chinacat", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        pickerLabel.numberOfLines = 1
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.minimumScaleFactor = 0.5
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.searchBar.resignFirstResponder()
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
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // hide keyboard when tap outside the textfield
        self.view.endEditing(true)
    }
    
    
    
}
