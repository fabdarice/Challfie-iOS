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
        let nib = UINib(nibName: "ExtraPagesTVCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ExtraPagesCell")
        
        self.navigationItem.title = NSLocalizedString("about_us", comment: "About Us")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ExtraPagesCell") as! ExtraPagesTVCell
        
        cell.userInteractionEnabled = false
        cell.loadItem()
        switch indexPath.row {
        case 0 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = NSLocalizedString("about_us_text_one", comment: "About Us Part I")
        case 1 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = NSLocalizedString("about_us_text_two", comment: "About Us Part II")
        case 2 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = NSLocalizedString("about_us_text_three", comment: "About Us Part III")
            
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
