//
//  AppDelegate.swift
//  Challfie
//
//  Created by fcheng on 11/6/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainAccess
import Armchair

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // Delete Keychain login & auth_token
        //KeychainInfo.login = nil
        //KeychainInfo.auth_token = nil
        
        // Change color of status bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var loginViewController:LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
        var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as! HomeTBC

        //var guideVC:GuideVC = mainStoryboard.instantiateViewControllerWithIdentifier("guideVC") as! GuideVC
        
        var facebookUsernameViewController:FacebookUsernameVC = mainStoryboard.instantiateViewControllerWithIdentifier("facebookUsernameVC") as! FacebookUsernameVC
        
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]
        let auth_token = keychain["auth_token"]
        
        var launchScreenVC = UIViewController(nibName: "LoadingLaunchScreen", bundle: nil)
        self.window?.rootViewController = launchScreenVC
        
        if (login != nil && auth_token != nil) {
            let parameters:[String: AnyObject] = [
                "login": login!,
                "token": auth_token!,
                "timezone": NSTimeZone.localTimeZone().name
            ]
            // Check if the login and auth_token are valid for the user
            request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    var keychain = Keychain(service: "challfie.app.service")
                    
                    if (mydata != nil) {
                        let json = JSON(mydata!)
                        if (json["success"].intValue == 1) {
                            let username_activated: Bool = json["username_activated"].boolValue
                            
                            // Activate the Background Fetch Mode to Interval Minimum
                            //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                                //UIApplicationBackgroundFetchIntervalMinimum)
                            
                            if username_activated == true {
                                self.window?.rootViewController = homeTableViewController
                                //self.window?.rootViewController = guideVC
                            } else {
                                self.window?.rootViewController = facebookUsernameViewController
                            }
                            
                        } else {
                            keychain["login"] = nil
                            keychain["auth_token"] = nil
                            // Logout FB if it was logged in
                            var facebookManager = FBSDKLoginManager()
                            facebookManager.logOut()
                            self.window?.rootViewController = loginViewController
                        }
                    } else {
                        // Logout FB if it was logged in
                        var facebookManager = FBSDKLoginManager()
                        facebookManager.logOut()
                        keychain["login"] = nil
                        keychain["auth_token"] = nil
                        self.window?.rootViewController = loginViewController
                    }
            }
        } else {
            // Logout FB if it was logged in
            var facebookManager = FBSDKLoginManager()
            facebookManager.logOut()
            self.window?.rootViewController = loginViewController
        }
        
        self.window?.makeKeyAndVisible()
        
        // Siren is a singleton
        let siren = Siren.sharedInstance
        
        // Required: Your app's iTunes App Store ID
        siren.appID = "974913351"
        
        // Optional: Defaults to .Option
        siren.alertType = .Option
        
        /*
        Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
        checks.
        */
        siren.checkVersion(.Immediately)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
        /*
        Useful if user returns to your app from the background after being sent to the
        App Store, but doesn't update their app before coming back to your app.
        
        ONLY USE WITH SirenAlertType.Force
        */
        
        Siren.sharedInstance.checkVersion(.Immediately)
    }

    

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        /*
        Perform daily (.Daily) or weekly (.Weekly) checks for new version of your app.
        Useful if user returns to your app from the background after extended period of time.
        Place in applicationDidBecomeActive(_:).   */
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]
        let auth_token = keychain["auth_token"]
        
        // Refresh Data if Users are currently signed in and current screen is timelineVC
        if (login != nil && auth_token != nil) {
            if let homeTableViewController:HomeTBC = self.window?.rootViewController as? HomeTBC,
                // Fetch Data of Timeline Tab
                allTabViewControllers = homeTableViewController.viewControllers,
                navController:UINavigationController = allTabViewControllers[0] as? UINavigationController,
                timelineVC: TimelineVC = navController.viewControllers[0] as? TimelineVC {
                    if homeTableViewController.selectedIndex == 0 && timelineVC.first_time == false {
                        timelineVC.backgroundRefresh()
                    }
            }
        }
        
        FBSDKAppEvents.activateApp()
        
        Siren.sharedInstance.checkVersion(.Daily)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var deviceTokenStr = NSString(format: "%@", deviceToken)
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]
        let auth_token = keychain["auth_token"]

        if (login != nil && auth_token != nil) {
            let parameters:[String: AnyObject] = [
                "login": login!,
                "auth_token": auth_token!,
                "device_token": deviceTokenStr,
                "type_device": "0",
                "active": "1"
            ]
            
            // update deviceToken
            request(.POST, ApiLink.create_or_update_device, parameters: parameters, encoding: .JSON)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("failed to register for remote notifications:  \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }

    // MARK: - Facebook Login to handle callback
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // You can add your app-specific url handling code here if needed
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)

    }
    
    
    // Set up Armchair
    override class func initialize() {
        super.initialize()

        Armchair.appID("974913351")
        Armchair.significantEventsUntilPrompt(10)
        Armchair.reviewMessage(NSLocalizedString("review_message", comment: "Review Message"))
        Armchair.reviewTitle(NSLocalizedString("review_title", comment: "Evalue Challfie"))
        Armchair.cancelButtonTitle(NSLocalizedString("no_thanks", comment: "No, Thanks"))
        Armchair.rateButtonTitle(NSLocalizedString("rate", comment: "Rate Challfie"))
        Armchair.remindButtonTitle(NSLocalizedString("remind_me_later", comment: "Remind me later"))
        Armchair.shouldPromptIfRated(true)
        Armchair.daysUntilPrompt(10)
        Armchair.usesUntilPrompt(20)
    }
    
    /*
    // MARK: - Fetch Data In Background Mode
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if let homeTableViewController:HomeTBC = self.window?.rootViewController as? HomeTBC,
            // Fetch Data of Timeline Tab
            allTabViewControllers = homeTableViewController.viewControllers,
            navController:UINavigationController = allTabViewControllers[0] as? UINavigationController,
            timelineVC: TimelineVC = navController.viewControllers[0] as? TimelineVC {
                timelineVC.fetchDataInBackground({(result) in completionHandler(result) })
        }
        
        
    }*/

}

