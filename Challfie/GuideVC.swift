//
//  GuideVC.swift
//  Challfie
//
//  Created by fcheng on 8/21/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class GuideVC : UIViewController, GKImagePickerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var skipTutorialButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var takeSelfieButton: UIButton!
    
    var from_facebook: Bool = false
    var use_camera: Bool = true
    var imageToSave: UIImage!
    var imagePicker: GKImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        
        self.usernameLabel.text = login
        self.welcomeLabel.text = NSLocalizedString("tutorial_one_title", comment: "Welcome")
        self.descriptionLabel.text = NSLocalizedString("tutorial_one_description", comment: "")
        self.skipTutorialButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip the tutorial"), forState: UIControlState.Normal)
        self.takeSelfieButton.setTitle(NSLocalizedString("tutorial_one_button", comment: ""), forState: UIControlState.Normal)
        self.takeSelfieButton.layer.cornerRadius = 5
        self.takeSelfieButton.layer.borderWidth = 1.0
        self.takeSelfieButton.layer.borderColor = MP_HEX_RGB("1E3A75").CGColor
    }
    
    

    
    // MARK: skipTutorial()
    @IBAction func skipTutorialAction(sender: AnyObject) {
        if self.from_facebook == true {
            // Modal to Timeline TabBarViewCOntroller
            self.performSegueWithIdentifier("homeSegue2", sender: self)
        } else {
            // Modal to LinkFacebook Tutorial Page
            self.performSegueWithIdentifier("linkFacebookSegue", sender: self)
        }
    }
    
    
    // MARK: takeSelfieAction()
    @IBAction func takeSelfieAction(sender: AnyObject) {
    
        // Show Pop-op to options to choose between camera and photo library
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a picture"), style: .Default) { (_) in
            self.use_camera = true
            self.showCamera()
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose from your Gallery"), style: .Default) { (_) in
            self.use_camera = false
            self.showPhotoLibrary()
        }
        let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(thirdAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Show Camera
    // When the user is taking a picture from the device camera
    func showCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            // Add Background for status bar
            let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
            statusBarViewBackground?.hidden = true
            self.imagePicker = GKImagePicker()
            self.imagePicker.cropSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 30, UIScreen.mainScreen().bounds.width - 30)
            // self.imagePicker.cropSize = CGSizeMake(300.0, 300.0)
            self.imagePicker.delegate = self
            self.imagePicker.resizeableCropArea = false
            
            //set the source type
            self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            self.presentViewController(self.imagePicker.imagePickerController, animated: true, completion: nil)
        }
        else{
            GlobalFunctions().displayAlert(title: "No Camera Found", message: " ", controller: self)
        }
    }
    
    // MARK: Show Photo Gallery
    // When the user is selecting a picture from the gallery
    func showPhotoLibrary() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        self.imagePicker = GKImagePicker()
        self.imagePicker.cropSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 30, UIScreen.mainScreen().bounds.width - 30)
        //self.imagePicker.cropSize = CGSizeMake(300.0, 300.0)
        self.imagePicker.delegate = self
        self.imagePicker.resizeableCropArea = false
        
        //set the source type
        self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(self.imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - GKImagePicker Delegate Methods
    func imagePicker(imagePicker: GKImagePicker!, pickedImage image: UIImage!) {
        self.imageToSave = image
        
        if self.use_camera == true {
            self.imageToSave = self.fixOrientation(image)
            UIImageWriteToSavedPhotosAlbum(self.imageToSave, nil, nil, nil)
        }
        
        imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        // API TO UPLOAD SELFIE
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            self.createSelfie()
        })
        
        // Push to GuideTakePicture
        let guideTakePictureVC = GuideTakePictureVC(nibName: "GuideTakePicture" , bundle: nil)
        guideTakePictureVC.from_facebook = self.from_facebook
        guideTakePictureVC.imageToSave = self.imageToSave
        self.presentViewController(guideTakePictureVC, animated: true, completion: nil)
        
    }
    
    func imagePickerDidCancel(imagePicker: GKImagePicker!) {
        imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        self.tabBarController?.selectedIndex = 0
    }
    
    
    // MARK: = Fix Orientation of the picture
    func fixOrientation(img:UIImage) -> UIImage {
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.drawInRect(rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    // MARK: - Upload the Selfie on the server
    func createSelfie() {
        // Retrieve id of challenge : "Take a selfie"
        let id_challenge: String = "1"
        let imageData = UIImageJPEGRepresentation(self.imageToSave, 0.9)
        
        let is_private: String = "1"
        let is_shared_fb: String = "0"
        let message: String = NSLocalizedString("first_challfie", comment: "My first Challfie!!")
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "message": message,
            "is_private": is_private,
            "is_shared_fb": is_shared_fb,
            "challenge_id": id_challenge,
            "approval_status": "1"
        ]
        
        Alamofire.upload(Method.POST, ApiLink.create_selfie,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: parameters["login"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "login")
                multipartFormData.appendBodyPart(data: parameters["auth_token"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "auth_token")
                multipartFormData.appendBodyPart(data: parameters["challenge_id"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "challenge_id")
                multipartFormData.appendBodyPart(data: parameters["message"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "message")
                multipartFormData.appendBodyPart(data: parameters["is_private"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_private")
                multipartFormData.appendBodyPart(data: parameters["is_shared_fb"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "is_shared_fb")
                multipartFormData.appendBodyPart(data: parameters["approval_status"]!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "approval_status")
                multipartFormData.appendBodyPart(data: imageData!, name: "mobile_upload_file", fileName: "mobile_upload_file21.jpg", mimeType: "image/jpeg")
            },
            encodingCompletion: nil
        )
    }
    
    
    // MARK: - prepareForSegue method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "homeSegue2") && (self.from_facebook == true) {
            let tabBar: HomeTBC = segue.destinationViewController as! HomeTBC
            tabBar.selectedIndex = 3
        }
    }

    
    
    
}