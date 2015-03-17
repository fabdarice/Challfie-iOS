//
//  LoadingActivityVC.swift
//  Challfie
//
//  Created by fcheng on 2/12/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class LoadingActivityVC: UIViewController {
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var has_tabBar: Bool = false
    var has_navigationBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var variableHeight: CGFloat = 0.0
        if self.has_tabBar == true {
            variableHeight += 49
        }
        
        if self.has_navigationBar == true {
            variableHeight += 40
        }
        
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        var screenHeight: CGFloat = 0.0
        var screenWidth: CGFloat = 0.0
        
        switch model {
        case "iPhone 4S":
            screenHeight = 480
            screenWidth = 320.0
        case "iPhone 5":
            screenHeight = 568
            screenWidth = 320.0
        case "iPhone 5c":
            screenHeight = 568
            screenWidth = 320.0
        case "iPhone 5s":
            screenHeight = 568
            screenWidth = 320.0
        case "iPhone 6" :
            screenHeight = 667
            screenWidth = 375
        case "iPhone 6 Plus" :
            screenHeight = 736
            screenWidth = 414.0
        default:
            screenHeight = 667
            screenWidth = 375
        }
        
        println("VIEW FRAME : \(self.view.frame)")
        
        // -49 because of the height of the Tabbar ; -40 because of navigationController
        var newframe = CGRectMake(0.0, 0.0, screenWidth, screenHeight - variableHeight)
        
        self.view.frame = newframe
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.activityIndicator.startAnimating()
        self.activityIndicator.color = UIColor.whiteColor()
        self.activityView.layer.cornerRadius = 15.0
        //self.activityView.clipsToBounds = true
        self.activityView.layer.borderWidth = 2.0
        //self.activityView.backgroundColor = MP_HEX_RGB("D1D1D1")
        self.activityView.backgroundColor = MP_HEX_RGB("052933")
        self.activityView.layer.borderColor = MP_HEX_RGB("1A596B").CGColor

        
    }
}