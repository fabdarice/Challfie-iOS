//
//  BookVC.swift
//  Challfie
//
//  Created by fcheng on 1/11/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

//import Alamofire

class BookVC : UIViewController, UIPageViewControllerDataSource, ENSideMenuDelegate {
    
    @IBOutlet weak var booksTabHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBar_bookstab_vertical_constraint: NSLayoutConstraint!
    @IBOutlet weak var challengeBookButton: UIButton!
    
    var books_array:[Book] = []
    var pageViewController: UIPageViewController?
    var last_book_unlocked_index: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        // navigationController Title
        let logoImageView = UIImageView(image: UIImage(named: "challfie_letter"))
        logoImageView.frame = CGRectMake(0.0, 0.0, 150.0, 35.0)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        // Add Delegate to SideMenu
        self.sideMenuController()?.sideMenu?.delegate = self
        
        // navigationController Left and Right Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Book of Challenges Button
        self.challengeBookButton.setTitle(NSLocalizedString("book_of_challenges", comment: "Book of Challenges"), forState: UIControlState.Normal)
        
        // call API to load list of books of challenge
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Show StatusBarBackground
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = false
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }

    func loadData() {
        // add loadingIndicator pop-up
        var loadingActivityVC = LoadingActivityVC(nibName: "LoadingActivity" , bundle: nil)
        loadingActivityVC.view.tag = 21
        self.view.addSubview(loadingActivityVC.view)
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        
        request(.POST, ApiLink.books_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                // Remove loadingIndicator pop-up
                if let loadingActivityView = self.view.viewWithTag(21) {
                    loadingActivityView.removeFromSuperview()
                }

                if (mydata == nil) {
                    GlobalFunctions().displayAlert(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), controller: self)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    println(json)
                    
                    if json["books"].count != 0 {
                        for var i:Int = 0; i < json["books"].count; i++ {
                            var book = Book.init(json: json["books"][i])
                            
                            if json["books"][i]["challenges"].count != 0 {
                                for var j:Int = 0; j < json["books"][i]["challenges"].count; j++ {
                                    var challenge = Challenge.init(json: json["books"][i]["challenges"][j])
                                    book.challenges_array.append(challenge)
                                }
                            }
                            self.books_array.append(book)
                        }
                    }                                                                                
                    
                }
                
                // call a function to initiate the UIPageViewController
                self.createPageViewController()
        }
        
    }
    
    // Function to push to Search Page
    func tapGestureToSearchPage() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: "Challenge")
        
    }
    
    
    // call a function to initiate the UIPageViewController
    func createPageViewController() {
        
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("booksPageVC") as? UIPageViewController
        self.pageViewController?.dataSource = self
        if self.books_array.count > 0 {
            for var i = 0; i < self.books_array.count; i++ {
                if self.books_array[i].is_unlocked == true && self.books_array[i].tier != 100 {
                    last_book_unlocked_index = i
                }
            }
            let lastBookContentVC = getBookContentVC(last_book_unlocked_index)!
            let startingViewControllers: NSArray = [lastBookContentVC]
            self.pageViewController?.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        let heightOtherView =  self.booksTabHeightConstraint.constant + self.topBar_bookstab_vertical_constraint.constant
        
        self.pageViewController?.view.frame = CGRectMake(0, heightOtherView, self.view.frame.size.width, self.view.frame.size.height - heightOtherView)
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)
    }
    
    // call a function to customize the layout of the Page Control Indicator
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = MP_HEX_RGB("C8DFE6")
        appearance.backgroundColor = MP_HEX_RGB("30768A")
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as BookPageContentVC
        if itemController.itemIndex > 0 {
            return getBookContentVC(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as BookPageContentVC
        
        if itemController.itemIndex+1 < self.books_array.count {
            return getBookContentVC(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    func getBookContentVC(itemIndex: Int) -> BookPageContentVC? {
        if itemIndex < self.books_array.count {
            let bookPageContent = BookPageContentVC(nibName: "BookPageContent", bundle: nil)
            bookPageContent.itemIndex = itemIndex
            bookPageContent.book = self.books_array[itemIndex]
            return bookPageContent
        }
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.books_array.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return last_book_unlocked_index
    }
    
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        // Add Tap gesture to Hide Side Menu
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideSideMenu")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func sideMenuWillClose() {
        // Remove Tap gesture to Hide Side Menu
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer as UIGestureRecognizer)
            }
        }
    }
    
    func toggleSideMenu() {
        toggleSideMenuView()
    }
    
    func hideSideMenu() {
        hideSideMenuView()
    }
    
}