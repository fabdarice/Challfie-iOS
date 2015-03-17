//
//  ChallengeVC.swift
//  Challfie
//
//  Created by fcheng on 12/4/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation
//import Alamofire

class ChallengeVC : UIViewController {
    
    @IBOutlet weak var bookProgressView: UIView!
//    @IBOutlet weak var topBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var nextBookProgressHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progresspercentageLabel: UILabel!
    @IBOutlet weak var progressNextLevelLabel: UILabel!
    @IBOutlet weak var separator3Image: UIImageView!
    @IBOutlet weak var levelProgressionLabel: UILabel!
    @IBOutlet weak var currentLeveLabel: UILabel!    
    @IBOutlet weak var currentLevelTitle: UILabel!
    @IBOutlet weak var nextLevelLabel: UILabel!
    @IBOutlet weak var nextLevelTitle: UILabel!
    @IBOutlet weak var challengeBookButton: UIButton!
    @IBOutlet weak var bookProgressViewHeightConstraint: NSLayoutConstraint!
    
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var percent:Int = 0
    var progressLayer : CAShapeLayer = CAShapeLayer()
    //var fullcircleLayer : CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling the navigationController
        self.navigationController?.navigationBar.barTintColor = MP_HEX_RGB("30768A")
        self.navigationController?.navigationBar.tintColor = MP_HEX_RGB("FFFFFF")
        self.navigationController?.navigationBar.translucent = false
        
        // navigationController Title
        let logoImageView = UIImageView(image: UIImage(named: "challfie_letter"))
        logoImageView.frame = CGRectMake(0.0, 0.0, 150.0, 35.0)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        // navigationController Left and Right Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapGestureToSearchPage")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabBar_Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleSideMenu")
        
        // Styling Background
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Label Color
        self.progresspercentageLabel.textColor = MP_HEX_RGB("8ceeff")
        self.levelProgressionLabel.textColor = MP_HEX_RGB("8ceeff")
        self.progressNextLevelLabel.textColor = MP_HEX_RGB("C7F5FC")
        self.progressNextLevelLabel.text = NSLocalizedString("next_level", comment: "Next Level")
        self.currentLevelTitle.text = NSLocalizedString("current_level", comment: "Current Level") + " : "
        self.nextLevelTitle.text = NSLocalizedString("next_level", comment: "Next Level") + " : "
        
        // Book of Challenges Button
        self.challengeBookButton.setTitle(NSLocalizedString("book_of_challenges", comment: "Book of Challenges"), forState: UIControlState.Normal)
        
        // Separator Color
        self.separator3Image.backgroundColor = MP_HEX_RGB("30768A")
        
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName

        switch model {
        case "iPhone 4": bookProgressViewHeightConstraint.constant = 180
        case "iPhone 4S": bookProgressViewHeightConstraint.constant = 180
        case "iPhone 5": bookProgressViewHeightConstraint.constant = 225
        case "iPhone 5c": bookProgressViewHeightConstraint.constant = 225
        case "iPhone 5s": bookProgressViewHeightConstraint.constant = 225
        case "iPhone 6" : bookProgressViewHeightConstraint.constant = 250
        case "iPhone 6 Plus" : bookProgressViewHeightConstraint.constant = 300
        default:
            bookProgressViewHeightConstraint.constant = 225
        }        
        
        self.createFullCircle()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display tabBarController
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.hidden = false
        
        // remove progressLayer to refresh with new one
        self.progressLayer.removeFromSuperlayer()
        
