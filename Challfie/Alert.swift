//
//  Alert.swift
//  Challfie
//
//  Created by fcheng on 12/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AlertType: String {
    case CommentMine = "comment_mine", CommentOther = "comment_other", SelfieApproval = "selfie_approval", SelfieStatus = "selfie_status", FriendRequest = "friend_request", LevelUnlock = "book_unlock", DailyChallenge = "daily_challenge", ChallfieMessage = "challfie_message", Matchup = "matchup"
}

class Alert {
    var id: Int!
    //var user_img: String!
    var author: User!
    var selfie_id: Int!
    var selfie_img: String!
    var book_img: String!
    var message: String!
    var time_ago: String!
    var type_notification: String!
    var read: Bool!
    var matchup: Matchup!
    
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.message = json["message"].stringValue
        self.selfie_id = json["selfie_id"].intValue
        self.selfie_img = json["selfie_img"].stringValue
        self.book_img = json["book_img"].stringValue
        self.time_ago = json["time_ago"].stringValue
        self.type_notification = json["type_notification"].stringValue
        self.read = json["read"].boolValue
        
        self.author = User.init(json: json["author"])
        self.matchup = Matchup.init(json: json["matchup"])
    }
}