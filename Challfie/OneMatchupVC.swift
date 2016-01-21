//
//  OneMatchupVC.swift
//  Challfie
//
//  Created by fcheng on 11/4/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class OneMatchupVC: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    
    var matchup: Matchup!
    var pageMenu : CAPSPageMenu?
    var timer = NSTimer()
    var matchupEnded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if self.matchup != nil {

            var user: User!
            var opponent: User!
            
            user = self.matchup.participants[0]
            opponent = matchup.participants[1]
            
            self.title = user.username + " vs " + opponent.username
            
            // Test if Matchup has ended
            if self.matchup.end_date == nil {
                self.timerLabel.text = "Matchup Pending.."
            } else {
                if self.matchup.end_date.timeIntervalSinceNow.isSignMinus {
                    // matchup's end_date is equal or after now
                    timer.invalidate()
                    self.matchupEnded = true
                    if matchup.matchup_winner != nil {
                        self.timerLabel.text = NSLocalizedString("winner_matchup", comment: "Winner") + " : " + matchup.matchup_winner
                    } else {
                        if self.matchup.status == MatchupStatus.EndedWithDraw.rawValue {
                            self.timerLabel.text = NSLocalizedString("tie_matchup", comment: "It's a tie")
                        } else {
                            self.timerLabel.text = NSLocalizedString("matchup_has_ended", comment: "Duel has ended")
                        }
                        
                    }
                } else {
                    // matchup's end_date is earlier than now
                    self.updateCounter()
                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "updateCounter", userInfo: nil, repeats: true)
                    self.matchupEnded = false
                }
            }
            
            self.challengeLabel.text = self.matchup.challenge.description
            self.challengeLabel.sizeToFit()            

            self.addTopMenu()
        } else {
            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
        }
 
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "One Matchup")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        
        self.tabBarController?.tabBar.hidden = true           
    }

    
    // MARK: - Add Top Menu
    func addTopMenu() {
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        var user: User!
        var opponent: User!
        
        user = self.matchup.participants[0]
        opponent = matchup.participants[1]
        
        let user_selfie = matchup.GetUserSelfie(user)
        let opponent_selfie = matchup.GetUserSelfie(opponent)
        
        if user_selfie == nil {
            // User hasn't taken his selfie yet
            let takeMatchupPictureVC = TakeMatchupPictureVC(nibName: "TakeMatchupPicture", bundle: nil)
            takeMatchupPictureVC.title = user.username
            takeMatchupPictureVC.user = user
            takeMatchupPictureVC.matchup = self.matchup
            takeMatchupPictureVC.parentController = self
            takeMatchupPictureVC.matchupEnded = self.matchupEnded
            controllerArray.append(takeMatchupPictureVC)
        } else {
            let oneSelfieVC = OneSelfieVC(nibName: "OneSelfieForMatchup" , bundle: nil)
            oneSelfieVC.selfie = user_selfie
            //let selfie1 = Selfie(id: 2)
            //oneSelfieVC.selfie = selfie1
            oneSelfieVC.title = user.username + " (" + (user_selfie?.nb_upvotes.description)! + ")"
            oneSelfieVC.isMatchup = true
            oneSelfieVC.to_bottom = false
            oneSelfieVC.parentController = self
            oneSelfieVC.matchupEnded = self.matchupEnded
            controllerArray.append(oneSelfieVC)
        }
        
        if opponent_selfie == nil {
            // Opponent hasn't taken his selfie yet
            // User hasn't taken his selfie yet
            let oppTakeMatchupPictureVC = TakeMatchupPictureVC(nibName: "TakeMatchupPicture", bundle: nil)
            oppTakeMatchupPictureVC.title = opponent.username
            oppTakeMatchupPictureVC.user = opponent
            oppTakeMatchupPictureVC.matchup = self.matchup
            oppTakeMatchupPictureVC.parentController = self
            oppTakeMatchupPictureVC.matchupEnded = self.matchupEnded
            controllerArray.append(oppTakeMatchupPictureVC)
        } else {
            let opponentOneSelfieVC = OneSelfieVC(nibName: "OneSelfieForMatchup" , bundle: nil)
            opponentOneSelfieVC.selfie = opponent_selfie
            opponentOneSelfieVC.title = opponent.username + " (" + (opponent_selfie?.nb_upvotes.description)! + ")"
            opponentOneSelfieVC.isMatchup = true
            opponentOneSelfieVC.to_bottom = false
            opponentOneSelfieVC.parentController = self
            opponentOneSelfieVC.matchupEnded = self.matchupEnded
            controllerArray.append(opponentOneSelfieVC)
        }
        
        let parameters: [CAPSPageMenuOption] = [
            // Background when scrolling outside of bounds
            .ViewBackgroundColor(UIColor.whiteColor()),
            // Color of the line for selected Menu
            .SelectionIndicatorColor(MP_HEX_RGB("FFCF66")),
            //Set font for Menu
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
            // Menu Item Width
            .MenuItemWidth(UIScreen.mainScreen().bounds.width / 2),
            // Background color of the Menu Scroll
            .ScrollMenuBackgroundColor(MP_HEX_RGB("1A596B")),
            // Color of unselected MenuItem
            .UnselectedMenuItemLabelColor(MP_HEX_RGB("FFFFFF")),
            // Color of selected MenuItem
            .SelectedMenuItemLabelColor(MP_HEX_RGB("FFCF66")),
            .BottomMenuHairlineColor(UIColor.grayColor()),
            .MenuMargin(0)
            
        ]
        
        let topViewHeight = 10.0 + self.timerLabel.bounds.height + 10.0 + 1.0 + 10.0 + self.challengeLabel.bounds.height + 10.0
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, topViewHeight, self.view.frame.width, self.view.frame.height - topViewHeight), pageMenuOptions: parameters)
                
        self.addChildViewController(pageMenu!)
        
        //pageMenu!.view.frame = CGRectMake(0.0, topViewHeight, self.view.frame.width, self.view.frame.height - topViewHeight)
        //pageMenu!.view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight] // modify this line as you like
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        
        pageMenu!.didMoveToParentViewController(self)
        
    }
    
    func updateCounter() {
        if self.matchup.end_date != nil {
            let timeLeft = self.matchup.end_date.timeIntervalSinceNow
            self.timerLabel.text = NSLocalizedString("time_left", comment: "Time left") + " : " + timeLeft.time
        }
    }
}

extension NSTimeInterval {
    var time:String {
        if Int((self/86400)) == 0 {
            return String(format:"%02dh %02dm %02ds", Int((self/3600.0)%24), Int((self/60.0)%60), Int((self)%60))
        } else {
            return String(format:"%02dd %02dh %02dm %02ds", Int((self/86400)), Int((self/3600.0)%24), Int((self/60.0)%60), Int((self)%60))
        }
        
        
    }
}