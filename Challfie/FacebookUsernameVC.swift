//
//  FacebookUsername.swift
//  Challfie
//
//  Created by fcheng on 2/13/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class FacebookUsernameVC : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var setUsernameView: UIView!
    @IBOutlet weak var selectUsernameLabel: UILabel!
    @IBOutlet weak var usernameHelperLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var setUsernameButton: UIButton!        
    @IBOutlet weak var eulaLabel: UILabel!
    
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
        
        // Eula
        self.eulaLabel.text = NSLocalizedString("eula", comment: "by signing up for this account, you agree to the terms and conditions")
        self.eulaLabel.font = UIFont.italicSystemFontOfSize(10.0)

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
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.validateUsernameButton(self.setUsernameButton)
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func validateUsernameButton(sender: AnyObject) {
        // add loadingIndicator pop-up
        let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "new_username": self.usernameTextField.text!
        ]
                
        Alamofire.request(.POST, ApiLink.update_user, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //convert to SwiftJSON
                    let json = JSON(mydata)
                    
                    if json["username"].count != 0 {
                        // ERROR VALIDATION OF USERNAME
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["username"][0].stringValue, controller: self)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        let login:String! = json["user"]["username"].string
                        
                        // Save login and auth_token to the iOS Keychain
                        let keychain = Keychain(service: "challfie.app.service")
                        keychain["login"] = login
                        
                        self.performSegueWithIdentifier("facebookregisterSegue", sender: self)
                        
                    }
                }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "facebookregisterSegue") {
            let guideVC: GuideVC = segue.destinationViewController as! GuideVC
            guideVC.from_facebook = true
        }
    }
}