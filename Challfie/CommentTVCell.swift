//
//  ListCommentsCell.swift
//  Challfie
//
//  Created by fcheng on 12/5/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class CommentTVCell : UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    func loadItem(comment: Comment) {
        
        // Make Cells Non Selectable
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        // view background color
        self.backgroundColor = MP_HEX_RGB("F7F7F7")
        
        // Last Comment Username
        //self.usernameLabel.setNeedsUpdateConstraints()
        self.usernameLabel.text = comment.username
        self.usernameLabel.textColor = MP_HEX_RGB("3E9AB5")
        self.usernameLabel.sizeToFit() // To update the UILabel frame width to fit it's content
        
        // Message Style - Indent First Line
        let comment_message_style = NSMutableParagraphStyle()
        comment_message_style.firstLineHeadIndent = CGFloat(self.usernameLabel.frame.width + 5.0)
        comment_message_style.headIndent = 0.0
        var comment_message_indent = NSMutableAttributedString(string: comment.message)
        // Test if Last comment exists or not
        comment_message_indent.addAttribute(NSParagraphStyleAttributeName, value: comment_message_style, range: NSMakeRange(0, comment_message_indent.length))
        self.messageLabel.attributedText = comment_message_indent
        self.messageLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        self.messageLabel.textColor = MP_HEX_RGB("000000")
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
    }
}