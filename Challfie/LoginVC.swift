//
//  ViewController.swift
//  Challfie
//
//  Created by fcheng on 11/6/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
//import Alamofire

class LoginVC: UIViewController, UITextFieldDelegate, FBLoginViewDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var facebookLoginView: FBLoginView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var credentialsBottomConstraint: NSLayoutConstraint!

    
    var first_facebook_login: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // credential View Style
        self.credentialView.layer.cornerRadius = 4.0
        self.credentialView.layer.borderColor = MP_HEX_RGB("145466").CGColor
        self.credentialView.layer.borderWidth = 1.0
        
        // Bottom View Layer Style
        self.bottomView.layer.borderColor = MP_HEX_RGB("145466").CGColor
        self.bottomView.layer.borderWidth = 1.0
        
        // Login Button Layer
        self.loginButton.layer.borderColor = MP_HEX_RGB("145466").CGColor
        self.loginButton.layer.borderWidth = 1.0
        
        // Login TextField Styke
        self.loginTextField.textColor = MP_HEX_RGB("000000")
        
        // Password Text Field Style
        self.passwordTextField.textColor = MP_HEX_RGB("000000")
        
        // self.registerButton.setTitleColor(MP_HEX_RGB("30768A"), forState: UIControlState.Normal)
        
        // Hide Password in TextField with *****
        self.passwordTextField.secureTextEntry = true
        

        // Set Textfield Delegate for hiding keyboard
        self.loginTextField.delegate = self;
        self.passwordTextField.delegate = self;

        // Facebook Login
        self.facebookLoginView.delegate = self
        self.facebookLoginView.readPermissions = ["public_profile", "email", "user_friends", "publish_actions"]    
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Add Notification for when the Keyboard pop up  and when it is dismissed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name:UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.credentialView.transform = CGAffineTransformMakeTranslation(0.0, -60.0)}, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.credentialView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
    }
    
    @IBAction func loginAction(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //let deviceToken = appDelegate.deviceToken
        
        // Add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)

        let parameters:[String: AnyObject] = [
            "login": self.loginTextField.text,
            "password": self.passwordTextField.text
        ]
        
        request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //convert to SwiftJSON
                    let json = JSON_SWIFTY(mydata!)
                    
                    if (json["success"].intValue == 0) {
                        // ERROR RESPONSE FROM HTTP Request
                        var alert = UIAlertController(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        let login:String! = json["login"].string
                        let auth_token:String! = json["auth_token"].string
                        
                        // Save login and auth_token to the iOS Keychain
                        KeychainWrapper.setString(login, forKey: kSecAttrAccount)
                        KeychainWrapper.setString(auth_token, forKey: kSecValueData)
                        
                        self.performSegueWithIdentifier("homeSegue", sender: self)
                    }
                }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UITextFieldDelegate Delegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        if textField == self.passwordTextField {
            self.loginAction(self.registerButton)
        }
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Facebook Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {        
        let login = KeychainWrapper.stringForKey(kSecAttrAccount)
        let auth_token = KeychainWrapper.stringForKey(kSecValueData)
        
        if self.first_facebook_login == false && login == nil && auth_token == nil {
            // add loadingIndicator pop-up
            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            self.view.addSubview(loadingActivityVC.view)
            
            self.first_facebook_login = true
            
            let fbAccessToken = FBSession.activeSession().accessTokenData.accessToken
            let fbTokenExpiresAt = FBSession.activeSession().accessTokenData.expirationDate.timeIntervalSince1970
            let userProfileImage = "http://graph.facebook.com/\(user.objectID)/picture?type=large"
            
            let parameters:[String: AnyObject] = [
                "uid": user.objectID,
                "login": user.name,
                "email": user.objectForKey("email"),
                "firstname": user.first_name,
                "lastname": user.last_name,
                "profilepic": userProfileImage,
                "fbtoken": fbAccessToken,
                "fbtoken_expires_at": fbTokenExpiresAt,
                "fb_locale": user.objectForKey("locale")
            ]
            
            
            request(.POST, ApiLink.facebook_register, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    // Remove loadingIndicator pop-up
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                    if (mydata == nil) {
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.first_facebook_login = false
                    } else {
                        //convert to SwiftJSON
                        let json = JSON_SWIFTY(mydata!)
                        
                        if (json["success"].intValue == 0) {
                            self.first_facebook_login = false
                            // ERROR RESPONSE FROM HTTP Request
                            var alert = UIAlertController(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        } else {
                            // SUCCESS RESPONSE FROM HTTP Request
                            let login:String! = json["login"].string
                            let auth_token:String! = json["auth_token"].string
                            let username_activated: Bool = json["username_activated"].boolValue

                            // Save login and auth_token to the iOS Keychain
                            KeychainWrapper.setString(login, forKey: kSecAttrAccount)
                            KeychainWrapper.setString(auth_token, forKey: kSecValueData)
                            
                            if username_activated == true {
                                // User has already set his Challfie Username
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as HomeTBC
                                // Add Background for status bar
                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                appDelegate.window?.rootViewController = homeTableViewController
                                self.presentViewController(homeTableViewController, animated: true, completion: nil)
                            } else {
                                // User needs to set his Challfie username since coming from Facebook
                                self.performSegueWithIdentifier("setFacebookUsernameSegue", sender: self)
                            }                            
                        }
                    }
            }
        }
        
    }
    
    
}

