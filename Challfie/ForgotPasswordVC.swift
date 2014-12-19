//
//  ForgotPasswordVC.swift
//  Challfie
//
//  Created by fcheng on 11/12/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire

class ForgotPasswordVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        
        // Set Textfield Delegate for hiding keyboard
        self.emailTextField.delegate = self
    }
    
    
    @IBAction func sendPasswordInstructionsButton(sender: UIButton) {


        self.activityIndicator.startAnimating()
        let parameters:[String: AnyObject] = [
            "email": self.emailTextField.text            
        ]
        
        Alamofire.request(.POST, ApiLink.reset_password, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                
                    //convert to SwiftJSON
                    let json = JSON(mydata!)
                    
                    self.activityIndicator.stopAnimating()
                    if (json["success"].intValue == 0) {
                        var alert =  UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        var alert =  UIAlertController(title: NSLocalizedString("Email_sent", comment: "Email sent"), message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
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