//
//  ApiLinkVariable.swift
//  Challfie
//
//  Created by fcheng on 11/10/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

struct ApiLink {
    //static var host = "http://ADM-ML-C02MM24.local:3000"
    static var host = "https://challfie.com"
    
    // Register and Sign_in
    static var register = host + "/api/users"
    static var sign_in = host + "/api/users/sign_in"
    static var reset_password = host + "/api/users/password"
    static var facebook_register = host + "/api/users/facebook"
    static var facebook_link_account = host + "/api/user/facebook_link"
    
    // SelfieController
    static var timeline = host + "/api/selfies"
    static var selfies_refresh = host + "/api/selfies/refresh"
    static var selfie_approve = host + "/api/selfie/approve"
    static var selfie_reject = host + "/api/selfie/reject"
    static var selfie_list_comments = host + "/api/selfie/comments"
    static var show_selfie = host + "/api/selfie"
    static var create_selfie = host + "/api/selfie/create"
    static var flag_selfie = host + "/api/selfie/flag_selfie"
    static var delete_selfie = host + "/api/selfie/delete"
    static var list_approval = host + "/api/selfie/list_approval"
    static var list_reject = host + "/api/selfie/list_reject"
    
    // CommentController
    static var create_comment = host + "/api/comments"
    
    // AlertController - NotificationController
    static var alerts_list = host + "/api/notifications"
    static var alert_refresh = host + "/api/notifications/refresh"    
    static var alerts_all_read = host + "/api/notifications/all_read"
    
    // UsersController
    static var show_user_profile = host + "/api/user"
    static var show_my_profile = host + "/api/current_user"
    static var user_selfies = host + "/api/user/selfies"
    static var autocomplete_search_user = host + "/api/user/autocomplete_search_user"
    static var update_user = host + "/api/user/update"
    static var users_ranking = host + "/api/users/ranking"
    static var users_ranking_global  = host + "/api/users/ranking_global"
    
    // FriendsController
    static var suggestions_and_request = host + "/api/suggestions_and_request"
    static var following_list = host + "/api/following"
    static var followers_list = host + "/api/followers"
    static var unfollow = host + "/api/following/unfollow"
    static var remove_follower = host + "/api/followers/remove_follower"
    static var follow = host + "/api/follow"
    static var accept_request = host + "/api/accept_request"
    
    // BooksController
    static var books_list = host + "/api/books"
    static var level_progression = host + "/api/book/level_progression"
    
    // ChallengesController
    static var challenges_list = host + "/api/challenges"
    static var daily_challenge = host + "/api/daily_challenge"
    
    // ContactController 
    static var create_contact = host + "/api/contact/create"
    
    // DevicesController
    static var create_or_update_device = host + "/api/device/create"
    
    // AdministratorsController
    static var flag_selfies_list = host + "/api/admin/list_flag_selfies"
    static var block_selfie = host + "/api/admin/block_selfie"
    static var block_user = host + "/api/admin/block_user"
    static var clear_flag_selfie = host + "/api/admin/clear_flag_selfie"
    
}