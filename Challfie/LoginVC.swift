//
//  ViewController.swift
//  Challfie
//
//  Created by fcheng on 11/6/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // credential View Style
        self.credentialView.layer.cornerRadius = 4.0
        self.credentialView.layer.borderColor = MP_HEX_RGB("145466").CGColor
        self.credentialView.layer.borderWidth = 1.0
        
        // Login TextField Styke
        self.loginTextField.textColor = MP_HEX_RGB("000000")
        
        // Password Text Field Style
        self.passwordTextField.textColor = MP_HEX_RGB("000000")
        
        // Hide Password in TextField with *****
        self.passwordTextField.secureTextEntry = true

        // Register New Account Button Style
        self.createAccountButton.backgroundColor = MP_HEX_RGB("30768A")

        // Set Textfield Delegate for hiding keyboard
        self.loginTextField.delegate = self;
        self.passwordTextField.delegate = self;
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        let parameters:[String: AnyObject] = [
            "login": self.loginTextField.text,
            "password": self.passwordTextField.text
        ]
        
        
        Alamofire.request(.POST, ApiLink.sign_in, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
            println(mydata)
                
            if (mydata == nil) {
                var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                //convert to SwiftJSON
                let json = JSON(mydata!)
                
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
                    
                    
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    self.performSegueWithIdentifier("homeSegue", sender: self)
                    
                    
                    //                    [self performSegueWithIdentifier: @"MySegue" sender: self];
                    //self.presentViewController(firstView, animated: true, completion: nil)
                }
            }
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}

