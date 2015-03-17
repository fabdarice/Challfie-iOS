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
                var currentFont = self.font
                var sizeScale: CGFloat = 1
                
                let model = UIDevice.currentDevice().modelName
                                
                switch model {
                case "iPhone 4": sizeScale = 0.9
                case "iPhone 4S": sizeScale = 0.9
                case "iPhone 5": sizeScale = 0.9
                case "iPhone 5c": sizeScale = 0.9
                case "iPhone 5s": sizeScale = 0.9
                case "iPhone 6" : sizeScale = 1.0
                case "iPhone 6 Plus" : sizeScale = 2.0
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