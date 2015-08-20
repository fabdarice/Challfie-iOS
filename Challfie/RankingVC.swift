//
//  RankingVC.swift
//  Challfie
//
//  Created by fcheng on 4/15/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class RankingVC : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var UsernameColumnLabel: UILabel!
    @IBOutlet weak var LevelColumnLabel: UILabel!
    @IBOutlet weak var progressColumnLabel: UILabel!
    
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
        
        self.loadData(false)
    }
    
    func loadData(pagination: Bool) {
        if pagination == true {
            self.loadingIndicator.startAnimating()
        } else {
            // add loadingIndicator pop-up
            var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
            loadingActivityVC.view.tag = 21
            // -49 because of the height of the Tabbar ; -40 because of navigationController
            var newframe = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 89)
            loadingActivityVC.view.frame = newframe
            
            self.view.addSubview(loadingActivityVC.view)
        }
        
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
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
                    var json = JSON_SWIFTY(mydata!)
                    
                    if json["users"].count != 0 {
                        for var i:Int = 0; i < json["users"].count; i++ {
                            var user = User.init(json: json["users"][i])
                            self.users_array.append(user)
                        }
                    }
                    self.page += 1
                    
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
        var cell = tableView.dequeueReusableCellWithIdentifier("RankingCell") as RankingTVCell
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
            if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                self.loadData(true)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : RankingTVCell = self.tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as RankingTVCell
        
        // Push to ProfilVC of the selected Row
        var profilVC = ProfilVC(nibName: "Profil" , bundle: nil)
        profilVC.user = cell.user
        
        self.navigationController?.pushViewController(profilVC, animated: true)
    }

}