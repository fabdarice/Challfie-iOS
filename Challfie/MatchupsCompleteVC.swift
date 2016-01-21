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

class MatchupsCompleteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parentController: MatchupsVC!
    var matchups_array: [Matchup] = []
    var loadMoreData: Bool = false
    var page = 1
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Bottom the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register the xib for the Custom TableViewCell
        let nib = UINib(nibName: "MatchupsTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "MatchupsCell")
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Add Google Tracker for Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Matchups - Complete")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
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
        
        Alamofire.request(.POST, ApiLink.complete_matchups, parameters: parameters, encoding: .JSON)
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
                    
                    print(json)
                    
                    if json["matchups"].count != 0 {
                        for var i:Int = 0; i < json["matchups"].count; i++ {
                            let matchup = Matchup.init(json: json["matchups"][i])
                            
                            self.matchups_array.append(matchup)
                        }
                        self.page += 1
                        self.loadMoreData = true
                        self.tableView.reloadData()
                    } else {
                        self.loadMoreData = false
                    }
                    self.tableView.tableFooterView = nil
                }
        }
    }
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchups_array.count
    }
 
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MatchupsCell") as! MatchupsTVCell
        
        let matchup = self.matchups_array[indexPath.row]
        cell.loadItem(matchup)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        if self.loadingIndicator.isAnimating() == false {
            if (indexPath.row == self.matchups_array.count - 1) && (self.loadMoreData == true) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                
                // Retrieve more Data (pagination)
                self.loadData(true)
            }
            
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell : MatchupsTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! MatchupsTVCell
        
        // Push to OneMatchupVC of the selected Row
        let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
        oneMatchUpVC.matchup = self.matchups_array[indexPath.row]
        
        oneMatchUpVC.hidesBottomBarWhenPushed = true
        
        self.parentController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.parentController.navigationController!.pushViewController(oneMatchUpVC, animated: true)
    }
    
}