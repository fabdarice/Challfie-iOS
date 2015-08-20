//
//  ContactViewController.swift
//  Challfie
//
//  Created by fcheng on 2/26/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class ContactViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    var message_presence = false
    var contactType = [NSLocalizedString("report_bug", comment: "Report a bug"), NSLocalizedString("require_account_assistance", comment: "Request Assistance for your account"), NSLocalizedString("report_content", comment: "Report obscene, offensive content"), NSLocalizedString("give_suggestions", comment: "Give suggestions for the website"), NSLocalizedString("others", comment: "Others")]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("e9eaed")
        
        // UITextView settings
        self.textView.delegate = self
        self.textView.text = NSLocalizedString("add_message", comment: "Add a message..")
        self.textView.textColor = UIColor.lightGrayColor()
        self.textView.font = UIFont.italicSystemFontOfSize(13.0)
        self.textView.editable = true
        self.textView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.textView.layer.borderWidth = 1.0
        
        // pickerview
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.layer.borderColor = MP_HEX_RGB("C4C4C4").CGColor
        self.pickerView.layer.borderWidth = 1.0
       // let t0 = CGAffineTransformMakeTranslation (0, self.pickerView.bounds.size.height/2)
       // let s0 = CGAffineTransformMakeScale(1.0, 0.5)
       // let t1 = CGAffineTransformMakeTranslation (0, -self.pickerView.bounds.size.height/2)
       // self.pickerView.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1))
        
        // tapGesture to hide keyboard
        var tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        self.view.userInteractionEnabled = true
        
        self.navigationItem.title = "Contact Us"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
                
    }
    
    // Dismiss Searchbar Keyboard
    func dismissKeyboard() {
        self.textView.resignFirstResponder()
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
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.pickerView.transform = CGAffineTransformMakeTranslation(0.0, -140.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.textView.transform = CGAffineTransformMakeTranslation(0.0, -140.0)}, completion: nil)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.pickerView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.textView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)}, completion: nil)
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        var contactTypeInt: Int!
        
        // Add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        // -49 because of the height of the Tabbar ; -40 because of navigationController
        var newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
        loadingActivityVC.view.frame = newframe
        self.view.addSubview(loadingActivityVC.view)
        
        switch contactType[self.pickerView.selectedRowInComponent(0)] {
        case NSLocalizedString("report_bug", comment: "Report a Bug") :
            contactTypeInt = 1
        case NSLocalizedString("report_content", comment: "Report obscene, pornographic, offensive content") :
            contactTypeInt = 2
        case NSLocalizedString("require_account_assistance", comment: "Require Assistance for your account") :
            contactTypeInt = 3
        case NSLocalizedString("give_suggestions", comment: "Give suggestions for the website") :
            contactTypeInt = 4    
        case NSLocalizedString("others", comment: "Others") :
            contactTypeInt = 5
        default :
            contactTypeInt = 0
        }
    
        let parameters:[String: AnyObject] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "type_contact": contactTypeInt,
            "message": self.textView.text
        ]
        
        request(.POST, ApiLink.create_contact, parameters: parameters, encoding: .JSON)
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
                        // ERROR RESPONSE FROM HTTP Request
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Authentication_failed", comment: "Authentication Failed"), message: json["message"].stringValue, controller: self)
                    } else {
                        // SUCCESS RESPONSE FROM HTTP Request
                        GlobalFunctions().displayAlert(title: "Message Sent", message: json["message"].stringValue, controller: self)
                    }
                }
        }
        
    }
    
    //MARK: - UITextView Delegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if self.message_presence == false {
            self.textView.text = ""
            self.textView.textColor = UIColor.blackColor()
            self.textView.font = UIFont.systemFontOfSize(13.0)
            self.message_presence = true
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // hide keyboard when click on the "return" key
        if(text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    
    // MARK: - UIPickerViewDelegate & UIPickerViewDatasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.contactType.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.contactType[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = self.contactType[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        
        return pickerLabel
    }
    
}