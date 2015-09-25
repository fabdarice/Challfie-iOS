//
//  UILabelExtension.swift
//  Challfie
//
//  Created by fcheng on 2/10/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

extension UILabel {
    var adjustFontToRealIPhoneSize: Bool {
        set {
            if newValue {
                let currentFont = self.font
                var sizeScale: CGFloat = 1
                
                let model = UIDevice.currentDevice().modelName
                                
                switch model {
                case "x86_64":
                    switch UIScreen.mainScreen().bounds.height {
                        // Iphone 3 & 4
                    case 480.0 : sizeScale = 0.9
                        // Iphone 5
                    case 568.0: sizeScale = 0.9
                        // Iphone 6
                    case 667.0: sizeScale = 1.0
                        // Iphone 6Plus
                    case 736.0: sizeScale = 1.1
                    default: sizeScale = 1.0
                    }
                case "iPhone 3G": sizeScale = 0.9
                case "iPhone 3GS": sizeScale = 0.9
                case "iPhone 4": sizeScale = 0.9
                case "iPhone 4S": sizeScale = 0.9
                case "iPhone 5": sizeScale = 0.9
                case "iPhone 5c": sizeScale = 0.9
                case "iPhone 5s": sizeScale = 0.9
                case "iPhone 6" : sizeScale = 1.0
                case "iPhone 6 Plus" : sizeScale = 1.1
                default:
                    sizeScale = 1.0
                }
                
                self.font = currentFont.fontWithSize(currentFont.pointSize * sizeScale)
            }
        }
        
        get {
            return false
        }
    }
}