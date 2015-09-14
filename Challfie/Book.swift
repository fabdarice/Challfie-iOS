//
//  Book.swift
//  Challfie
//
//  Created by fcheng on 11/14/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class Book {
    var id: Int!
    var name: String!
    var cover: String!
    var is_unlocked: Bool!
    var tier: Int!
    var challenges_array: [Challenge]!
    var thumb: String!
    
    init() {
        
    }
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.cover = json["cover"].stringValue
        self.tier = json["tier"].intValue
        self.is_unlocked = json["is_unlocked"].boolValue
        self.thumb = json["thumb"].stringValue
        self.challenges_array = []
    }
    
    func show_book_pic() -> String {
        return self.cover
    }
}