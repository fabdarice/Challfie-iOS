//
//  User.swift
//  Challfie
//
//  Created by fcheng on 11/14/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class User {
    var id: Int!
    var username: String!
    var email: String!
    var firstname: String!
    var lastname: String!
    var profile_pic: String!
    var created_at: String!
    var book_tier: Int!
    var book_level: String!
    var is_facebook_picture: Bool!
        
    init(json: JSON) {
        self.id = json["id"].intValue
        self.created_at = json["created_at"].stringValue
        self.username = json["username"].stringValue
        self.email = json["email"].stringValue
        self.firstname = json["firstname"].stringValue
        self.lastname = json["lastname"].stringValue
        self.profile_pic = json["avatar"].stringValue
        self.book_tier = json["book_tier"].intValue
        self.book_level = json["book_level"].stringValue
        self.is_facebook_picture = json["is_facebook_picture"].boolValue
    }
    
    func show_profile_pic() -> String {
        var profile_pic_url: String!
        if ((self.is_facebook_picture == true) || (ApiLink.host == "https://challfie.com")) {
            profile_pic_url = self.profile_pic
        } else {
            profile_pic_url = ApiLink.host + self.profile_pic
        }
        return profile_pic_url
    }
}