//
//  CreateMatchupVC.swift
//  Challfie
//
//  Created by fcheng on 10/30/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import KeychainAccess
import Alamofire
import SwiftyJSON


class CreateMatchupVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userLeftImageView: UIImageView!
    @IBOutlet weak var userRightImageView: UIImageView!
    
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var usernameLeftLabel: UILabel!
    @IBOutlet weak var usernameRightLabel: UILabel!
    
    @IBOutlet weak var statsLeftLabel: UILabel!
    @IBOutlet weak var statsRightLabel: UILabel!
   // @IBOutlet weak var selectDurationLabel: UILabel!
    
    @IBOutlet weak var createChallengeLabel: UILabel!
    @IBOutlet weak var selectChallengeLabel: UILabel!
    //@IBOutlet weak var challengeTextField: UITextField!
   // @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    var opponent: User!
    var duration: Int = 1
    var parentController: UIViewController!
    var isSelectedChallenge: Bool = false

    var challenges_array: [Challenge] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show navigationBar
        self.navigationController?.navigationBar.hidden = false
        self.title = ""
        let doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "createMatchup")
        doneItem.tintColor = MP_HEX_RGB("5BD9FC")
        self.navigationItem.rightBarButtonItem = doneItem

        self.textField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "ChallengeTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ChallengeCell")
        
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        
        self.usernameLeftLabel.text = login
        self.usernameRightLabel.text = self.opponent.username
        
        self.selectChallengeLabel.textColor = MP_HEX_RGB("1A596B")
        self.selectChallengeLabel.text = NSLocalizedString("select_from_the_list", comment: "Select from the list")
        self.createChallengeLabel.textColor = MP_HEX_RGB("1A596B")
        self.createChallengeLabel.text = NSLocalizedString("create_a_challenge", comment: "Create a challenge")
        //self.selectDurationLabel.textColor = MP_HEX_RGB("1A596B")
        
        
        //self.durationButton.backgroundColor = MP_HEX_RGB("FFFFFF")
        //self.durationButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        //self.durationButton.layer.borderColor = MP_HEX_RGB("145466").CGColor
        //self.durationButton.layer.borderWidth = 1.0
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.separatorColor = MP_HEX_RGB("C4C4C4")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 10.0

        
        // Display challenged user (Right Side) information
        if opponent.show_profile_pic() != "missing" {
            let profilePicURL:NSURL = NSURL(string: opponent.show_profile_pic())!
            self.userRightImageView.hnk_setImageFromURL(profilePicURL)
        } else {
            self.userRightImageView.image = UIImage(named: "missing_user")
        }
        // Set Profil Pic Frame and Gesture
        self.userRightImageView.layer.cornerRadius = self.userRightImageView.frame.size.width / 2
        self.userRightImageView.clipsToBounds = true
        
        // Set Profil Pic Frame and Gesture
        self.userLeftImageView.layer.cornerRadius = self.userLeftImageView.frame.size.width / 2
        self.userLeftImageView.clipsToBounds = true
        
        
        self.usernameRightLabel.text = self.opponent.username
        self.loadData()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Create Matchup Page")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
  
    // MARK: - Load Data Action Methods
    func loadData() {
        // add loadingIndicator pop-up
        let loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        // -49 because of the height of the Tabbar ; -40 because of navigationController
        let newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        loadingActivityVC.view.frame = newframe
        self.view.addSubview(loadingActivityVC.view)

        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "opponent_id": opponent.id.description
        ]
        
        Alamofire.request(.POST, ApiLink.new_matchup, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    print(json)
                    
                    if json != nil {
                        if json["matchups"].count != 0 {
                            for var i:Int = 0; i < json["matchups"].count; i++ {
                                if json["matchups"][i]["challenges"].count != 0 {
                                    for var j:Int = 0; j < json["matchups"][i]["challenges"].count; j++ {
                                        let challenge = Challenge.init(json: json["matchups"][i]["challenges"][j])
                                        self.challenges_array.append(challenge)
                                    }
                                }
                            }
                            
                            if json["meta"]["userProfilPic"].stringValue != "missing" {
                                let profilePicURL:NSURL = NSURL(string: json["meta"]["userProfilPic"].stringValue)!
                                self.userLeftImageView.hnk_setImageFromURL(profilePicURL)
                            } else {
                                self.userLeftImageView.image = UIImage(named: "missing_user")
                            }
                            
                            self.statsLeftLabel.text = json["meta"]["currentUserStats"].stringValue
                            self.statsRightLabel.text = json["meta"]["opponentStats"].stringValue

                            self.tableView.reloadData()
                        }
                    } else {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    }
                }
        }
    }
