//
//  RankingVC.swift
//  Challfie
//
//  Created by fcheng on 10/28/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class RankingVC: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenFrame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.view.frame = screenFrame
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.navigationItem.title = NSLocalizedString("ranking_all_users_title", comment: "Ranking - All Users")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
        self.addTopMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    // MARK: - Add Top Menu
    func addTopMenu() {
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []

        let rankingFriendsController : RankingFriendsVC = RankingFriendsVC(nibName: "RankingFriends", bundle: nil)
        rankingFriendsController.title = NSLocalizedString("my_friends", comment: "My Friends")
        rankingFriendsController.parentController = self
        let _ = rankingFriendsController.view
        controllerArray.append(rankingFriendsController)
                
        let rankingAllUsersController : RankingAllUsersVC = RankingAllUsersVC(nibName: "RankingAllUsers", bundle: nil)
        rankingAllUsersController.title = NSLocalizedString("all_users", comment: "Top 100")
        rankingAllUsersController.parentController = self
        controllerArray.append(rankingAllUsersController)        
        
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
        print("RANKINGVC")
        print(self.view.frame)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
}
