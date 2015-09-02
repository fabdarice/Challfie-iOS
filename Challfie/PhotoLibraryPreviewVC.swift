//
//  PhotoLibraryPreviewVC.swift
//  Challfie
//
//  Created by fcheng on 8/30/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class PhotoLibraryPreviewVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    
    var homeTabBarController: HomeTBC!
    var imageToSave: UIImage!
    var imagePicker: UIImagePickerController!
    var challenge_selected: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        self.imageView.image = self.imageToSave
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.cancelButton.setTitle(NSLocalizedString("cancel", comment: "Cancel"), forState: UIControlState.Normal)
        self.validateButton.setTitle(NSLocalizedString("confirm", comment: "Confirm"), forState: UIControlState.Normal)        
        self.navigationController?.navigationBarHidden = true
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.homeTabBarController.showPhotoLibrary()
    }
    
    @IBAction func validateAction(sender: AnyObject) {
        // Push to TakePictureVC
        if let allTabViewControllers = homeTabBarController.viewControllers {
            var navController:UINavigationController = allTabViewControllers[2] as UINavigationController
            var takePictureVC: TakePictureVC = navController.viewControllers[0] as TakePictureVC
            takePictureVC.imageToSave = self.imageToSave
            takePictureVC.challenge_selected = self.challenge_selected
            homeTabBarController.selectedViewController = navController
            self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}