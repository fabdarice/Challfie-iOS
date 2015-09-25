//
//  GlobalFunctions.swift
//  Challfie
//
//  Created by fcheng on 1/17/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class GlobalFunctions {
    
    /// Function to push to my Profil
    func tapGestureToProfil(controller: UIViewController) {
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token
        ]
        
        Alamofire.request(.POST, ApiLink.show_my_profile, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    self.displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: controller)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    var current_user: User!
                    
                    if json["user"].count != 0 {
                        current_user = User.init(json: json["user"])
                    }
                    
                    // Push to OneSelfieVC
                    let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                    profilVC.user = current_user
                    controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                    controller.navigationController?.pushViewController(profilVC, animated: true)
                }
        }
        
    }
    
    
    // Function to push to Search Page
    func tapGestureToSearchPage(controller: UIViewController, backBarTitle: String) {
        // Push to SearchPage
        let searchUserVC = SearchUserVC(nibName: "SearchUser" , bundle: nil)
        controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: backBarTitle, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        controller.navigationController?.pushViewController(searchUserVC, animated: true)
        
    }
    
    // Display Alert
    func displayAlert(title title: String, message: String, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
}