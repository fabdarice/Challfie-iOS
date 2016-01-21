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
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var homeTabBarController: HomeTBC!
    var imageToSave: UIImage!
    var imagePicker: UIImagePickerController!
    var challenge_selected: String = ""
    var matchup : Matchup!
    var parentController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        self.cancelButton.setTitle(NSLocalizedString("cancel", comment: "Cancel"), forState: UIControlState.Normal)
        self.validateButton.setTitle(NSLocalizedString("confirm", comment: "Confirm"), forState: UIControlState.Normal)        
        self.navigationController?.navigationBarHidden = true
        
        let screen_width = UIScreen.mainScreen().bounds.width - 8 - 8
        let ratio_photo = self.imageToSave.size.width / self.imageToSave.size.height
        self.imageHeightConstraint.constant =  screen_width / ratio_photo
        
        self.imageView.image = self.imageToSave
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        //self.homeTabBarController.showPhotoLibrary()
    }
    
    @IBAction func validateAction(sender: AnyObject) {
        // Push to TakePictureVC
        if let allTabViewControllers = homeTabBarController.viewControllers,
            navController:UINavigationController = allTabViewControllers[2] as? UINavigationController,
            takePictureVC: TakePictureVC = navController.viewControllers[0] as? TakePictureVC {
            takePictureVC.imageToSave = self.imageToSave
            takePictureVC.challenge_selected = self.challenge_selected
            takePictureVC.matchup = self.matchup
                
            if self.matchup == nil {
                homeTabBarController.selectedViewController = navController
            } else {
                self.parentController.navigationController?.pushViewController(takePictureVC, animated: true)
            }
            
            self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
}