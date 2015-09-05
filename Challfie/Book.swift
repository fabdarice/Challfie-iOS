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
    
    init() {
        
    }
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.cover = json["cover"].stringValue
        self.tier = json["tier"].intValue
        self.is_unlocked = json["is_unlocked"].boolValue
        self.challenges_array = []
    }
    
    func show_book_pic() -> String {
        var book_url: String!
        if ApiLink.host == "https://challfie.com" {
            book_url = self.cover
        } else {
            book_url = ApiLink.host + self.cover
        }
        return book_url
    }
}