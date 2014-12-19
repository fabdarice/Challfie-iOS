//
//  Comment.swift
//  Challfie
//
//  Created by fcheng on 11/26/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class Comment {
    var id: Int!
    var message: String!
    var username: String!
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.message = json["message"].stringValue
        self.username = json["username"].stringValue
    }
    
}