//
//  Matchup.swift
//  Challfie
//
//  Created by fcheng on 11/4/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MatchupStatus: String {
    case Pending = "pending", Accepted = "accepted", Declined = "declined", Ended = "ended", EndedWithDraw = "ended_with_draw"
}

class Matchup {
    var id:Int!
    var type_matchup: Int!
    var status: String!
    var participants: [User] = []
    var selfies: [Selfie] = []
    var is_creator: Bool!
    var duration: Int!
    var challenge: Challenge!
    var end_date: NSDate!
    var matchup_winner: String!
    
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.type_matchup = json["type_matchup"].intValue
        self.status = json["status"].stringValue
        self.duration = json["duration"].intValue
        self.is_creator = json["is_creator"].boolValue
        
        self.challenge = Challenge.init(json: json["challenge"])
        
        if json["end_date_with_timezone"] != nil {
            self.end_date = dateFromString(json["end_date_with_timezone"].stringValue, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }
        
        if json["matchup_winner"] != nil {
            self.matchup_winner = json["matchup_winner"].stringValue
        }
        
        for var j:Int = 0; j < json["users"].count; j++ {
            let user = User.init(json: json["users"][j])
            self.participants.append(user)
        }
        
        for var j:Int = 0; j < json["selfies"].count; j++ {
            let selfie = Selfie.init(json: json["selfies"][j])
            self.selfies.append(selfie)
        }
    }
    
    func GetUserSelfie(user: User) -> Selfie? {
        for var i = 0; i < self.selfies.count; i++ {
            let selfie = self.selfies[i]
            if selfie.user.id == user.id {
                // User's selfie
                return selfie
            }
        }
        return nil
    }
    
    func dateFromString(date: String, format: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(date)!
    }
    
}