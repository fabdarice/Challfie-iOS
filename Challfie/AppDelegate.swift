//
//  AppDelegate.swift
//  Challfie
//
//  Created by fcheng on 11/6/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        //KeychainWrapper.removeObjectForKey(kSecAttrAccount)
        //KeychainWrapper.removeObjectForKey(kSecValueData)
        
        // Change color of status bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var loginViewController:LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as LoginVC
        var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as HomeTBC
        
        let login = KeychainWrapper.stringForKey(kSecAttrAccount)
        let auth_token = KeychainWrapper.stringForKey(kSecValueData)
        
        if (login != nil && auth_token != nil) {
            let parameters:[String: AnyObject] = [
                "login": login!,
                "token": auth_token!
            ]
            
            // Check if the login and auth_token are valid for the user
            Alamofire.request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    println(mydata)
                    if (mydata == nil) {
                        self.window?.rootViewController = loginViewController
                    } else {
                        let json = JSON(mydata!)
                        if (json["success"].intValue == 0) {
                            self.window?.rootViewController = loginViewController
                        } else {
                            self.window?.rootViewController = homeTableViewController
                        }
                    }
            
            }
            //self.window?.rootViewController = homeTableViewController
        } else {
            self.window?.rootViewController = loginViewController
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

