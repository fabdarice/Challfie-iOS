//
//  PopUpViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore

@objc class PopUpViewControllerSwift : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
  //  @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logoImg: UIImageView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    var sourceView : UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRectMake(0.0, 0.0, self.sourceView.bounds.width, self.sourceView.bounds.height - 40.0)
        self.closeButton.setTitle(NSLocalizedString("Close", comment: "Close"), forState: .Normal)
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
        // Set bookProgressView height based on the device
        let model = UIDevice.currentDevice().modelName
        
        switch model {
        case "iPhone 3G": topSpaceConstraint.constant = 70
        case "iPhone 3GS": topSpaceConstraint.constant = 70
        case "iPhone 4": topSpaceConstraint.constant = 70
        case "iPhone 4S": topSpaceConstraint.constant = 70
        case "iPhone 5": topSpaceConstraint.constant = 85
        case "iPhone 5c": topSpaceConstraint.constant = 85
        case "iPhone 5s": topSpaceConstraint.constant = 85
        case "iPhone 6" : topSpaceConstraint.constant = 100
        case "iPhone 6 Plus" : topSpaceConstraint.constant = 120
        default:
            topSpaceConstraint.constant = 100
        }
        

    }
    
    func showInView(aView: UIView!, withImage image : UIImage!, withMessage message: String!, animated: Bool)
    {
        self.sourceView = aView
        self.view.frame = CGRectMake(0.0, 0.0, self.sourceView.bounds.width, self.sourceView.bounds.height - 40.0)
        aView.addSubview(self.view)
        logoImg!.image = image
        
       // messageLabel!.text = message
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}
