//
//  FacebookUsername.swift
//  Challfie
//
//  Created by fcheng on 2/13/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class FacebookUsernameVC : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var setUsernameView: UIView!
    @IBOutlet weak var selectUsernameLabel: UILabel!
    @IBOutlet weak var usernameHelperLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var setUsernameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell Background
        //self.view.backgroundColor = MP_HEX_RGB("30768A")
        
        // View Border color
        self.setUsernameView.layer.borderColor = MP_HEX_RGB("308A6C").CGColor
        self.setUsernameView.layer.borderWidth = 1.0

        self.setUsernameButton.backgroundColor = MP_HEX_RGB("308A6C")
        self.selectUsernameLabel.textColor = UIColor.whiteColor()
        
        // Set Textfield Delegate for hiding keyboard
        self.usernameTextField.delegate = self
        
        // FR-EN
        self.selectUsernameLabel.text = NSLocalizedString("choose_username", comment: "Choose a Username")
        self.usernameHelperLabel.text = NSLocalizedString("only_alphanumeric", comment: "must contain only alphanumeric characters")
        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "Username") + " *"
        self.setUsernameButton.setTitle(NSLocalizedString("confirm", comment: "Confirm"), forState: UIControlState.Normal)
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
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.setUsernameView.transform = CGAffineTransformMakeTranslation(0.0, -60.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.selectUsernameLabel.transform = CGAffineTransformMakeTranslation(0.0, -60.0)}, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.setUsernameView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.selectUsernameLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate Delegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        self.validateUsernameButton(self.setUsernameButton)
        return true;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    @IBAction func validateUsernameButton(sender: AnyObject) {
        // add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "new_username": self.usernameTextField.text
        ]
                
        request(.POST, ApiLink.update_user, parameters: parameters, encoding: .JSON)
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
                    
                    if json["username"].count != 0 {
                        // ERROR VALIDATION OF USERNAME
                        var alert = UIAlertController(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["username"][0].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        let login:String! = json["user"]["username"].string
                        
                        // Save login and auth_token to the iOS Keychain
                        KeychainWrapper.setString(login, forKey: kSecAttrAccount)
                        
                        self.performSegueWithIdentifier("homeSegue3", sender: self)
                    }
                }
        }
        
    }
}