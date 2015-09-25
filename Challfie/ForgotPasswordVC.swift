//
//  ForgotPasswordVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ForgotPasswordVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!    
    @IBOutlet weak var forgotPasswordTitleLabl: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var sendResetPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Textfield Delegate for hiding keyboard
        self.emailTextField.delegate = self
        
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "Email")
        self.forgotPasswordTitleLabl.text = NSLocalizedString("forgot_password_title", comment: "I forgot my password")
        self.signInButton.setTitle(NSLocalizedString("sign_in_challfie", comment: "Log in to Challfie"), forState: .Normal)
        self.sendResetPasswordButton.setTitle(NSLocalizedString("send_reset_password", comment: "Send Password Instructions"), forState: .Normal)
    }
    
    
    @IBAction func sendPasswordInstructionsButton(sender: UIButton) {

        // add loadingIndicator pop-up
        let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let parameters:[String: String] = [
            "email": self.emailTextField.text!
        ]
        
        Alamofire.request(.POST, ApiLink.reset_password, parameters: parameters, encoding: .JSON)
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
                    
                    if (json["success"].intValue == 0) {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: json["message"].stringValue, controller: self)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Email_sent", comment: "Email sent"), message: json["message"].stringValue, controller: self)
                    }
                }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}