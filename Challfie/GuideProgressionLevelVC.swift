//
//  GuideProgressionLevelVC.swift
//  Challfie
//
//  Created by fcheng on 8/21/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class GuideProgressionLevelVC: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var skipTutorialButton: UIButton!
    @IBOutlet weak var nextBookProgressView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var nextLevelLabel: UILabel!
    @IBOutlet weak var nextBookViewHeightConstraint: NSLayoutConstraint!    
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextPageVerticalConstraint: NSLayoutConstraint!
    
    var from_facebook: Bool = false
    var percent:Int = 0
    var progressLayer : CAShapeLayer = CAShapeLayer()
    var progressTimer: NSTimer!
    var progresspercentNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = NSLocalizedString("tutorial_four_title", comment: "Congratulation on your first Challfie")
        self.descriptionLabel.text = NSLocalizedString("tutorial_four_description", comment: "")
        self.skipTutorialButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip the tutorial"), forState: UIControlState.Normal)
        self.nextPageButton.setTitle(NSLocalizedString("tutorial_four_button", comment: ""), forState: UIControlState.Normal)
        self.nextPageButton.layer.cornerRadius = 5
        self.nextPageButton.layer.borderWidth = 1.0
        self.nextPageButton.layer.borderColor = MP_HEX_RGB("1E3A75").CGColor
        
        self.nextLevelLabel.text = NSLocalizedString("next_level", comment: "Next Level")
        //self.percentageLabel.text = "10%"
        self.percent = 10
        
        self.percentageLabel.textColor = MP_HEX_RGB("8ceeff")
        self.nextLevelLabel.textColor = MP_HEX_RGB("C7F5FC")
        
        
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "iPhone 4":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
            nextBookViewHeightConstraint.constant = 180
        case "iPhone 4S":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
            nextBookViewHeightConstraint.constant = 180
        case "iPhone 5":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
            nextBookViewHeightConstraint.constant = 225
        case "iPhone 5c":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
            nextBookViewHeightConstraint.constant = 225
        case "iPhone 5s":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
            nextBookViewHeightConstraint.constant = 225
        case "iPhone 6" :
            descriptionBottomConstraint.constant = 40
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 40
            nextBookViewHeightConstraint.constant = 250
        case "iPhone 6 Plus" :
            descriptionBottomConstraint.constant = 50
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 19.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 40
            nextBookViewHeightConstraint.constant = 300
        default:
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
            nextBookViewHeightConstraint.constant = 225
        }
        
        self.createFullCircle()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Create Animated Circle Progress
        self.createProgressLayer()
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }

    func updateProgress() {
        if self.progresspercentNumber < 10 {
            self.progresspercentNumber += 1
            self.percentageLabel.text = self.progresspercentNumber.description + "%"
        } else {
            self.progressTimer.invalidate()
        }
    }

    // MARK: - Skip the Tutorial Action
    @IBAction func skipTutorialAction(sender: AnyObject) {
        if self.from_facebook == true {
            // Modal to Timeline TabBarViewCOntroller
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as HomeTBC
            homeTableViewController.from_facebook = self.from_facebook
            self.presentViewController(homeTableViewController, animated: true, completion: nil)
            
        } else {
            // Modal to LinkFacebook Tutorial Page
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var linkFacebookVC:LinkFacebookVC = mainStoryboard.instantiateViewControllerWithIdentifier("linkFacebookVC") as LinkFacebookVC
            self.presentViewController(linkFacebookVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK:: Next Page Action
    @IBAction func nextPageAction(sender: AnyObject) {
        // Push to GuideBookVC
        var guideBookVC = GuideBookVC(nibName: "GuideBook" , bundle: nil)
        guideBookVC.from_facebook = self.from_facebook
        
        self.presentViewController(guideBookVC, animated: true, completion: nil)
    }
    
    
    func createFullCircle() {        
        // Where is start
        let arcCenter  = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: self.nextBookViewHeightConstraint.constant / 2)
        // Diameter
        let radius: CGFloat = CGFloat(self.nextBookViewHeightConstraint.constant / 2 - 20)
        
        let startAngle: CGFloat = CGFloat(M_PI * 1.5)
        let endAngle: CGFloat = CGFloat(M_PI * 1.5 + (M_PI * 2))
        
        let circlePath : UIBezierPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Draw the full circle
        var fullcircleLayer : CAShapeLayer = CAShapeLayer()
        fullcircleLayer.path = circlePath.CGPath
        fullcircleLayer.strokeColor = MP_HEX_RGB("0F4352").CGColor
        fullcircleLayer.fillColor = UIColor.clearColor().CGColor
        fullcircleLayer.lineWidth = 10.0
        fullcircleLayer.strokeEnd = 100
        self.nextBookProgressView.layer.addSublayer(fullcircleLayer)
    }
    
    
    // Create Animated Circle Progress
    func createProgressLayer() {
        // Where is start
        let arcCenter  = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: self.nextBookViewHeightConstraint.constant / 2)
        // Diameter
        let radius: CGFloat = CGFloat(self.nextBookViewHeightConstraint.constant / 2 - 20)
        
        let startAngle: CGFloat = CGFloat(M_PI * 1.5)
        let endAngle: CGFloat = CGFloat(M_PI * 1.5 + (M_PI * 2))
        
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
        animation.duration = 2.0
        animation.delegate = self
        animation.removedOnCompletion = false
        animation.additive = true
        animation.fillMode = kCAFillModeForwards
        progressLayer.addAnimation(animation, forKey: "strokeEnd")
        self.nextBookProgressView.layer.addSublayer(progressLayer)
        
    }
    
}