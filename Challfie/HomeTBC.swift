//
//  HomeTBC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class HomeTBC: UITabBarController, UITabBarControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //var new_alert_nb:Int! = 0
    var from_facebook: Bool = false
    var imageToSave: UIImage!
    var imagePicker: UIImagePickerController!
    var use_camera: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Tabbar Background
        self.tabBar.backgroundImage = UIImage(named: "tabBar_background")
        
        // TabBar Text and Image color for selected item
        self.tabBar.tintColor = MP_HEX_RGB("30768A")
        
        // Set Color for selected and unselected title item
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("A8A7A7")], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("30768A")], forState:.Selected)

        
        // Set Color for unselected image item
        if let tabBarItems = self.tabBar.items {
            for item in tabBarItems {
                if let image = item.image {
                    item.image = image.imageWithColor(MP_HEX_RGB("A8A7A7")).imageWithRenderingMode(.AlwaysOriginal)
                }
            }
            
        }
        
        // Load all views + set Title of UITabBarItem
        var i = 0
        for viewController in self.viewControllers!
        {
            let _ = viewController.view
            let navController:UINavigationController = (viewController as? UINavigationController)!
            switch i {
            case 0 : navController.tabBarItem.title = NSLocalizedString("tab_timeline", comment: "Timeline")
            case 1 : navController.tabBarItem.title = NSLocalizedString("tab_challenge", comment: "Challenge")
            case 2 :
                navController.tabBarItem.title = nil
                navController.tabBarItem.image = UIImage(named: "tabBar_camera")?.imageWithRenderingMode(.AlwaysOriginal)
                navController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            case 3 : navController.tabBarItem.title = NSLocalizedString("tab_friends", comment: "Friends")
            case 4 : navController.tabBarItem.title = NSLocalizedString("tab_alert", comment: "Alert")
            default: navController.tabBarItem.title = ""
            }
            i += 1
        }
        
        if self.from_facebook == true {            
            // Show Friend's Tab
            self.selectedIndex = 3
        }
        
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        // If currently on timeline page and tap on "Timeline" tab, scroll tableview to top
        if let selectedViewController = tabBarController.viewControllers {
            if (viewController == selectedViewController[0] as NSObject) && (self.selectedIndex == 0) {
                if let navController = viewController as? UINavigationController {
                    let timelineVC: TimelineVC = navController.viewControllers[0] as! TimelineVC
                    timelineVC.timelineTableView.setContentOffset(CGPointMake(0, 0 - timelineVC.timelineTableView.contentInset.top), animated:true)
                    timelineVC.navigationController?.navigationBarHidden = false
                }
            }
        }

        
        // Show popup for "camera Tab" instead of showing the viewcontroller directly
        if let selectedViewController = tabBarController.viewControllers {
            if (viewController == selectedViewController[2] as NSObject) {
                // Show Pop-op to options to choose between camera and photo library
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                let oneAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a Picture"), style: .Default) { (_) in
                    self.use_camera = true
                    self.showCamera()
                }
                let twoAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose From Your Gallery"), style: .Default) { (_) in
                    self.use_camera = false
                    self.showPhotoLibrary()
                }
                let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
                
                alert.addAction(oneAction)
                alert.addAction(twoAction)
                alert.addAction(thirdAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                return false
            }
        }
        return true
    }
    
    
    
    // MARK: - When the user is taking a picture from the device camera
    func showCamera() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            GlobalFunctions().displayAlert(title: "No Camera Found", message: " ", controller: self)
        }
    }
    
    // MARK: - When the user is selecting a picture from the gallery
    func showPhotoLibrary() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            GlobalFunctions().displayAlert(title: "No access to photo library", message: " ", controller: self)
        }
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
                if let allTabViewControllers = self.viewControllers,
                navController:UINavigationController = allTabViewControllers[2] as? UINavigationController,
                takePictureVC: TakePictureVC = navController.viewControllers[0] as? TakePictureVC {
                    takePictureVC.imageToSave = self.imageToSave
                    self.selectedViewController = navController
                    picker.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.hidesBottomBarWhenPushed = true
                let photoLibraryPreviewVC = PhotoLibraryPreviewVC(nibName: "PhotoLibraryPreview", bundle: nil)
                photoLibraryPreviewVC.imageToSave = self.imageToSave
                photoLibraryPreviewVC.homeTabBarController = self
                photoLibraryPreviewVC.imagePicker = picker
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

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
