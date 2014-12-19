//
//  HomeTBC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class HomeTBC: UITabBarController {
    
    //var new_alert_nb:Int! = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tabbar Background
        self.tabBar.backgroundImage = UIImage(named: "tabBar_background_white")
        
        // TabBar Text and Image color for selected item
        self.tabBar.selectedImageTintColor = MP_HEX_RGB("30768A")
        
        // Set Color for selected and unselected title item
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("A8A7A7")], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MP_HEX_RGB("30768A")], forState:.Selected)
        
        // Set Color for unselected image item
        for item in self.tabBar.items as [UITabBarItem] {
            if item.title != "" {
                if let image = item.image {
                    item.image = image.imageWithColor(MP_HEX_RGB("A8A7A7")).imageWithRenderingMode(.AlwaysOriginal)
                }
            } else {
                item.image = UIImage(named: "tabBar_camera")?.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
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
