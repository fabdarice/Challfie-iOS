//
//  MatchupsTVCell.swift
//  Challfie
//
//  Created by fcheng on 10/29/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation
import KeychainAccess

class MatchupsTVCell: UITableViewCell {
    
    @IBOutlet weak var selfieLeftImageVIEW: UIImageView!
    
    @IBOutlet weak var selfieRightImageView: UIImageView!
    @IBOutlet weak var usernameLeftLabel: UILabel!
    @IBOutlet weak var usernameRightLabel: UILabel!
    @IBOutlet weak var statsLeftLabel: UILabel!
    @IBOutlet weak var statsRightLabel: UILabel!
    @IBOutlet weak var leftNumberApprovedLabel: UILabel!    
    @IBOutlet weak var rightNumberApprovedLabel: UILabel!
    
    @IBOutlet weak var leftWinnerImageView: UIImageView!
    
    @IBOutlet weak var rightWinnerImageView: UIImageView!
    
    var selfie_missing : UIImage!
    var icon_pending: UIImage!
    var icon_inprogress: UIImage!
    var icon_accept: UIImage!
    var icon_winner: UIImage!
    
    var current_user_username: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cache Images
        self.selfie_missing = UIImage(named: "no_selfie")
        self.icon_pending = UIImage(named: "icon_pending")
        self.icon_inprogress = UIImage(named: "icon_inprogress")
        self.icon_accept = UIImage(named: "accept_request")
        self.icon_winner = UIImage(named: "icon_winner")
        
        let keychain = Keychain(service: "challfie.app.service")
        self.current_user_username = keychain["login"]!
        
    }
    
    func loadItem(matchup:Matchup) {
        var user: User!
        var opponent: User!
        
        
        // User's Left or Right Username
        user = matchup.participants[0]
        self.usernameLeftLabel.text = user.username
        if self.usernameLeftLabel.text == self.current_user_username {
            self.usernameLeftLabel.textColor = MP_HEX_RGB("2B7DCF")
        }
        opponent = matchup.participants[1]
        //opponent = matchup.users
        
        self.usernameRightLabel.text = opponent.username
        if self.usernameRightLabel.text == self.current_user_username {
            self.usernameRightLabel.textColor = MP_HEX_RGB("2B7DCF")
        }

        // Left Or Right Number of Approval
        self.leftNumberApprovedLabel.text = "0"
        self.rightNumberApprovedLabel.text = "0"
        
        let user_selfie = matchup.GetUserSelfie(user)
        if user_selfie != nil {
            self.leftNumberApprovedLabel.text = user_selfie?.nb_upvotes.description
        }

        let opponent_selfie = matchup.GetUserSelfie(opponent)
        if opponent_selfie != nil {
            self.rightNumberApprovedLabel.text = opponent_selfie?.nb_upvotes.description
        }
        
        
        
        // Left or Right User's Statistiques (Win-Lose)
        self.statsLeftLabel.text = user.matchups_stats
        self.statsRightLabel.text = opponent.matchups_stats
        
        // Display User's Profil (Pending/Request) and User's Matchups' Selfies
        if matchup.status == MatchupStatus.Accepted.rawValue
            || matchup.status == MatchupStatus.Ended.rawValue
            || matchup.status == MatchupStatus.EndedWithDraw.rawValue {
            if user_selfie != nil {
                let selfiePicURL:NSURL = NSURL(string: (user_selfie?.show_selfie_pic())!)!
                self.selfieLeftImageVIEW.hnk_setImageFromURL(selfiePicURL)
            } else {
                self.selfieLeftImageVIEW.image = self.selfie_missing
                
            }
            
            if opponent_selfie != nil {
                let selfiePicURL:NSURL = NSURL(string: (opponent_selfie?.show_selfie_pic())!)!
                self.selfieRightImageView.hnk_setImageFromURL(selfiePicURL)
            } else {
                self.selfieRightImageView.image = self.selfie_missing
            }
                
            if user_selfie != nil && opponent_selfie != nil {
                if user_selfie?.nb_upvotes > opponent_selfie?.nb_upvotes {
                    self.rightWinnerImageView.hidden = true
                    self.leftWinnerImageView.image = self.icon_winner

                } else {
                    if user_selfie?.nb_upvotes < opponent_selfie?.nb_upvotes {
                        self.leftWinnerImageView.hidden = true
                        self.rightWinnerImageView.image = self.icon_winner
                    } else {
                        // Hide Winner Icon
                        self.leftWinnerImageView.hidden = true
                        self.rightWinnerImageView.hidden = true
                    }
                }
            } else {
                self.leftNumberApprovedLabel.textColor = MP_HEX_RGB("daa400")
                self.rightNumberApprovedLabel.textColor = MP_HEX_RGB("daa400")
            }
                
                
            // Display Winner Icon
            if matchup.status == MatchupStatus.Ended.rawValue || matchup.status == MatchupStatus.EndedWithDraw.rawValue {
                if matchup.matchup_winner != nil {
                    if matchup.matchup_winner == self.usernameLeftLabel.text {
                        self.rightWinnerImageView.hidden = true
                        self.leftWinnerImageView.image = self.icon_winner
                    } else {
                        if matchup.matchup_winner == self.usernameRightLabel.text {
                            self.leftWinnerImageView.hidden = true
                            self.rightWinnerImageView.image = self.icon_winner
                        } else {
                            // Hide Winner Icon
                            self.leftWinnerImageView.hidden = true
                            self.rightWinnerImageView.hidden = true
                        }
                    }
                } else {
                    // Hide Winner Icon
                    self.leftWinnerImageView.hidden = true
                    self.rightWinnerImageView.hidden = true
                }
                        
            }
        } else {
            // Set Profil Pic Frame and Gesture
            if user.show_profile_pic() != "missing" {
                let profilePicURL:NSURL = NSURL(string: user.show_profile_pic())!
                self.selfieLeftImageVIEW.hnk_setImageFromURL(profilePicURL)
            } else {
                self.selfieLeftImageVIEW.image = UIImage(named: "missing_user")
            }
            self.selfieLeftImageVIEW.layer.cornerRadius = self.selfieLeftImageVIEW.frame.size.width / 2
            self.selfieLeftImageVIEW.clipsToBounds = true
            
            // Display challenged user (Right Side) profil pic
            if opponent.show_profile_pic() != "missing" {
                let profilePicURL:NSURL = NSURL(string: opponent.show_profile_pic())!
                self.selfieRightImageView.hnk_setImageFromURL(profilePicURL)
            } else {
                self.selfieRightImageView.image = UIImage(named: "missing_user")
            }
            self.selfieRightImageView.layer.cornerRadius = self.selfieRightImageView.frame.size.width / 2
            self.selfieRightImageView.clipsToBounds = true
        }

                
    }
    
}