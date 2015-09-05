//
//  Challenge.swift
//  Challfie
//
//  Created by fcheng on 11/13/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class Challenge {
    var id:Int!
    var description: String!
    var difficulty: Int!
    var complete_status: Int!
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.description = json["description"].stringValue
        self.difficulty = json["difficulty"].intValue
        self.complete_status = json["complete_status"].intValue
    }
    
}