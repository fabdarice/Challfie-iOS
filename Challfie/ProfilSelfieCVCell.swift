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
    
    func loadItem() {
        
        // Selfie Image
        let selfieImageURL:NSURL = NSURL(string: selfie.show_selfie_pic())!
        self.selfieImage.hnk_setImageFromURL(selfieImageURL)
        
        var selfiePictapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
        selfiePictapGesture.addTarget(self, action: "selfieTapGesture")
        self.selfieImage.addGestureRecognizer(selfiePictapGesture)
        self.selfieImage.userInteractionEnabled = true
    }
    
    func selfieTapGesture() {
        self.profilVC.hidesBottomBarWhenPushed = true
        // Push to OneSelfieVC
        var oneSelfieVC = OneSelfieVC(nibName: "OneSelfie" , bundle: nil)
        oneSelfieVC.selfie = self.selfie
        oneSelfieVC.to_bottom = false
        self.profilVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Profil_tab", comment: "Profile"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.profilVC.navigationController?.pushViewController(oneSelfieVC, animated: true)
        
    }
    
}