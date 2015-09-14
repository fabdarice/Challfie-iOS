//
//  RegisterVC.swift
//  Challfie
//
//  Created by fcheng on 11/8/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess


class RegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordHelperLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var createNewAccountLabel: UILabel!    
    @IBOutlet weak var eulaLabel: UILabel!
    @IBOutlet weak var alreadyAccount: UIButton!
    @IBOutlet weak var passwordHelper: UILabel!    
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MP_HEX_RGB("FFFFFF")

        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "Username")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password") + " *"
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "Email")
        self.firstnameTextField.placeholder = NSLocalizedString("Firstname", comment: "First name")
        self.lastnameTextField.placeholder = NSLocalizedString("Lastname", comment: "Last name")
        self.createNewAccountLabel.text = NSLocalizedString("new_account_title", comment: "New account on Challfie")
        self.createAccountButton.setTitle(NSLocalizedString("Create_account", comment: "Create Account"), forState: .Normal)
        self.passwordHelperLabel.text = NSLocalizedString("Password_helper", comment: "* Password must be at least 8 characters long")
        self.alreadyAccount.setTitle(NSLocalizedString("already_an_account", comment: "Already an account"), forState: .Normal)
        
        // Eula
        self.eulaLabel.text = NSLocalizedString("eula", comment: "by signing up for this account, you agree to the terms and conditions")
        self.eulaLabel.font = UIFont.italicSystemFontOfSize(10.0)
        
        
        // password Helper Style
        self.passwordHelperLabel.font = UIFont.italicSystemFontOfSize(10.0)
        
        // Set TextFieldDelegate
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self

        // Hide Password in TextField with *****
        self.passwordTextField.secureTextEntry = true
        
        
        
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
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.registerView.transform = CGAffineTransformMakeTranslation(0.0, -65.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.createNewAccountLabel.transform = CGAffineTransformMakeTranslation(0.0, -65.0)}, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.registerView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.createNewAccountLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
    }
    
    
    @IBAction func createAccountButton(sender: AnyObject) {
        // add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let parameters:[String: AnyObject] = [
            "login": self.usernameTextField.text,
            "firstname": self.firstnameTextField.text,
            "lastname": self.lastnameTextField.text,
            "password": self.passwordTextField.text,
            "email": self.emailTextField.text,
            "from_facebook": false,
            "from_mobileapp": true
        ]


        request(.POST, ApiLink.register, parameters: parameters, encoding: .JSON)
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
                        // ERROR RSPONSE FROM HTTP Request
                        var error_message: String = ""
                        if (json["message"]["username"] != nil) {
                            error_message += "\n" + NSLocalizedString("Username", comment: "Username") + " : " + json["message"]["username"][0].stringValue
                        }
                        if (json["message"]["password"] != nil) {
                            error_message += "\n" + NSLocalizedString("Password", comment: "Password") + " : " + json["message"]["password"][0].stringValue
                        }
                        if (json["message"]["email"] != nil) {
                            error_message += "\nEmail : " + json["message"]["email"][0].stringValue
                        }
                        if (json["message"]["firstname"] != nil) {
                            error_message += "\n" + NSLocalizedString("Firstname", comment: "Firsname") + " : " + json["message"]["firstname"][0].stringValue
                        }
                        if (json["message"]["lastname"] != nil) {
                            error_message += "\n" + NSLocalizedString("Lastname", comment: "Lastname") + " : " + json["message"]["lastname"][0].stringValue
                        }
                        
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Account_creation_failed", comment: "Account creation failed"), message: error_message, controller: self)
                    } else {
                        // SUCCESS RSPONSE FROM HTTP Request
                        let login:String! = json["login"].string
                        let auth_token:String! = json["auth_token"].string
                        
                        var keychain = Keychain(service: "challfie.app.service")
                        // Save login and auth_token to the iOS Keychain
                        keychain["login"] = login
                        keychain["auth_token"] = auth_token
                        
                        // Modal to GuideVC
                        //self.performSegueWithIdentifier("homeSegue2", sender: self)
                        self.performSegueWithIdentifier("registerSegue", sender: self)

                    }
                }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField {
            self.emailTextField.becomeFirstResponder()
        }
        if textField == self.emailTextField {
            self.firstnameTextField.becomeFirstResponder()
        }
        if textField == self.firstnameTextField {
            self.lastnameTextField.becomeFirstResponder()
        }
        if textField == self.lastnameTextField {
            self.createAccountButton(self)
        }
        
        return true;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}
