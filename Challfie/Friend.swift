//
//  Friend.swift
//  Challfie
//
//  Created by fcheng on 12/17/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation


class Friend: User {
    var nb_mutual_friends: Int!
    
    override init(json: JSON) {
        super.init(json: json)
        self.nb_mutual_friends = json["nb_mutual_friend"].intValue
    }
    
}