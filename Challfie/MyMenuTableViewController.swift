//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
//import Alamofire

class MyMenuTableViewController: UITableViewController {
    //var selectedMenuItem : Int = 5
    
    var navController : UINavigationController!
    var current_user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = MP_HEX_RGB("073340")
        tableView.bounces = false

        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        //tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch section {
        case 0 : return 1
        case 1 : return 2
        case 2 : return 4
        case 3 : return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
        }
        var imageView : UIImageView = UIImageView(frame: CGRectMake(10.0, 10.0, 20.0, 20.0))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        var textLabel : UILabel = UILabel(frame: CGRectMake(40.0, 10.0, cell!.frame.size.width - 7 - 20, 20.0))
        textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        textLabel.textColor = MP_HEX_RGB("D1D1D1")
        
        cell!.addSubview(imageView)
        cell!.addSubview(textLabel)
        
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.clearColor()
        cell!.selectedBackgroundView = selectedBackgroundView
        
        // Profile Section
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0 :
                textLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
                textLabel.textColor = MP_HEX_RGB("FFFFFF")
                
                // Get Current User
                let parameters:[String: String] = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
                ]
                
                request(.POST, ApiLink.show_my_profile, parameters: parameters, encoding: .JSON)
                    .responseJSON { (_, _, mydata, _) in
                        if (mydata == nil) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.navController)
                        } else {
                            //Convert to SwiftJSON
                            
                            var json = JSON_SWIFTY(mydata!)
                            
                            if json["user"].count != 0 {
                                self.current_user = User.init(json: json["user"])
                                if self.current_user.show_profile_pic() != "missing" {
                                    let profilePicURL:NSURL = NSURL(string: self.current_user.show_profile_pic())!
                                    imageView.hnk_setImageFromURL(profilePicURL)
                                } else {
                                   
                                    imageView.image = UIImage(named: "missing_user")
                                }
                                textLabel.text = self.current_user.username
                            }
                        }
                }
            default:
                textLabel.text = ""
            }
        }
        
        // Challenge Section
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0 :
                textLabel.text = NSLocalizedString("daily_challenge", comment: "Daily Challenge")
                imageView.image = UIImage(named: "icon_daily_challenge")
            case 1 :
                textLabel.text = NSLocalizedString("ranking", comment: "Ranking")
                imageView.image = UIImage(named: "icon_ranking")
            default:
                textLabel.text = ""
            }
        }
        
        // Extra Section
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0 :
                textLabel.text = NSLocalizedString("about_us", comment: "About us")
                imageView.image = UIImage(named: "icon_about_us")
            case 1 :
                textLabel.text = "Privacy"
                imageView.image = UIImage(named: "icon_privacy")
            case 2 :
                textLabel.text = "Terms"
                imageView.image = UIImage(named: "icon_terms")
            case 3 :
                textLabel.text = NSLocalizedString("contact_us", comment: "Contact us")
                imageView.image = UIImage(named: "icon_contact")
            default:
                textLabel.text = ""
            }
        }
        
        // Log Out Section
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0 :
                textLabel.text = NSLocalizedString("Log_out", comment: "Log Out")
                imageView.image = UIImage(named: "icon_log_out")
            default:
                textLabel.text = ""
            }
        }
        
        return cell!
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //if (indexPath.row == selectedMenuItem) {
        //    return
        //}
        //selectedMenuItem = indexPath.row
        
        
        // Cell Background Color
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = MP_HEX_RGB("165669")
        
        // hide sideMenu
        self.navController.hideSideMenuView()

        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var destViewController : UIViewController!

        switch (indexPath.section) {
        // Profile Section
        case 0:
            // My Profile
            let parameters:[String: String] = [
                "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
            ]
            
            request(.POST, ApiLink.show_my_profile, parameters: parameters, encoding: .JSON)
                .responseJSON { (_, _, mydata, _) in
                    if (mydata == nil) {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.navController)
                    } else {
                        //Convert to SwiftJSON
                        var json = JSON_SWIFTY(mydata!)
                        var current_user: User!
                        
                        if json["user"].count != 0 {
                            current_user = User.init(json: json["user"])
                        }
                        
                        // Push to OneSelfieVC
                        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
                        profilVC.user = current_user
                        self.navController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                        self.navController.pushViewController(profilVC, animated: true)
                        selectedCell.contentView.backgroundColor = UIColor.clearColor()
                    }
            }
            break
        // Challenge Section
        case 1:
            // Daily Challenge
            if indexPath.row == 0 {
                let parameters:[String: String] = [
                    "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
                    "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
                ]
                
                request(.POST, ApiLink.daily_challenge, parameters: parameters, encoding: .JSON)
                    .responseJSON { (_, _, mydata, _) in
                        if (mydata == nil) {
                            GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self.navController)
                        } else {
                            //Convert to SwiftJSON
                            var json = JSON_SWIFTY(mydata!)
                            GlobalFunctions().displayAlert(title: NSLocalizedString("daily_challenge", comment: "Daily Challenge"), message: json["daily_challenge"].stringValue, controller: self.navController)
                            selectedCell.contentView.backgroundColor = UIColor.clearColor()
                        }
                }
            }
            // Rank
            if indexPath.row == 1 {
                var rankingVC = RankingVC(nibName: "Ranking" , bundle: nil)
                self.navController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                self.navController.pushViewController(rankingVC, animated: true)                
                selectedCell.contentView.backgroundColor = UIColor.clearColor()
            }
            break
        // Extra Section
        case 2:
            // About Us
            if indexPath.row == 0 {
                var aboutUsTVC = AboutUsTableViewController()
                self.navController.pushViewController(aboutUsTVC, animated: true)
                selectedCell.contentView.backgroundColor = UIColor.clearColor()
            }
            
            // Privacy
            if indexPath.row == 1 {
                var privacyTVC = PrivacyTableViewController()
                self.navController.pushViewController(privacyTVC, animated: true)
                selectedCell.contentView.backgroundColor = UIColor.clearColor()
            }
            
            
            // Terms
            if indexPath.row == 2 {
                var termsTVC = TermsTableViewController()
                self.navController.pushViewController(termsTVC, animated: true)
                selectedCell.contentView.backgroundColor = UIColor.clearColor()
            }
            
            // Contact Us
            if indexPath.row == 3 {
                var contactVC = ContactViewController(nibName:"Contact", bundle: nil)
                self.navController.pushViewController(contactVC, animated: true)
                selectedCell.contentView.backgroundColor = UIColor.clearColor()
            }
            break
        case 3:
            // Log Out
            // Desactive Device so it can't receive push notifications
            let login = KeychainWrapper.stringForKey(kSecAttrAccount)
            let auth_token = KeychainWrapper.stringForKey(kSecValueData)
            if (login != nil && auth_token != nil) {
                let parameters:[String: AnyObject] = [
                    "login": login!,
                    "auth_token": auth_token!,
                    "type_device": "0",
                    "active": "0"
                ]
                // update deviceToken
                request(.POST, ApiLink.create_or_update_device, parameters: parameters, encoding: .JSON)
            }
            
            KeychainWrapper.removeObjectForKey(kSecAttrAccount)
            KeychainWrapper.removeObjectForKey(kSecValueData)
            if let facebookSession = FBSession.activeSession() {
                facebookSession.closeAndClearTokenInformation()
                facebookSession.close()
                FBSession.setActiveSession(nil)
            }
            var loginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as LoginVC
            // Desactive the Background Fetch Mode
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                UIApplicationBackgroundFetchIntervalNever)
            self.navController.presentViewController(loginVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.0
        } else if section == 3  || section == 4 {
            return 5.0
        } else {
            return 25.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0        
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 25.0))
        headerView.backgroundColor = MP_HEX_RGB("042A36")
        headerView.layer.borderColor = MP_HEX_RGB("01171F").CGColor
        headerView.layer.borderWidth = 1.0
        var headerLabel = UILabel(frame: CGRectMake(10.0, 5.0, tableView.frame.width, 15.0))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        headerLabel.textColor = MP_HEX_RGB("A3A3A3")
        
        
        headerView.addSubview(headerLabel)
        
        switch section {
        case 1 : headerLabel.text = "Challenge"
        case 2 : headerLabel.text = "Extra"
        default:
            headerLabel.text = ""
        }
        return headerView
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
