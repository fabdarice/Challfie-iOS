//
//  Friend.swift
//  Challfie
//
//  Created by fcheng on 12/17/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON


class Friend: User {
    var nb_mutual_friends: Int!
    var nb_followers: Int!
    

    override init(json: JSON) {
        super.init(json: json)
        self.nb_mutual_friends = json["nb_mutual_friend"].intValue
        self.nb_followers = json["nb_followers"].intValue        
    }
    
}