//
//  ViewController.swift
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

class LoginVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!

    
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
        self.loginButton.setTitle(NSLocalizedString("log_in", comment: "Log in"), forState: UIControlState.Normal)
        
        // Login TextField Styke
        self.loginTextField.textColor = MP_HEX_RGB("000000")
        self.loginTextField.placeholder = NSLocalizedString("Username", comment: "Username")
        
        // Password Text Field Style
        self.passwordTextField.textColor = MP_HEX_RGB("000000")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password")
        
        // Hide Password in TextField with *****
        self.passwordTextField.secureTextEntry = true
        
        self.forgotPasswordButton.setTitle(NSLocalizedString("forgot_password", comment: "Forgot your password?"), forState: .Normal)

        // Set Textfield Delegate for hiding keyboard
        self.loginTextField.delegate = self;
        self.passwordTextField.delegate = self;
        
        // Facebook Login
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        // Register new account Btn
        self.registerButton.setTitle(NSLocalizedString("register_new_account", comment: "Register new account"), forState: .Normal)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Add Notification for when the Keyboard pop up  and when it is dismissed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name:UIKeyboardDidHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Show or Hide Keyboard
    func keyboardDidShow(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.credentialView.transform = CGAffineTransformMakeTranslation(0.0, -60.0)}, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.credentialView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
    }
    
    // MARK: - login Action
    @IBAction func loginAction(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let parameters:[String: AnyObject] = [
            "login": self.loginTextField.text,
            "password": self.passwordTextField.text,
            "timezone": NSTimeZone.localTimeZone().name
        ]
        
        request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
            .responseJSON{ (_, _, mydata, _) in
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
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["message"].stringValue, controller: self)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        let login:String! = json["login"].string
                        let auth_token:String! = json["auth_token"].string
                        
                        // Save login and auth_token to the iOS Keychain
                        //KeychainInfo.login = login
                        //KeychainInfo.auth_token = auth_token
                        
                        var keychain = Keychain(service: "challfie.app.service")
                        // Save login and auth_token to the iOS Keychain
                        keychain["login"] = login
                        keychain["auth_token"] = auth_token
                        
                        // Activate the Background Fetch Mode to Interval Minimum
                        //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                          //  UIApplicationBackgroundFetchIntervalMinimum)
                        
                        self.performSegueWithIdentifier("homeSegue", sender: self)
                    }
                }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITextFieldDelegate Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.loginTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        
        if textField == self.passwordTextField {
            self.loginAction(self.registerButton)
        }
        return true;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil {
            self.loginWithFacebook()
        } else {
            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
    }
    
    
    func loginWithFacebook()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email,first_name,last_name,locale"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
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
                
                let parameters:[String: AnyObject] = [
                    "uid": user_id,
                    "login": result.valueForKey("name") as! String,
                    "email": email,
                    "firstname": result.valueForKey("first_name") as! String,
                    "lastname": result.valueForKey("last_name") as! String ,
                    "profilepic": userProfileImage,
                    "fbtoken": fbAccessToken,
                    "fbtoken_expires_at": fbTokenExpiresAt,
                    "fb_locale": facebook_locale,
                    "timezone": NSTimeZone.localTimeZone().name
                ]
                
                request(.POST, ApiLink.facebook_register, parameters: parameters, encoding: .JSON)
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
                                GlobalFunctions().displayAlert(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["message"].stringValue, controller: self)
                            } else {
                                // SUCCESS RESPONSE FROM HTTP Request
                                let login:String! = json["login"].string
                                let auth_token:String! = json["auth_token"].string
                                let username_activated: Bool = json["username_activated"].boolValue
                                
                                var keychain = Keychain(service: "challfie.app.service")
                                // Save login and auth_token to the iOS Keychain
                                keychain["login"] = login
                                keychain["auth_token"] = auth_token

                                if username_activated == true {
                                    // User has already set his Challfie Username
                                    // Activate the Background Fetch Mode to Interval Minimum
                                    //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                                      //  UIApplicationBackgroundFetchIntervalMinimum)
                                    
                                    self.performSegueWithIdentifier("homeSegue", sender: self)
                                } else {
                                    // User needs to set his Challfie username since coming from Facebook
                                    self.performSegueWithIdentifier("setFacebookUsernameSegue", sender: self)
                                }                            
                            }
                        }
                }
            }
        })
    }
    
    
}

