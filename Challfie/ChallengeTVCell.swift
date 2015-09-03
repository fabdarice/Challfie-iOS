//
//  ChallengeTVCell.swift
//  Challfie
//
//  Created by fcheng on 1/12/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation


class ChallengeTVCell : UITableViewCell {
    
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var difficultyImageView: UIImageView!
    @IBOutlet weak var challengeCompleteImageView: UIImageView!
    
    var challenge: Challenge!
    
    func loadItem() {
        self.challengeLabel.numberOfLines = 0
        self.challengeLabel.text = self.challenge.description
        self.challengeLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.challengeLabel.sizeToFit()
        
        if challenge.complete_status == 1 {
            self.challengeCompleteImageView.image = UIImage(named: "accept_request")
        } else if challenge.complete_status == 2 {
            self.challengeCompleteImageView.image = UIImage(named: "decline_request")
        } else {
            self.challengeCompleteImageView.image = nil
        }
        
        switch self.challenge.difficulty {
        case 1 : self.difficultyImageView.image = UIImage(named: "star_very_easy")
        case 2 : self.difficultyImageView.image = UIImage(named: "star_easy")
        case 3 : self.difficultyImageView.image = UIImage(named: "star_intermediate")
        case 4 : self.difficultyImageView.image = UIImage(named: "star_hard")
        case 5 : self.difficultyImageView.image = UIImage(named: "star_very_hard")
        default:
            self.difficultyImageView.image = UIImage(named: "star_very_easy")
        }
        
    }
    
    
    func loadItemForTakePicture() {
        self.challengeLabel.numberOfLines = 0
        self.challengeLabel.text = self.challenge.description
        self.challengeLabel.textColor = UIColor.blackColor()
        self.challengeLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.challengeLabel.sizeToFit()
        
        switch self.challenge.difficulty {
        case 1 : self.difficultyImageView.image = UIImage(named: "star_very_easy_black")
        case 2 : self.difficultyImageView.image = UIImage(named: "star_easy_black")
        case 3 : self.difficultyImageView.image = UIImage(named: "star_intermediate_black")
        case 4 : self.difficultyImageView.image = UIImage(named: "star_hard_black")
        case 5 : self.difficultyImageView.image = UIImage(named: "star_very_hard_black")
        default:
            self.difficultyImageView.image = UIImage(named: "star_very_easy_black")
        }
    }
}