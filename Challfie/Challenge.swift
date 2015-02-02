//
//  Challenge.swift
//  Challfie
//
//  Created by fcheng on 11/13/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class Challenge {
    var id:Int!
    var created_at: String!
    var description: String!
    var difficulty: Int!
    var point: Int!
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.created_at = json["created_at"].stringValue
        self.description = json["description"].stringValue
        self.difficulty = json["difficulty"].intValue
        self.point = json["point"].intValue
    }
    
}