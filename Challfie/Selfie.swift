//
//  Selfie.swift
//  Challfie
//
//  Created by fcheng on 11/13/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class Selfie {
    var id: Int!
    var message: String!
    var photo: String!
    var shared_fb: Bool!
    var challenge: Challenge!
    var is_private: Bool!
    var approval_status: Int!
    var is_daily: Bool!
    var creation_date: String!
    var user: User!
    var nb_upvotes: Int!
    var nb_downvotes: Int!
    var nb_comments: Int!
    var user_vote_status: Int!
    var last_comment: Comment!
    
    init(json:JSON) {
        self.id = json["id"].intValue
        self.message = json["message"].stringValue
        self.photo = json["photo"].stringValue
        self.shared_fb = json["shared_fb"].boolValue
        self.approval_status = json["approval_status"].intValue
        self.is_daily = json["is_daily"].boolValue
        self.is_private = json["private"].boolValue
        self.creation_date = json["creation_date"].stringValue
        self.nb_upvotes = json["nb_upvotes"].intValue
        self.nb_downvotes = json["nb_downvotes"].intValue
        self.nb_comments = json["nb_comments"].intValue
        self.user_vote_status = json["status_vote"].intValue
    }
    
    
    
}
