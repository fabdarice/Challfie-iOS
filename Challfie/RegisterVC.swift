//
//  RegisterVC.swift
//  Challfie
//
//  Created by fcheng on 11/8/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
import Alamofire


class RegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordHelperLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MP_HEX_RGB("FFFFFF")
        
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
        
        // Do any additional setup after loading the view, typically from a nib.
        // set activityIndicator to hide when it's not spinning
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = MP_HEX_RGB("30768A")
    }
    
    
    @IBAction func createAccountButton(sender: UIButton) {
        self.activityIndicator.startAnimating()
        
        let parameters:[String: AnyObject] = [
            "login": self.usernameTextField.text,
            "firstname": self.firstnameTextField.text,
            "lastname": self.lastnameTextField.text,
            "password": self.passwordTextField.text,
            "email": self.emailTextField.text,
            "from_facebook": false,
            "from_mobileapp": true
        ]


        Alamofire.request(.POST, ApiLink.register, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
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
                        
                        
                        var alert = UIAlertController(title: NSLocalizedString("Account_creation_failed", comment: "Account creation failed"), message: error_message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // SUCCESS RSPONSE FROM HTTP Request
                        let login:String! = json["login"].string
                        let auth_token:String! = json["auth_token"].string
                        
                        // Save login and auth_token to the iOS Keychain
                        KeychainWrapper.setString(login, forKey: kSecAttrAccount)
                        KeychainWrapper.setString(auth_token, forKey: kSecValueData)
                        
                        // Modal to Timeline TabBarViewCOntroller
                        self.performSegueWithIdentifier("homeSegue2", sender: self)

                    }
                }
                self.activityIndicator.stopAnimating()
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}
