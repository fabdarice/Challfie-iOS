//
//  User.swift
//  Challfie
//
//  Created by fcheng on 11/14/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    var id: Int!
    var username: String!
    var authentication_token: String!
    var email: String!
    var firstname: String!
    var lastname: String!
    var profile_pic: String!
    var created_at: String!
    var book_tier: Int!
    var book_level: String!
    var book_image: String!
    var is_facebook_picture: Bool!
    // Variable to check if the current_user has a following relationship (pending or not) with self.user
    var is_following: Bool!
    // Variable to check if the current_user has a following request pending for self.user
    var is_pending: Bool!
    var uid: String!
    var oauth_token: String!
    var progression: Int!
    var administrator: Int!
    var blocked: Bool!
    var is_current_user: Bool!
    var matchups_stats: String!
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.created_at = json["created_at"].stringValue
        self.username = json["username"].stringValue
        self.authentication_token = json["authentication_token"].stringValue
        self.email = json["email"].stringValue
        self.firstname = json["firstname"].stringValue
        self.lastname = json["lastname"].stringValue
        self.profile_pic = json["avatar"].stringValue
        self.book_tier = json["book_tier"].intValue
        self.book_level = json["book_level"].stringValue
        self.book_image = json["book_image"].stringValue
        self.is_facebook_picture = json["is_facebook_picture"].boolValue
        self.is_following = json["is_following"].boolValue
        self.is_pending = json["is_pending"].boolValue
        self.uid = json["uid"].stringValue
        self.oauth_token = json["oauth_token"].stringValue
        self.progression = json["progression"].intValue
        self.administrator = json["administrator"].intValue
        self.blocked = json["blocked"].boolValue
        self.is_current_user = json["is_current_user"].boolValue
        self.matchups_stats = json["matchups_stats"].stringValue
    }
    
    func show_profile_pic() -> String {
        if self.profile_pic == "/assets/missing_user.png" {
            return "missing"
        } else {
            return self.profile_pic
        }
        
    }
    
    func show_book_image() -> String {
        return self.book_image
        
    }
}