/*
    // MARK: - durationButtonAction() : Select duration Function
    @IBAction func durationButtonAction(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: "1 day", style: .Default) { (_) in
            self.durationButton.setTitle("1 day", forState: UIControlState.Normal)
            self.duration = 1
        }
        
        let twoAction = UIAlertAction(title: "2 days", style: .Default) { (_) in
            self.durationButton.setTitle("2 days", forState: UIControlState.Normal)
            self.duration = 2
        }
        
        let thirdAction = UIAlertAction(title: "3 days", style: .Default) { (_) in
            self.durationButton.setTitle("3 days", forState: UIControlState.Normal)
            self.duration = 3
        }
        
        let fourAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .Cancel) { (_) in
        }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(thirdAction)
        alert.addAction(fourAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
*/
    // MARK: - createMatchup Function
    func createMatchup() {
        // Check if a Challenge has been selected or crate
        let path = self.tableView.indexPathForSelectedRow
        var challenge_description = ""
        var challenge_id = ""
        var challenge_popup = ""
        
        if (path != nil) {
            // Retrieve selected challenge
            let selectedIndexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            let selected_challenge: Challenge = self.challenges_array[selectedIndexPath.row]
            challenge_id = selected_challenge.id.description
            challenge_popup = selected_challenge.description
        } else {
            if self.textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                challenge_description = self.textField.text!
                challenge_popup = self.textField.text!
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("create_selfie_missing_challenge", comment: "Please select a challenge."), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return ;
            }
        }

        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "opponent_id": opponent.id.description,
            "challenge_id": challenge_id,
            "description": challenge_description
        ]
        
        Alamofire.request(.POST, ApiLink.create_matchup, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    let json = JSON(mydata)
                    
                    if (json["success"].intValue == 1) {
                        //Create the AlertController
                        let actionSheetController: UIAlertController = UIAlertController(title: "fabdR vs Hermano", message: challenge_popup, preferredStyle: .Alert)
                        
                        //Close Action
                        let closeAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .Default) { action -> Void in
                            //Do some stuff
                            self.navigationController!.popViewControllerAnimated(true)
                        }
                        
                        //See Duel Action
                        let duelPageAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("view", comment: "View"), style: .Default) { action -> Void in
                            self.navigationController!.popViewControllerAnimated(true)
                            let matchupsVC = MatchupsVC(nibName: "Matchups" , bundle: nil)
                            matchupsVC.hidesBottomBarWhenPushed = true
                            self.parentController.navigationController!.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                            self.parentController.navigationController!.pushViewController(matchupsVC, animated: true)
                        }
                        actionSheetController.addAction(closeAction)
                        actionSheetController.addAction(duelPageAction)
                        self.presentViewController(actionSheetController, animated: true, completion: nil)
                        //Add a text field
                    } else {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    }
                }
        }
    }
    
    // MARK: - UITextField Functions Delegate Functions
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - UITABLEVIEW DELEGATE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.challenges_array.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        let cell: ChallengeTVCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! ChallengeTVCell
        
        let challenge: Challenge = self.challenges_array[indexPath.row]
        cell.challenge = challenge
        cell.loadItemForTakePicture()
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if tableView.indexPathForSelectedRow == indexPath {
            // Deselect already selected Row
            self.isSelectedChallenge = false
        } else {
            // Select a row
            self.isSelectedChallenge = true
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if self.isSelectedChallenge == true {
            selectedCell.contentView.backgroundColor = MP_HEX_RGB("FAE0B1")
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedCell.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        
    }
    
}