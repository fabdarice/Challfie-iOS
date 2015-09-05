//
//  GuideTakePictureVC.swift
//  Challfie
//
//  Created by fcheng on 8/21/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class GuideTakePictureVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var skipTutorialButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var challengePendingImageView: UIImageView!    
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextPageVerticalConstraint: NSLayoutConstraint!
    
    var from_facebook: Bool = false
    var imageToSave: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.challengePendingImageView.image = UIImage(named: "challenge_pending.png")
        self.titleLabel.text = NSLocalizedString("tutorial_two_title", comment: "Congratulation on your first Challfie")
        self.descriptionLabel.text = NSLocalizedString("tutorial_two_description", comment: "")
        self.skipTutorialButton.setTitle(NSLocalizedString("skip_tutorial", comment: "Skip the tutorial"), forState: UIControlState.Normal)
        self.nextPageButton.setTitle(NSLocalizedString("tutorial_two_button", comment: ""), forState: UIControlState.Normal)
        self.nextPageButton.layer.cornerRadius = 5
        self.nextPageButton.layer.borderWidth = 1.0
        self.nextPageButton.layer.borderColor = MP_HEX_RGB("1E3A75").CGColor
        
        self.challengeLabel.text = NSLocalizedString("take_a_selfie", comment: "Take a selfie")
        self.selfieImageView.image = self.imageToSave
        
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
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 30
        case "iPhone 5c":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            nextPageVerticalConstraint.constant = 30
        case "iPhone 5s":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.skipTutorialButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Skip the Tutorial Button Action
    @IBAction func skipTutorialAction(sender: AnyObject) {
        if self.from_facebook == true {
            // Modal to Timeline TabBarViewCOntroller
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var homeTableViewController:HomeTBC = mainStoryboard.instantiateViewControllerWithIdentifier("hometabbar") as! HomeTBC
            homeTableViewController.from_facebook = self.from_facebook
            self.presentViewController(homeTableViewController, animated: true, completion: nil)
            
        } else {
            // Modal to LinkFacebook Tutorial Page
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var linkFacebookVC:LinkFacebookVC = mainStoryboard.instantiateViewControllerWithIdentifier("linkFacebookVC") as! LinkFacebookVC
            self.presentViewController(linkFacebookVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Next Page Action
    @IBAction func nextPageAction(sender: AnyObject) {
        // Push to GuideApproveSelfieVC
        var guideApproveSelfie = GuideApproveSelfieVC(nibName: "GuideApproveSelfie" , bundle: nil)
        guideApproveSelfie.from_facebook = self.from_facebook
        //guideApproveSelfie.selfieImageView.image = self.imageToSave        
        guideApproveSelfie.selfie = self.imageToSave
        
        self.presentViewController(guideApproveSelfie, animated: true, completion: nil)
    }
    
}