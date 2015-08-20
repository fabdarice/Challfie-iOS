//
//  ExtraPagesTVCell.swift
//  Challfie
//
//  Created by fcheng on 2/23/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class ExtraPagesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func loadItem() {
        self.titleLabel.textColor = MP_HEX_RGB("30768A")
        self.titleLabel.font = UIFont.boldSystemFontOfSize(14.0)
        self.titleLabel.numberOfLines = 0
        
        self.messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textColor = UIColor.blackColor()
    }
}