//
//  RankingVC.swift
//  Challfie
//
//  Created by fcheng on 4/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class RankingVC : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var UsernameColumnLabel: UILabel!
    @IBOutlet weak var LevelColumnLabel: UILabel!
    @IBOutlet weak var progressColumnLabel: UILabel!
    @IBOutlet weak var rankColumnLabel: UILabel!
    @IBOutlet weak var friendsRankButton: UIButton!
    @IBOutlet weak var allUsersRankButton: UIButton!
    
    @IBOutlet weak var currentUserView: UIView!
    
    @IBOutlet weak var currentUsernameLabel: UILabel!
    @IBOutlet weak var currentUserRankLabel: UILabel!
    @IBOutlet weak var currentUserProfilPicImageView: UIImageView!
    @IBOutlet weak var currentUserProgressLabel: UILabel!    
    @IBOutlet weak var levelImageView: UIImageView!
    
    
    var page = 1
    var users_array : [User] = []
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        
        self.navigationItem.title = NSLocalizedString("ranking_title", comment: "Ranking")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
        
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        self.rankColumnLabel.text = NSLocalizedString("rank", comment: "Rank")
        self.UsernameColumnLabel.text = NSLocalizedString("user", comment: "User")
        self.LevelColumnLabel.text = NSLocalizedString("level", comment: "Level")
        self.progressColumnLabel.text = NSLocalizedString("progress", comment: "Progress")
        self.friendsRankButton.setTitle(NSLocalizedString("my_friends", comment: "My Friends"), forState: .Normal)
        self.allUsersRankButton.setTitle(NSLocalizedString("all_users", comment: "All Users"),  forState: .Normal)
        
        // Add Bottom the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "RankingTVCell", bundle: nil)
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

        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = false

        
        self.loadData(false)
    }
    
    // MARK: - Load/Fetch Data
    func loadData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            var newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            loadingActivityVC.view.frame = newframe
            
            self.view.addSubview(loadingActivityVC.view)
        }
        
        var keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "page": self.page.description
        ]
        
        request(.POST, ApiLink.users_ranking, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                // Remove loadingIndicator pop-up
                if pagination == true {
                    self.loadingIndicator.stopAnimating()
                } else {
                    if let loadingActivityView = self.view.viewWithTag(21) {
                        loadingActivityView.removeFromSuperview()
                    }
                }
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)

                    // Set Current_user row
                    var current_user = User.init(json: json["current_user"][0])
                    self.currentUserRankLabel.text = json["current_rank"].stringValue
                    // Username
                    self.currentUsernameLabel.text = current_user.username
                    self.currentUsernameLabel.textColor = MP_HEX_RGB("3E9AB5")
                    
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
                            var user = User.init(json: json["users"][i])
                            self.users_array.append(user)
                        }
                        self.page += 1
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
        var cell = tableView.dequeueReusableCellWithIdentifier("RankingCell") as! RankingTVCell
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
        
        return cell
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.loadingIndicator.isAnimating() == false {
            // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
            if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height * 0.66)) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                self.loadData(true)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : RankingTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! RankingTVCell
        
        // Push to ProfilVC of the selected Row
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.user
        profilVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }
    
    
    @IBAction func allUsersRankAction(sender: AnyObject) {
        var rankingAllusersVC = RankingAllUsersVC(nibName: "RankingAllUsers", bundle: nil)
        self.navigationController?.pushViewController(rankingAllusersVC, animated: true)
    }

}