//
//  ProfilSelfieCVCell.swift
//  Challfie
//
//  Created by fcheng on 12/28/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation


class ProfilSelfieCVCell : UICollectionViewCell {
    
    @IBOutlet weak var selfieImage: UIImageView!
    
    var selfie: Selfie!
    var profilVC : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selfiePictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        selfiePictapGesture.addTarget(self, action: "selfieTapGesture")
        self.selfieImage.addGestureRecognizer(selfiePictapGesture)
        self.selfieImage.userInteractionEnabled = true
    }
    
    func loadItem() {
        // Selfie Image
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)
    }
    
    func selfieTapGesture() {
        self.profilVC.hidesBottomBarWhenPushed = true
        
        if self.selfie.matchup != nil {
            print("PUSH ONEDUEL")
            // Push to OneMatchupVC of the selected Row
            let oneMatchUpVC = OneMatchupVC(nibName: "OneMatchup" , bundle: nil)
            oneMatchUpVC.hidesBottomBarWhenPushed = true
            oneMatchUpVC.matchup = self.selfie.matchup
            self.profilVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            self.profilVC.navigationController!.pushViewController(oneMatchUpVC, animated: true)

        } else {
            print("PSUH ONESELFIE")
            // Push to OneSelfieVC
            let oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
            oneSelfieVC.selfie = self.selfie
            oneSelfieVC.to_bottom = false
            self.profilVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Profil_tab", comment: "Profile"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            self.profilVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
        }
        
        
    }
    
}