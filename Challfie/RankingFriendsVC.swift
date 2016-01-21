//
//  RankingFriendsVC.swift
//  Challfie
//
//  Created by fcheng on 4/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class RankingFriendsVC : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var UsernameColumnLabel: UILabel!
    @IBOutlet weak var LevelColumnLabel: UILabel!
    @IBOutlet weak var progressColumnLabel: UILabel!
    @IBOutlet weak var rankColumnLabel: UILabel!
    
    @IBOutlet weak var currentUserView: UIView!
    
    @IBOutlet weak var currentUsernameLabel: UILabel!
    @IBOutlet weak var currentUserRankLabel: UILabel!
    @IBOutlet weak var currentUserProfilPicImageView: UIImageView!
    @IBOutlet weak var currentUserProgressLabel: UILabel!    
    @IBOutlet weak var levelImageView: UIImageView!
    
    
    var page = 1
    var users_array : [User] = []
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var parentController: UIViewController!
    var loadMoreData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        self.rankColumnLabel.text = NSLocalizedString("rank", comment: "Rank")
        self.UsernameColumnLabel.text = NSLocalizedString("user", comment: "User")
        self.LevelColumnLabel.text = NSLocalizedString("level", comment: "Level")
        self.progressColumnLabel.text = NSLocalizedString("progress", comment: "Progress")        
        
        // Add Bottom the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "RankingTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "RankingCell")
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        //self.currentUserView.backgroundColor = MP_HEX_RGB("FAE0B1")
        self.currentUserView.layer.borderWidth = 1.0
        self.currentUserView.layer.borderColor = MP_HEX_RGB("000000").CGColor

        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Ranking Friends Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Load/Fetch Data
    func loadData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            let newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            loadingActivityVC.view.frame = newframe

            self.view.addSubview(loadingActivityVC.view)
        }
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "page": self.page.description
        ]
        
        Alamofire.request(.POST, ApiLink.users_ranking, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if pagination == true {
                    self.loadingIndicator.stopAnimating()
                } else {
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                }
                
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)

                    // Set Current_user row
                    let current_user = User.init(json: json["current_user"][0])
                    self.currentUserRankLabel.text = json["current_rank"].stringValue
                    // Username
                    self.currentUsernameLabel.text = current_user.username
                    self.currentUsernameLabel.textColor = UIColor.blackColor()
                    
                    // Level
                    let levelImageURL:NSURL = NSURL(string: current_user.show_book_image())!
                    self.levelImageView.hnk_setImageFromURL(levelImageURL)
                    
                    // Progression
                    self.currentUserProgressLabel.text = current_user.progression.description + "%"
                    
                    // User Profile Picture
                    if current_user.show_profile_pic() != "missing" {
                        let profilePicURL:NSURL = NSURL(string: current_user.show_profile_pic())!
                        self.currentUserProfilPicImageView.hnk_setImageFromURL(profilePicURL)
                    } else {
                        self.currentUserProfilPicImageView.image = UIImage(named: "missing_user")
                    }
                    self.currentUserProfilPicImageView.layer.cornerRadius = self.currentUserProfilPicImageView.frame.size.width / 2
                    self.currentUserProfilPicImageView.clipsToBounds = true
                    self.currentUserProfilPicImageView.layer.borderWidth = 2.0
                    self.currentUserProfilPicImageView.layer.borderColor = MP_HEX_RGB("FFFFFF").CGColor
                    
                    if current_user.book_tier == 1 {
                        self.currentUserProfilPicImageView.layer.borderColor = MP_HEX_RGB("bfa499").CGColor;
                        //self.currentUserLevelLabel.textColor = MP_HEX_RGB("0095AE")
                    }
                    if current_user.book_tier == 2 {
                        self.currentUserProfilPicImageView.layer.borderColor = MP_HEX_RGB("89b7b4").CGColor;
                        //self.currentUserLevelLabel.textColor = MP_HEX_RGB("63B54A")
                    }
                    if current_user.book_tier == 3 {
                        self.currentUserProfilPicImageView.layer.borderColor = MP_HEX_RGB("f1eb6c").CGColor;
                        //self.currentUserLevelLabel.textColor = MP_HEX_RGB("8258E5")
                    }                                        
                   
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            let user = User.init(json: json["users"][i])
                            self.users_array.append(user)
                        }
                        self.page += 1
                        self.loadMoreData = true
                    } else {
                        self.loadMoreData = false
                    }
                    
                    self.tableView.reloadData()                    
                }
                self.tableView.tableFooterView = nil
        }

    }
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users_array.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RankingCell") as! RankingTVCell
        cell.user = self.users_array[indexPath.row]
        cell.index = indexPath
        cell.loadItem()
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        if self.loadingIndicator.isAnimating() == false {
            if (indexPath.row == self.users_array.count - 1) && (self.loadMoreData == true) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                
                // Retrieve more Data (pagination)
                self.loadData(true)
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : RankingTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! RankingTVCell
        
        // Push to ProfilVC of the selected Row
        let profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.user
        profilVC.hidesBottomBarWhenPushed = true
        self.parentController.navigationController?.pushViewController(profilVC, animated: true)
    }
    

}