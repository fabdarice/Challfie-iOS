//
//  MatchupsDailyVC.swift
//  Challfie
//
//  Created by fcheng on 10/28/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class MatchupsActiveVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parentController: MatchupsVC!
    var in_progress_matchups_array: [Matchup] = []
    var pending_matchups_array: [Matchup] = []
    var matchup_requests_array: [Matchup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "MatchupsTVCell", bundle: nil)
        //let nib_request = UINib(nibName: "MatchupsPendingTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "MatchupsCell")
        //self.tableView.registerNib(nib_request, forCellReuseIdentifier: "MatchupsPendingCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Matchups - Active")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    // MARK: - Load/Fetch Data
    func loadData() {
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token
        ]
        
        Alamofire.request(.POST, ApiLink.active_matchups, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in                
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    print(json)
                    
                    if json["matchups"].count != 0 {
                        for var i:Int = 0; i < json["matchups"].count; i++ {
                            let matchup = Matchup.init(json: json["matchups"][i])
                            
                            if matchup.status == MatchupStatus.Pending.rawValue {
                                if matchup.is_creator == true {
                                    self.pending_matchups_array.append(matchup)
                                } else {
                                    self.matchup_requests_array.append(matchup)
                                }
                                
                            }
                            if matchup.status == MatchupStatus.Accepted.rawValue {
                                self.in_progress_matchups_array.append(matchup)
                            }
                            
                        }
                        self.tableView.reloadData()
                    }
                    
                }
        }        
    }
    
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.matchup_requests_array.count
        } else {
            if section == 1 {
                return self.pending_matchups_array.count
            } else {
                return self.in_progress_matchups_array.count
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.matchup_requests_array.count == 0 {
                return 0.0
            } else {
                return 30.0
            }
        } else {
            if section == 1 {
                if self.pending_matchups_array.count == 0 {
                    return 0.0
                } else {
                    return 30.0
                }
            } else {
                return 30.0
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 30.0))
        headerView.backgroundColor = UIColor.whiteColor()
        let headerLabel = UILabel(frame: CGRectMake(0.0, 10.0, tableView.frame.width, 14.0))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        headerLabel.textColor = UIColor.blackColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        
        headerView.addSubview(headerLabel)
        
        if section == 0 {
            headerLabel.text = NSLocalizedString("request", comment: "REQUEST")
        } else {
            if section == 1 {
                headerLabel.text = NSLocalizedString("pending_response", comment: "PENDING RESPONSE")
            } else {
                headerLabel.text = NSLocalizedString("in_progress", comment: "IN PROGRESS")
            }
            
        }
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MatchupsCell") as! MatchupsTVCell
        
        var matchup: Matchup!
        
        if indexPath.section == 0 {
            matchup = self.matchup_requests_array[indexPath.row]
        } else {
            if indexPath.section == 1 {
                matchup = self.pending_matchups_array[indexPath.row]
            } else {
                matchup = self.in_progress_matchups_array[indexPath.row]
            }
            
        }
        
        cell.loadItem(matchup)
        
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

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell : MatchupsTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! MatchupsTVCell
        
        // Push to OneMatchupVC of the selected Row
        let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
        
        if indexPath.section == 0 {
            oneMatchUpVC.matchup = self.matchup_requests_array[indexPath.row]
        } else {
            if indexPath.section == 1 {
                oneMatchUpVC.matchup = self.pending_matchups_array[indexPath.row]
            } else {
                oneMatchUpVC.matchup = self.in_progress_matchups_array[indexPath.row]
            }
            
        }
                
        oneMatchUpVC.hidesBottomBarWhenPushed = true
        
        if oneMatchUpVC.matchup.status == MatchupStatus.Pending.rawValue {
            if oneMatchUpVC.matchup.is_creator == true {
                //Create the AlertController
                let actionSheetController: UIAlertController = UIAlertController(title: oneMatchUpVC.matchup.participants[0].username + " vs " + oneMatchUpVC.matchup.participants[1].username, message: oneMatchUpVC.matchup.challenge.description, preferredStyle: .Alert)
                
                //Create and add the Cancel action
                let closeAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                
                let RemoveAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("remove_matchup", comment: "Remove"), style: .Destructive) { action -> Void in
                    self.acceptRejectMatchup(2, matchupVC: oneMatchUpVC, indexPath: indexPath)
                }
                
                actionSheetController.addAction(RemoveAction)
                actionSheetController.addAction(closeAction)
                
                
                self.parentController.presentViewController(actionSheetController, animated: true, completion: nil)
                //Add a text field
            } else {
                //Create the AlertController
                let actionSheetController: UIAlertController = UIAlertController(title: oneMatchUpVC.matchup.participants[0].username + " vs " + oneMatchUpVC.matchup.participants[1].username, message: oneMatchUpVC.matchup.challenge.description, preferredStyle: .Alert)
                
                //Create and add the Cancel action
                let closeAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .Destructive) { action -> Void in
                    //Do some stuff
                }
                
                
                let acceptDuelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("accept_matchup", comment: "Accept"), style: .Default) { action -> Void in
                    self.acceptRejectMatchup(1, matchupVC: oneMatchUpVC, indexPath: indexPath)
                }
                let declineDuelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("decline_matchup", comment: "Decline"), style: .Default) { action -> Void in
                    self.acceptRejectMatchup(2, matchupVC: oneMatchUpVC, indexPath: indexPath)
                }
                
                actionSheetController.addAction(acceptDuelAction)
                actionSheetController.addAction(declineDuelAction)
                actionSheetController.addAction(closeAction)
                
                self.parentController.presentViewController(actionSheetController, animated: true, completion: nil)
                //Add a text field
            }
            
        }
        if oneMatchUpVC.matchup.status == MatchupStatus.Accepted.rawValue {

            self.parentController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

            self.parentController.navigationController!.pushViewController(oneMatchUpVC, animated: true)
        }
        
    }
    
    func acceptRejectMatchup(matchup_status: Int, matchupVC: OneMatchupVC, indexPath: NSIndexPath) {
        let keychain = Keychain(service: "challfie.app.service")
        let login = keychain["login"]!
        let auth_token = keychain["auth_token"]!
        
        let parameters:[String: String] = [
            "login": login,
            "auth_token": auth_token,
            "matchup_id": matchupVC.matchup.id.description,
            "matchup_status": matchup_status.description
        ]
        
        Alamofire.request(.POST, ApiLink.accept_reject_matchup, parameters: parameters, encoding: .JSON)
            .responseJSON { _, _, result in
                switch result {
                case .Failure(_, _):
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                case .Success(let mydata):
                    //Convert to SwiftJSON
                    var json = JSON(mydata)
                    
                    //print(json)
                    
                    if json["matchup"].count != 0 {
                        if matchup_status == 1 {
                            // Accepted
                            let matchup = Matchup.init(json: json["matchup"])
                            //let tmp_matchup = self.pending_matchups_array[indexPath.row]
                            //tmp_matchup.status = MatchupStatus.Accepted.rawValue
                            self.in_progress_matchups_array.append(matchup)
                            self.matchup_requests_array.removeAtIndex(indexPath.row)
                        } else {
                            self.pending_matchups_array.removeAtIndex(indexPath.row)
                            // Declined
                        }
                        self.tableView.reloadData()
                        self.parentController.navigationController?.pushViewController(matchupVC, animated: true)
                    } else {
                        GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                    }
                    
                }
        }
    }
}