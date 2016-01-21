//
//  TakeMatchupPictureVC.swift
//  Challfie
//
//  Created by fcheng on 11/5/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class TakeMatchupPictureVC : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {    
    
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var noPictureLabel: UILabel!
    
    var user: User!
    var imagePicker: UIImagePickerController!
    var imageToSave: UIImage!
    var use_camera: Bool = true
    var matchup: Matchup!
    var parentController : UIViewController!
    var matchupEnded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noPictureLabel.text = NSLocalizedString("no_selfie_duel_yet", comment: "No selfie yet for the duel")
        self.takePictureButton.setTitle(NSLocalizedString("take_selfie_duel", comment: "Take selfie duel"), forState: .Normal)
        
        if user == nil {
            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
        } else {
            let keychain = Keychain(service: "challfie.app.service")
            let login = keychain["login"]!
            
            if self.matchupEnded == true {
                self.noPictureLabel.hidden = false
                self.takePictureButton.hidden = true
                self.noPictureLabel.text = NSLocalizedString("no_selfie_duel", comment: "No selfie has been taken for the duel")
            } else {
                if user.username == login {
                    self.noPictureLabel.hidden = true
                    self.takePictureButton.hidden = false
                } else {
                    self.noPictureLabel.hidden = false
                    self.takePictureButton.hidden = true
                }
            }
            
        }
        
    }
    
    @IBAction func takeMatchupPicture(sender: AnyObject) {
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let twoAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose From Your Gallery"), style: .Default) { (_) in
            self.use_camera = false
            GlobalFunctions().showPhotoLibrary(self.imagePicker, parentController: self) }

        let oneAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a Picture"), style: .Default) { (_) in
            self.use_camera = true
            GlobalFunctions().showCamera(self.imagePicker, parentController: self)
        }
        let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(thirdAction)
        
        self.parentController.presentViewController(alert, animated: true, completion: nil)
    }
        
    // MARK: - UIImagePickerController Delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        if let pickedImage = image {
            self.imageToSave = pickedImage
            
            // Save to Challfie Album
            if self.use_camera == true {
                self.imageToSave = self.fixOrientation(image)
                UIImageWriteToSavedPhotosAlbum(self.imageToSave, nil, nil, nil)
                // Push to TakePictureVC
                if let allTabViewControllers = self.tabBarController?.viewControllers,
                    let navController:UINavigationController = allTabViewControllers[2] as? UINavigationController,
                    let takePictureVC: TakePictureVC = navController.viewControllers[0] as? TakePictureVC {
                        takePictureVC.imageToSave = self.imageToSave
                        takePictureVC.matchup = self.matchup
                        self.parentController.navigationController?.pushViewController(takePictureVC, animated: true)
                        picker.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.hidesBottomBarWhenPushed = true
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as! HomeTBC
                
                let photoLibraryPreviewVC = PhotoLibraryPreviewVC(nibName: "PhotoLibraryPreview", bundle: nil)
                photoLibraryPreviewVC.imageToSave = self.imageToSave
                photoLibraryPreviewVC.homeTabBarController = homeTableViewController
                photoLibraryPreviewVC.imagePicker = picker
                photoLibraryPreviewVC.matchup = self.matchup
                photoLibraryPreviewVC.parentController = self.parentController
                picker.pushViewController(photoLibraryPreviewVC, animated: true)
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
    
}