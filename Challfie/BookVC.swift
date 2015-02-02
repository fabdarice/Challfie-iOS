//
//  BookVC.swift
//  Challfie
//
//  Created by fcheng on 1/11/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

import Alamofire

class BookVC : UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var booksTabHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBar_bookstab_vertical_constraint: NSLayoutConstraint!
    @IBOutlet weak var challengeBookButton: UIButton!
    @IBOutlet weak var profilImage: UIImageView!    
    @IBOutlet weak var searchImage: UIImageView!
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var books_array:[Book] = []
    var pageViewController: UIPageViewController?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Set Background color for topBar
        self.topBarView.backgroundColor = MP_HEX_RGB("30768A")
        
        // Book of Challenges Button
        self.challengeBookButton.setTitle(NSLocalizedString("book_of_challenges", comment: "Book of Challenges"), forState: UIControlState.Normal)
        
        // set link to my profil
        var myProfiltapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        myProfiltapGesture.addTarget(self, action: "tapGestureToProfil")
        self.profilImage.addGestureRecognizer(myProfiltapGesture)
        self.profilImage.userInteractionEnabled = true
        
        // set link to Search User xib
        var searchPagetapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        searchPagetapGesture.addTarget(self, action: "tapGestureToSearchPage")
        self.searchImage.addGestureRecognizer(searchPagetapGesture)
        self.searchImage.userInteractionEnabled = true
        
        // call API to load list of books of challenge
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // Hide navigationController
        self.navigationController?.navigationBar.hidden = true
    }

    func loadData() {
        self.loadingIndicator.startAnimating()
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!
        ]
        
        Alamofire.request(.POST, ApiLink.books_list, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println(mydata)
                    //Convert to SwiftJSON
                    var json = JSON(mydata!)
                    
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
                
                self.loadingIndicator.stopAnimating()
        }
        
    }
    
    /// Function to push to my Profil
    func tapGestureToProfil() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToProfil(self)
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
            let firstBookContentVC = getBookContentVC(0)!
            let startingViewControllers: NSArray = [firstBookContentVC]
            self.pageViewController?.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        let heightOtherView = self.topBarHeightConstraint.constant + self.booksTabHeightConstraint.constant + self.topBar_bookstab_vertical_constraint.constant
        
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
        return 0
    }


}