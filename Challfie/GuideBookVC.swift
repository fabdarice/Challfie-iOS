//
//  GuideBookVC.swift
//  Challfie
//
//  Created by fcheng on 8/21/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class GuideBookVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var bookView: UIView!
    @IBOutlet weak var firstBookImageView: UIImageView!
    @IBOutlet weak var secondBookImageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var thanksLabel: UILabel!
    
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookViewHeightConstraint: NSLayoutConstraint!
    
    var from_facebook: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = NSLocalizedString("tutorial_five_title", comment: "")
        self.descriptionLabel.text = NSLocalizedString("tutorial_five_description", comment: "")
        self.thanksLabel.text = NSLocalizedString("thanks_tutorial", comment: "Thank you for becoming part of the Challfie family.")
        self.nextPageButton.setTitle(NSLocalizedString("tutorial_five_button", comment: ""), forState: UIControlState.Normal)
        self.nextPageButton.layer.cornerRadius = 5
        self.nextPageButton.layer.borderWidth = 1.0
        self.nextPageButton.layer.borderColor = MP_HEX_RGB("1E3A75").CGColor

        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "iPhone 4":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 225
        case "iPhone 4S":
            descriptionBottomConstraint.constant = 10
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 225
        case "iPhone 5":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 250
        case "iPhone 5c":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 270
        case "iPhone 5s":
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 270
        case "iPhone 6" :
            descriptionBottomConstraint.constant = 40
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            bookViewHeightConstraint.constant = 300
        case "iPhone 6 Plus" :
            descriptionBottomConstraint.constant = 50
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 19.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            bookViewHeightConstraint.constant = 350
        default:
            descriptionBottomConstraint.constant = 30
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            thanksLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            self.nextPageButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
            bookViewHeightConstraint.constant = 225
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(2.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut , animations: {
            self.lockImageView.alpha = 0.0
            }, completion: {_ in
        })
    }

    
    // MARK: - Next Page Action
    @IBAction func nextPageAction(sender: AnyObject) {
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
    
}