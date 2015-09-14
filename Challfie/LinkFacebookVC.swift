//
//  LinkFacebookVC.swift
//  Challfie
//
//  Created by fcheng on 4/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainAccess

class LinkFacebookVC: UIViewController {
    
    @IBOutlet weak var linkFacebookTitle: UILabel!
    @IBOutlet weak var linkInfoLabel: UILabel!
    @IBOutlet weak var searchFacebookFriendsButton: UIButton!
    @IBOutlet weak var skipStepButton: UIButton!
    
    var is_Facebook_linked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.linkFacebookTitle.text = NSLocalizedString("link_facebook_title", comment: "Link Your Facebook Account")
        self.linkInfoLabel.text = NSLocalizedString("link_facebook_info", comment: "* we will never post anything on your timeline without your permission")
        self.searchFacebookFriendsButton.setTitle(NSLocalizedString("link_facebook_button", comment: "Search for your Facebook Friends"), forState: UIControlState.Normal)
        self.skipStepButton.setTitle(NSLocalizedString("skip_link_facebook_step", comment: "Skip this step"), forState: .Normal)
        
        self.linkInfoLabel.font = UIFont.italicSystemFontOfSize(13.0)
        
        self.searchFacebookFriendsButton.layer.cornerRadius = 5
        self.searchFacebookFriendsButton.layer.borderWidth = 1.0
        self.searchFacebookFriendsButton.layer.borderColor = MP_HEX_RGB("1E3A75").CGColor
    }
    
    @IBAction func linkFacebookAcct(sender: AnyObject) {
        var fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
            if (error != nil) {
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
            } else {
                self.linkWithFacebook()
            }
        })
        
        /*
        FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: {
                (session:FBSession!, state:FBSessionState, error:NSError!) in
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                appDelegate.sessionStateChanged(session, state: state, error: error)
                if FBSession.activeSession().isOpen {
                    FBRequestConnection.startForMeWithCompletionHandler({ (connection, user, error) -> Void in
                        if (error != nil) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        } else {
                            // add loadingIndicator pop-up
                            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                            loadingActivityVC.view.tag = 21            
                            self.view.addSubview(loadingActivityVC.view)
                            
                            let user_uid: String = user.objectForKey("id") as! String
                            let user_lastname = user.objectForKey("last_name") as! String
                            let user_firstname = user.objectForKey("first_name") as! String
                            let user_locale = user.objectForKey("locale") as! String
                            
                            let fbAccessToken = FBSession.activeSession().accessTokenData.accessToken
                            let fbTokenExpiresAt = FBSession.activeSession().accessTokenData.expirationDate.timeIntervalSince1970
                            
                            let parameters:[String: AnyObject] = [
                                "login": KeychainInfo.login,
                                "auth_token": KeychainInfo.auth_token,
                                "uid": user_uid,
                                "firstname": user_firstname,
                                "lastname": user_lastname,
                                "fbtoken": fbAccessToken,
                                "fbtoken_expires_at": fbTokenExpiresAt,
                                "fb_locale": user_locale,
                                "isPublishPermissionEnabled": false
                            ]
                            
                            request(.POST, ApiLink.facebook_link_account, parameters: parameters, encoding: .JSON)
                                .responseJSON { (_, _, mydata, _) in
                                    // Remove loadingIndicator pop-up
                                    if let loadingActivityView = self.view.viewWithTag(21) {
                                        loadingActivityView.removeFromSuperview()
                                    }
                                    if (mydata == nil) {
                                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                                    } else {
                                        //convert to SwiftJSON
                                        let json = JSON(mydata!)
                                        
                                        if (json["success"].intValue == 0) {
                                            // ERROR RESPONSE FROM HTTP Request
                                            GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)
                                        } else {
                                            self.is_Facebook_linked = true
                                            // Modal to Timeline TabBarViewCOntroller
                                            self.performSegueWithIdentifier("homeSegueFromFacebook", sender: self)
                                        }
                                    }
                                    
                            }
                            
                        }
                        
                    })
                }
        })*/
    }
    
    func linkWithFacebook()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email,first_name,last_name,locale"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
            } else {
                // add loadingIndicator pop-up
                var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
                loadingActivityVC.view.tag = 21
                self.view.addSubview(loadingActivityVC.view)
                
                let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let fbTokenExpiresAt = FBSDKAccessToken.currentAccessToken().expirationDate.timeIntervalSince1970
                var user_id = result.valueForKey("id") as! String
                let userProfileImage = "http://graph.facebook.com/\(user_id)/picture?type=large"
                var email = ""
                var facebook_locale: String = "en_US"
                
                if result.valueForKey("email") == nil {
                    email = user_id + "@facebook.com"
                } else {
                    email = result.valueForKey("email") as! String
                }
                
                if result.valueForKey("locale") != nil {
                    facebook_locale = result.valueForKey("locale") as! String
                }
                
                var keychain = Keychain(service: "challfie.app.service")
                let login = keychain["login"]!
                let auth_token = keychain["auth_token"]!

                let parameters:[String: AnyObject] = [
                    "login": login,
                    "auth_token": auth_token,
                    "uid": user_id,
                    "firstname": result.valueForKey("first_name") as! String,
                    "lastname": result.valueForKey("last_name") as! String ,
                    "fbtoken": fbAccessToken,
                    "fbtoken_expires_at": fbTokenExpiresAt,
                    "fb_locale": facebook_locale
                ]
                
                request(.POST, ApiLink.facebook_link_account, parameters: parameters, encoding: .JSON)
                    .responseJSON { (_, _, mydata, _) in
                        // Remove loadingIndicator pop-up
                        if let loadingActivityView = self.view.viewWithTag(21) {
                            loadingActivityView.removeFromSuperview()
                        }
                        if (mydata == nil) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                        } else {
                            
                            //convert to SwiftJSON
                            let json = JSON(mydata!)

                            if (json["success"].intValue == 0) {
                                // ERROR RESPONSE FROM HTTP Request
                                GlobalFunctions().displayAlert(title: "Facebook Authentication", message: json["message"].stringValue, controller: self)
                            } else {
                                self.is_Facebook_linked = true
                                // Modal to Timeline TabBarViewCOntroller
                                self.performSegueWithIdentifier("homeSegueFromFacebook", sender: self)
                            }
                        }
                        
                }
            }
        })
    }
        
    @IBAction func skipTestButton(sender: AnyObject) {
        // Modal to Timeline TabBarViewCOntroller
        self.performSegueWithIdentifier("homeSegueFromFacebook", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "homeSegueFromFacebook") && (self.is_Facebook_linked == true) {
            var tabBar: HomeTBC = segue.destinationViewController as! HomeTBC
            tabBar.selectedIndex = 3
        }
    }
}
