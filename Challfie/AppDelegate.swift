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
        
        var loginViewController:LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginVC
        var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as! HomeTBC
        var guideVC:GuideVC = mainStoryboard.instantiateViewControllerWithIdentifier("guideVC") as! GuideVC
        
        var facebookUsernameViewController:FacebookUsernameVC = mainStoryboard.instantiateViewControllerWithIdentifier("facebookUsernameVC") as! FacebookUsernameVC

        let login = KeychainWrapper.stringForKey(kSecAttrAccount as String)
        let auth_token = KeychainWrapper.stringForKey(kSecValueData as String)
        
        var launchScreenVC = UIViewController(nibName: "LoadingLaunchScreen", bundle: nil)
        self.window?.rootViewController = launchScreenVC
        
        if (login != nil && auth_token != nil) {
            let parameters:[String: AnyObject] = [
                "login": login!,
                "token": auth_token!
            ]
            
            // Check if the login and auth_token are valid for the user
            request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata != nil) {
                        let json = JSON(mydata!)
                        if (json["success"].intValue == 1) {
                            let username_activated: Bool = json["username_activated"].boolValue
                            
                            // Activate the Background Fetch Mode to Interval Minimum
                            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                                UIApplicationBackgroundFetchIntervalMinimum)
                            
                            if username_activated == true {
                                self.window?.rootViewController = homeTableViewController
                                self.window?.rootViewController = guideVC
                            } else {
                                self.window?.rootViewController = facebookUsernameViewController
                            }
                            
                        } else {
                            KeychainWrapper.removeObjectForKey(kSecAttrAccount as String)
                            KeychainWrapper.removeObjectForKey(kSecValueData as String)
                            if let facebookSession = FBSession.activeSession() {
                                facebookSession.closeAndClearTokenInformation()
                                facebookSession.close()
                                FBSession.setActiveSession(nil)
                            }

                            self.window?.rootViewController = loginViewController
                        }
                    } else {
                        KeychainWrapper.removeObjectForKey(kSecAttrAccount as String)
                        KeychainWrapper.removeObjectForKey(kSecValueData as String)
                        if let facebookSession = FBSession.activeSession() {
                            facebookSession.closeAndClearTokenInformation()
                            facebookSession.close()
                            FBSession.setActiveSession(nil)
                        }

                        self.window?.rootViewController = loginViewController
                    }
            }
        } else {
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
        
        Siren.sharedInstance.checkVersion(.Daily)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("ENTER didRegisterForRemoteNotificationsWithDeviceToken")
        var deviceTokenStr = NSString(format: "%@", deviceToken)
        let login = KeychainWrapper.stringForKey(kSecAttrAccount as String)
        let auth_token = KeychainWrapper.stringForKey(kSecValueData as String)
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
        let facebookCallHandled = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        
        // You can add your app-specific url handling code here if needed
        return facebookCallHandled
    }
    
    
    func sessionStateChanged(session:FBSession, state:FBSessionState, error:NSError?) {
        
    }
    
    // MARK: - Fetch Data In Background Mode
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("ENTER performFetchWithCompletionHandler")
        if let homeTableViewController:HomeTBC = self.window?.rootViewController as? HomeTBC {
            // Fetch Data of Timeline Tab
            if let allTabViewControllers = homeTableViewController.viewControllers,
                navController:UINavigationController = allTabViewControllers[0] as? UINavigationController,
                timelineVC: TimelineVC = navController.viewControllers[0] as? TimelineVC {
                
                timelineVC.fetchDataInBackground({(result) in completionHandler(result) })
            }
        }
        
        
    }

}

