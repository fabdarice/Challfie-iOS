//
//  GuideApproveSelfieVC.swift
//  Challfie
//
//  Created by fcheng on 8/21/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class GuideApproveSelfieVC : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!    
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var challengeApprovedImageView: UIImageView!
    @IBOutlet weak var skipTutorialButton: UIButton!    
    @IBOutlet weak var selfieLayoutView: UIView!
    @IBOutlet weak var nextPageButton: UIButton!
    
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextPageVerticalConstraint: NSLayoutConstraint!
    var from_facebook: Bool = false
    var selfie: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        self.challengeApprovedImageView.image = UIImage(named: "challenge_pending.png")
        self.selfieImageView.image = self.selfie
        self.challengeLabel.text = NSLocalizedString("take_a_selfie", comment: "Take a selfie")
        self.titleLabel.text = NSLocalizedString("tutorial_three_title", comment: "Congratulation on your first Challfie")
        self.descriptionLabel.text = NSLocalizedString("tutorial_three_description", comment: "")
        self.skipTutorialButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip the tutorial"), forState: UIControlState.Normal)
        self.nextPageButton.setTitle(NSLocalizedString("tutorial_three_button", comment: ""), forState: UIControlState.Normal)
   
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "iPhone 4":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
        case "iPhone 4S":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
        case "iPhone 5":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
        case "iPhone 5c":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
        case "iPhone 5s":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 30
        case "iPhone 6" :
            descriptionBottomConstraint.constant = 40
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 40
        case "iPhone 6 Plus" :
            descriptionBottomConstraint.constant = 50
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 19.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 40
        default:
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            nextPageVerticalConstraint.constant = 20
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Switch Pending Image to Approved with fade animation
        self.approveImageFadeIn()
    }
    
    // MARK: - Skip Tutorial Action
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
    
    // MARK: - Next Page Action
    @IBAction func nextPageAction(sender: AnyObject) {
        // Push to GuideProgressLevelVC
        var guideProgressLevelVC = GuideProgressionLevelVC(nibName: "GuideProgressionLevel" , bundle: nil)
        guideProgressLevelVC.from_facebook = self.from_facebook
        
        self.presentViewController(guideProgressLevelVC, animated: true, completion: nil)

    }
    
    
    // MARK: - Animation image Pending -> Approved
    func approveImageFadeIn() {
        
        //let approveImageView = UIImageView(image: UIImage(named: "challenge_approve.png"))
        //approveImageView.frame = self.challengeApprovedImageView.frame
        //approveImageView.alpha = 0.0
        
        //self.selfieLayoutView.insertSubview(approveImageView, aboveSubview: self.challengeApprovedImageView)
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut , animations: {
            self.challengeApprovedImageView.alpha = 0.0
            }, completion: {_ in
                self.challengeApprovedImageView.image = UIImage(named: "challenge_approve.png")
                //approveImageView.removeFromSuperview()
                
                UIView.animateWithDuration(2.0, delay: 0.1, options: .CurveEaseOut, animations: {
                    self.challengeApprovedImageView.alpha = 1.0
                    }, completion: {_ in
                        //self.challengeApprovedImageView.image = approveImageView.image
                        //approveImageView.removeFromSuperview()
                })
        })
        
        
        
        
    }
    
}