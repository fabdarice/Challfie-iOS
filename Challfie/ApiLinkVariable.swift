//
//  ApiLinkVariable.swift
//  Challfie
//
//  Created by fcheng on 11/10/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

struct ApiLink {
    static var host = "http://ADM-ML-C02MM24.local:3000"
    //static var host = "https://challfie.com"
    
    // Register and Sign_in
    static var register = host + "/api/users"
    static var sign_in = host + "/api/users/sign_in"
    static var reset_password = host + "/api/users/password"
    
    // SelfieController
    static var timeline = host + "/api/selfies"
    static var selfies_refresh = host + "/api/selfies/refresh"
    static var selfie_approve = host + "/api/selfie/approve"
    static var selfie_reject = host + "/api/selfie/reject"
    static var selfie_list_comments = host + "/api/selfie/comments"
    
    // CommentController
    static var create_comment = host + "/api/comments"
    
    
    // AlertController - NotificationController
    static var alerts_list = host + "/api/notifications"
    static var alert_refresh = host + "/api/notifications/refresh"    
    static var alerts_all_read = host + "/api/notifications/all_read"
    
    // FriendsController
    static var friends_list = host + "/api/friends"
    static var friend_refresh = host + "/api/friends/refresh"
    
}