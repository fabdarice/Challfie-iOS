//
//  HomeTBC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class HomeTBC: UITabBarController, UITabBarControllerDelegate, UIAlertViewDelegate {
    
    //var new_alert_nb:Int! = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Tabbar Background
        self.tabBar.backgroundImage = UIImage(named: "tabBar_background_white")
        
        // TabBar Text and Image color for selected item
        self.tabBar.selectedImageTintColor = MP_HEX_RGB("30768A")
        
        // Set Color for selected and unselected title item
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("A8A7A7")], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("30768A")], forState:.Selected)

        // Set Color for unselected image item
        for item in self.tabBar.items as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(MP_HEX_RGB("A8A7A7")).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        var camera_tabBarItem : UITabBarItem = self.tabBar.items?[2] as UITabBarItem
        camera_tabBarItem.title = nil
        camera_tabBarItem.image = UIImage(named: "tabBar_camera")?.imageWithRenderingMode(.AlwaysOriginal)
        camera_tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        // Show popup for "camera Tab" instead of showing the viewcontroller directly
        if let selectedViewController = tabBarController.viewControllers {
            if (viewController == selectedViewController[2] as NSObject) {

                let navController = viewController as UINavigationController
                var takePictureVC: TakePictureVC = navController.viewControllers[0] as TakePictureVC
                
                // Show Pop-op to options to choose between camera and photo library on iOS 8
                var alert = UIAlertController(title: nil, message: NSLocalizedString("add_a_new_selfie", comment: "Add a new challfie"), preferredStyle: UIAlertControllerStyle.ActionSheet)
                let oneAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a Picture"), style: .Default) { (_) in
                        takePictureVC.use_camera = true
                        takePictureVC.photo_taken = false
                        tabBarController.selectedViewController = navController
                    }
                let twoAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose From Your Gallery"), style: .Default) { (_) in
                        takePictureVC.use_camera = false
                        takePictureVC.photo_taken = false
                        tabBarController.selectedViewController = navController
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
    
}

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
