//
//  TutorialVC.swift
//  Challfie
//
//  Created by fcheng on 3/26/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class TutorialVC : UIViewController, UIPageViewControllerDataSource {
 
    var pageViewController: UIPageViewController?
    var numberOfPages = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // call a function to initiate the UIPageViewController
        self.createPageViewController()
        
        // call a function to customize the layout of the Page Control Indicator
        //self.setupPageControl()
    }
    
    
    // call a function to initiate the UIPageViewController
    func createPageViewController() {
        
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("tutorialPageVC") as? UIPageViewController
        self.pageViewController?.dataSource = self
        
        let firstController = getTutorialPageContentVC(0)!
        let startingViewControllers: NSArray = [firstController]
        self.pageViewController?.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
        self.pageViewController?.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)
    }
    
    // call a function to customize the layout of the Page Control Indicator
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.redColor()
        appearance.currentPageIndicatorTintColor = MP_HEX_RGB("C8DFE6")
        appearance.backgroundColor = UIColor.clearColor()
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as TutorialPageContentVC
        if itemController.itemIndex > 0 {
            return getTutorialPageContentVC(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as TutorialPageContentVC
        
        if itemController.itemIndex+1 < self.numberOfPages {
            return getTutorialPageContentVC(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    func getTutorialPageContentVC(itemIndex: Int) -> TutorialPageContentVC? {
        let pageContent = TutorialPageContentVC(nibName: "TutorialPageContent", bundle: nil)
        pageContent.itemIndex = itemIndex
        pageContent.tutorialVC = self
        
        return pageContent
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.numberOfPages
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
