//
//  TutorialPageContentVC.swift
//  Challfie
//
//  Created by fcheng on 3/26/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class TutorialPageContentVC : UIViewController {
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var stepTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    
    var itemIndex: Int = 0
    var tutorialVC: TutorialVC!
    var fromFacebook: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background Color
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "iPhone 4":
            self.stepTopConstraint.constant = 20
            self.skipBottomConstraint.constant = 20
            self.imageHeightConstraint.constant = 250
        case "iPhone 4S":
            self.stepTopConstraint.constant = 20
            self.skipBottomConstraint.constant = 20
            self.imageHeightConstraint.constant = 250
        case "iPhone 5":
            self.stepTopConstraint.constant = 40
            self.skipBottomConstraint.constant = 30
            self.imageHeightConstraint.constant = 275
        case "iPhone 5c":
            self.stepTopConstraint.constant = 40
            self.skipBottomConstraint.constant = 30
            self.imageHeightConstraint.constant = 275
        case "iPhone 5s":
            self.stepTopConstraint.constant = 40
            self.skipBottomConstraint.constant = 30
            self.imageHeightConstraint.constant = 275
        case "iPhone 6" :
            self.stepTopConstraint.constant = 50
            self.skipBottomConstraint.constant = 40
            self.imageHeightConstraint.constant = 300
        case "iPhone 6 Plus" :
            self.stepTopConstraint.constant = 60
            self.skipBottomConstraint.constant = 50
            self.imageHeightConstraint.constant = 350
        default:
            self.stepTopConstraint.constant = 50
            self.skipBottomConstraint.constant = 40
            self.imageHeightConstraint.constant = 300
        }
        
        switch itemIndex {
        case 0 :
            self.stepLabel.text = NSLocalizedString("step", comment: "STEP") + " 1"
            self.messageLabel.text = NSLocalizedString("tutorial_step_one", comment: "Pick a challenge")
            self.skipButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip Tutorial"), forState: UIControlState.Normal)
            self.mainImageView.image = UIImage(named: "tutorial_step_01")
        case 1 :
            self.stepLabel.text = NSLocalizedString("step", comment: "STEP") + " 2"
            self.messageLabel.text = NSLocalizedString("tutorial_step_two", comment: "Take a selfie to complete your challenge")
            self.skipButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip Tutorial"), forState: UIControlState.Normal)
            self.mainImageView.image = UIImage(named: "tutorial_step_02")
        case 2 :
            self.stepLabel.text = NSLocalizedString("step", comment: "STEP") + " 3"
            self.messageLabel.text = NSLocalizedString("tutorial_step_three", comment: "Get your Challfie approved by your friends")
            self.skipButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip Tutorial"), forState: UIControlState.Normal)
            self.mainImageView.image = UIImage(named: "tutorial_step_03")
        case 3 :
            self.stepLabel.text = NSLocalizedString("step", comment: "STEP") + " 4"
            self.messageLabel.text = NSLocalizedString("tutorial_step_four", comment: "Earn points for each Challfie approved and level up to unlock new challenges")
            self.messageLabel.numberOfLines = 3
            self.messageLabel.sizeToFit()
            self.skipButton.setTitle(NSLocalizedString("get_started", comment: "Get Started"), forState: UIControlState.Normal)
            self.mainImageView.image = UIImage(named: "tutorial_step_04")
        default : ""
            
        }
        
    }
    
    
    @IBAction func skipAction(sender: AnyObject) {
        
        if self.fromFacebook == true {
            // Modal to Timeline TabBarViewCOntroller
            tutorialVC.performSegueWithIdentifier("homeSegue2", sender: self)
        } else {
            // Modal to LinkFacebook Tutorial Page
            tutorialVC.performSegueWithIdentifier("linkFacebookSegue", sender: self)
        }
        
    }
    
}