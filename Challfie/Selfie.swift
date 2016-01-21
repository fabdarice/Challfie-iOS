//
//  Selfie.swift
//  Challfie
//
//  Created by fcheng on 11/13/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    var created_at: String!
    var user: User!
    var nb_upvotes: Int!
    var nb_downvotes: Int!
    var nb_comments: Int!
    var user_vote_status: Int!
    var last_comment: Comment!
    var flag_count: Int!
    var blocked: Bool!
    var ratio_photo: CGFloat!
    var matchup: Matchup!
    
    init(id: Int) {
        self.id = id
    }
    
    init(json:JSON) {
        self.id = json["id"].intValue
        self.message = json["message"].stringValue
        self.photo = json["photo"].stringValue
        self.shared_fb = json["shared_fb"].boolValue
        self.approval_status = json["approval_status"].intValue
        self.is_daily = json["is_daily"].boolValue
        self.is_private = json["private"].boolValue
        self.creation_date = json["creation_date"].stringValue
        self.created_at = json["created_at"].stringValue
        self.nb_upvotes = json["nb_upvotes"].intValue
        self.nb_downvotes = json["nb_downvotes"].intValue
        self.nb_comments = json["nb_comments"].intValue
        self.user_vote_status = json["status_vote"].intValue
        self.flag_count = json["flag_count"].intValue
        self.blocked = json["blocked"].boolValue
        self.ratio_photo =  CGFloat(json["ratio_photo"].floatValue)
        
        let challenge = Challenge.init(json: json["challenge"])
        let user = User.init(json: json["user"])
        let last_comment = Comment.init(json: json["last_comment"])
        if json["matchup"].count > 0 {
            let matchup = Matchup.init(json: json["matchup"])
            self.matchup = matchup
        }
        
        self.challenge = challenge
        self.user = user
        self.last_comment = last_comment

    }
    
    func show_selfie_pic() -> String {
        return self.photo
    }
}

extension Selfie: Equatable {}

func ==(lhs: Selfie, rhs: Selfie) -> Bool {
    return lhs.id == rhs.id
}
