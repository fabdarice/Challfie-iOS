//
//  MatchupsFriendsVC.swift
//  Challfie
//
//  Created by fcheng on 10/28/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class MatchupsRankingVC: UIViewController {
    
    var parentController: MatchupsVC!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Matchups - Ranking")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
}