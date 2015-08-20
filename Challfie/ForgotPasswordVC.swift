//
//  ForgotPasswordVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class ForgotPasswordVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Textfield Delegate for hiding keyboard
        self.emailTextField.delegate = self
    }
    
    
    @IBAction func sendPasswordInstructionsButton(sender: UIButton) {

        // add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        
        let parameters:[String: AnyObject] = [
            "email": self.emailTextField.text            
        ]
        
        request(.POST, ApiLink.reset_password, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                
                    //convert to SwiftJSON
                    let json = JSON_SWIFTY(mydata!)
                    
                    if (json["success"].intValue == 0) {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: json["message"].stringValue, controller: self)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Email_sent", comment: "Email sent"), message: json["message"].stringValue, controller: self)
                    }
                }
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