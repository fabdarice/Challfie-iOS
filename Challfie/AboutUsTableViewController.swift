//
//  TermsTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
//import Alamofire

class AboutUsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        // Customize apperance of table view
        //tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.whiteColor()
        //tableView.scrollsToTop = false
        
        
        // Set the height of a cell dynamically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "ExtraPagesTVCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ExtraPagesCell")
        
        self.navigationItem.title = "About Us"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExtraPagesCell") as ExtraPagesTVCell
        
        cell.userInteractionEnabled = false
        cell.loadItem()
        switch indexPath.row {
        case 0 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = "Challfie is a social network that takes selfies to the next level by adding a fun and competitive spin."
        case 1 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = "It incorporates the concept of challenges that users must complete and have approved by their friends. \nThe more challenges that are completed and approved, the more points users earn, allowing them to reach higher levels and unlock new challenges."
        case 2 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = "So grab your camera and take your first Challfie!"
            
        default :
            cell.titleLabel.text = ""
            cell.messageLabel.text = ""
        }
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
    
}
