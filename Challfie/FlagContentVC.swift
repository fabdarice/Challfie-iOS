//
//  FlagContentVC.swift
//  Challfie
//
//  Created by fcheng on 6/24/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class FlagContentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,ENSideMenuDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var page = 1
    var flag_selfie_array:[Selfie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        
        // Add Delegate to SideMenu
        self.sideMenuController()?.sideMenu?.delegate = self
        
        // navigationController Title
        let logoImageView = UIImageView(image: UIImage(named: "challfie_letter"))
        logoImageView.frame = CGRectMake(0.0, 0.0, 150.0, 35.0)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        // navigationController Left and Right Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
        // Remove tableview Inset Separator
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Initialize the loading Indicator
        self.loadingIndicator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)
        self.loadingIndicator.tintColor = MP_HEX_RGB("30768A")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "FlagContentTVCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FlagContentCell")
        
        // Set the height of a cell dynamically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        // Add right swipe gesture hide Side Menu
        var ensideNavBar = self.navigationController as MyNavigationController
        var ensideMenu :ENSideMenu = ensideNavBar.sideMenu!
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showSideMenu")
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        let rightSwipeGestureRecognizer2 = UISwipeGestureRecognizer(target: self, action: "showSideMenu")
        rightSwipeGestureRecognizer2.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer2.delegate = self
        ensideMenu.sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer2)
        
        // Add left swipe gesture Show Side Menu
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "hideSideMenu")
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        let leftSwipeGestureRecognizer2 = UISwipeGestureRecognizer(target: self, action: "hideSideMenu")
        leftSwipeGestureRecognizer2.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer2.delegate = self
        ensideMenu.sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer2)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Load data
        self.page = 1
        self.flag_selfie_array.removeAll(keepCapacity: false)
        self.loadData()
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false

    }
    
    
    // Retrive list of selfies to a user timeline
    func loadData() {
        self.loadingIndicator.startAnimating()
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!,
            "page": self.page.description
        ]
        
        request(.POST, ApiLink.flag_selfies_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    if json["administrators"].count != 0 {
                        for var i:Int = 0; i < json["administrators"].count; i++ {
                            var selfie = Selfie.init(json: json["administrators"][i])
                            var user: User = User.init(json: json["administrators"][i]["user"])
                            selfie.user = user
                            self.flag_selfie_array.append(selfie)
                        }
                        self.page += 1
                        self.tableView.reloadData()
                    }
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - tableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var cell: FlagContentTVCell = tableView.dequeueReusableCellWithIdentifier("FlagContentCell") as FlagContentTVCell
        
        var selfie: Selfie = self.flag_selfie_array[indexPath.row]
        cell.loadItem(selfie)
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flag_selfie_array.count
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.loadingIndicator.isAnimating() == false {
            // Check if the user has scrolled down to the end of the view -> if Yes -> Load more content
            if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
                // Add Loading Indicator to footerView
                self.tableView.tableFooterView = self.loadingIndicator
                // Load Next Page of Selfies for User Timeline
                self.loadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selfie: Selfie = self.flag_selfie_array[indexPath.row]
        
        // Push to OneSelfieVC
        var oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
        oneSelfieVC.selfie = selfie
        oneSelfieVC.is_administrator = true
        
        // Hide TabBar when push to OneSelfie View
        self.hidesBottomBarWhenPushed = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Alert_tab", comment: "Alert"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.pushViewController(oneSelfieVC, animated: true)
    }
    
    // MARK: - UIGestureDelegate
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    func toggleSideMenu() {
        toggleSideMenuView()
    }
    
    func hideSideMenu() {
        hideSideMenuView()
    }
    
    func showSideMenu() {
        showSideMenuView()
    }


}