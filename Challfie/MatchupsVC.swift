//
//  MatchupsVC.swift
//  Challfie
//
//  Created by fcheng on 10/28/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation


class MatchupsVC: UIViewController {
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.navigationItem.title = NSLocalizedString("matchups", comment: "Duels")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let dailyMatchupsVC : MatchupsDailyVC = MatchupsDailyVC(nibName: "MatchupsDaily", bundle: nil)
        dailyMatchupsVC.title = NSLocalizedString("matchups_daily", comment: "DAILY")
        dailyMatchupsVC.parentController = self
        controllerArray.append(dailyMatchupsVC)
        
        let friendsMatchupsVC : MatchupsFriendsVC = MatchupsFriendsVC(nibName: "MatchupsFriends", bundle: nil)
        friendsMatchupsVC.title = NSLocalizedString("matchups_friends", comment: "FRIENDS")
        friendsMatchupsVC.parentController = self
        controllerArray.append(friendsMatchupsVC)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            // Background when scrolling outside of bounds
            .ViewBackgroundColor(UIColor.whiteColor()),
            // Color of the line for selected Menu
            .SelectionIndicatorColor(MP_HEX_RGB("3E9AB5")),
            //Set font for Menu
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
            // Menu Item Width
            .MenuItemWidth(UIScreen.mainScreen().bounds.width / 2),
            // Background color of the Menu Scroll
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            // Color of unselected MenuItem
            .UnselectedMenuItemLabelColor(UIColor.blackColor()),
            // Color of selected MenuItem
            .SelectedMenuItemLabelColor(MP_HEX_RGB("3E9AB5")),
            .BottomMenuHairlineColor(UIColor.grayColor()),
            .MenuMargin(0)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)        
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
    
}