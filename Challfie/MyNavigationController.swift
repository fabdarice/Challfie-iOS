//
//  MyNavigationController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 30.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
//import Alamofire

class MyNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var menuTVC = MyMenuTableViewController()
        menuTVC.navController = self
                        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: menuTVC, menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 250.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false

        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
    }
    
    func sideMenuWillClose() {
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
