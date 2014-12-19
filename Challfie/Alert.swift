//
//  Alert.swift
//  Challfie
//
//  Created by fcheng on 12/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation


class Alert {
    var id: Int!
    //var user_img: String!
    var author: User!
    var selfie_img: String!
    var book_img: String!
    var message: String!
    var time_ago: String!
    var type_notification: String!
    var read: Bool!
    
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.message = json["message"].stringValue
        //self.user_img = json["user_img"].stringValue
        self.selfie_img = json["selfie_img"].stringValue
        self.book_img = json["book_img"].stringValue
        self.time_ago = json["time_ago"].stringValue
        self.type_notification = json["type_notification"].stringValue
        self.read = json["read"].boolValue
    }
}