        // show navigation and don't hide on swipe & keboard Appears
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        
        // call API to load level Progression
        loadData()
    }
        
    func toggleSideMenu() {
        toggleSideMenuView()
    }
    
    func loadData() {
        self.loadingIndicator.startAnimating()
        let parameters:[String: String] = [
            "login": KeychainWrapper.stringForKey(kSecAttrAccount)!,
            "auth_token": KeychainWrapper.stringForKey(kSecValueData)!            
        ]
        
        request(.POST, ApiLink.level_progression, parameters: parameters, encoding: .JSON)
            .responseJSON { (_, _, mydata, _) in
                if (mydata == nil) {
                    var alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Generic_error", comment: "Generic error"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //Convert to SwiftJSON
                    var json = JSON_SWIFTY(mydata!)
                    
                    // Update Badge of Alert TabBarItem
                    var alert_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[4] as UITabBarItem
                    if json["new_alert_nb"] != 0 {
                        alert_tabBarItem.badgeValue = json["new_alert_nb"].stringValue
                    } else {
                        alert_tabBarItem.badgeValue = nil
                    }
                    
                    // Update Badge of Friends TabBarItem
                    var friend_tabBarItem : UITabBarItem = self.tabBarController?.tabBar.items?[3] as UITabBarItem
                    if json["new_friends_request_nb"] != 0 {
                        friend_tabBarItem.badgeValue = json["new_friends_request_nb"].stringValue
                    } else {
                        friend_tabBarItem.badgeValue = nil
                    }
                    
                    // Set value of current level / next level / and level progression percentage
                    self.percent = json["progress_percentage"].intValue
                    self.progresspercentageLabel.text = json["progress_percentage"].stringValue + "%"
                    self.currentLeveLabel.text = json["current_level"].stringValue
                    self.nextLevelLabel.text = json["next_level"].stringValue
                    
                    // Create Animated Circle Progress
                    self.createProgressLayer()
                }
                
                self.loadingIndicator.stopAnimating()
        }
    }
    
    func createFullCircle() {
        // Display our percentage as a string
        let textContent = self.percent
        
        // Where is start
        let arcCenter  = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: self.bookProgressViewHeightConstraint.constant / 2)
        // Diameter
        let radius: CGFloat = CGFloat(self.bookProgressViewHeightConstraint.constant / 2 - 20)
        
        let startAngle: CGFloat = CGFloat(M_PI * 1.5)
        let endAngle: CGFloat = CGFloat(M_PI * 1.5 + (M_PI * 2))
        //let test = (endAngle - startAngle) * (self.percent / 100.0) + startAngle
        
        let circlePath : UIBezierPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Draw the full circle
        var fullcircleLayer : CAShapeLayer = CAShapeLayer()
        fullcircleLayer.path = circlePath.CGPath
        fullcircleLayer.strokeColor = MP_HEX_RGB("0F4352").CGColor
        fullcircleLayer.fillColor = UIColor.clearColor().CGColor
        fullcircleLayer.lineWidth = 10.0
        fullcircleLayer.strokeEnd = 100
        self.bookProgressView.layer.addSublayer(fullcircleLayer)
    }
    
    
    // Create Animated Circle Progress
    func createProgressLayer() {
        // Where is start
        let arcCenter  = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: self.bookProgressViewHeightConstraint.constant / 2)
        // Diameter
        let radius: CGFloat = CGFloat(self.bookProgressViewHeightConstraint.constant / 2 - 20)
        
        let startAngle: CGFloat = CGFloat(M_PI * 1.5)
        let endAngle: CGFloat = CGFloat(M_PI * 1.5 + (M_PI * 2))
        //let test = (endAngle - startAngle) * (self.percent / 100.0) + startAngle
        
        let circlePath : UIBezierPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Draw the circle corresponding to the progression of the user
        
        progressLayer.path = circlePath.CGPath
        progressLayer.strokeColor = MP_HEX_RGB("ffcc66").CGColor
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(self.percent)/100
        animation.duration = 1.0
        animation.delegate = self
        animation.removedOnCompletion = false
        animation.additive = true
        animation.fillMode = kCAFillModeForwards
        progressLayer.addAnimation(animation, forKey: "strokeEnd")
        //var gradientMaskLayer = gradientMask(colorTop: MP_HEX_RGB("FFD700").CGColor, colorBottom: MP_HEX_RGB("FFD700").CGColor)
        //gradientMaskLayer.mask = progressLayer
        self.bookProgressView.layer.addSublayer(progressLayer)
        
    }
    
    // Function to push to Search Page
    func tapGestureToSearchPage() {
        var globalFunctions = GlobalFunctions()
        globalFunctions.tapGestureToSearchPage(self, backBarTitle: "Challenge")
        
    }            
}