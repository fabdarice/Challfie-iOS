//
//  TermsTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
//import Alamofire

class TermsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        // Customize apperance of table view
        //tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.whiteColor()
        //tableView.scrollsToTop = false
        
        // Set the height of a cell dynamically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "ExtraPagesTVCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ExtraPagesCell")
        
        self.navigationItem.title = "Terms & Conditions"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExtraPagesCell") as! ExtraPagesTVCell
        
        cell.userInteractionEnabled = false
        cell.loadItem()

        switch indexPath.row {
        case 0 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = "Please read these Terms of Service carefully before using the Challfie website (the 'Service').\n\nYour access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Service.\n\nBy accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service."
        case 1 :
            cell.titleLabel.text = "Accounts"
            cell.messageLabel.text = "You must be at least 13 years of age to use our website; and by using our website or agreeing to these terms and conditions, you warrant and represent to us that you are at least 13 years of age.\n\nWhen you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.\n\nYou are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password, whether your password is with our Service or a third-party service.\n\nYou agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.\n\nYou must notify us in writing immediately if you become aware of any unauthorised use of your account or any disclosure of your password.\n\nYou must not use any other person's account to access the website.\n\nYour user ID must not be liable to mislead and must comply with the content rules; you must not use your account or user ID for or in connection with the impersonation of any person.\n\nYou are responsible for any activity on our website arising out of any failure to keep your password confidential, and may be held liable for any losses arising out of such a failure."
        case 2 :
            cell.titleLabel.text = "Acceptable Use"
            cell.messageLabel.text = "You must not:\n\n(a)  use our website in any way or take any action that causes, or may cause, damage to the website or impairment of the performance, availability or accessibility of the website;\n(b)  use our website in any way that is unlawful, illegal, fraudulent or harmful, or in connection with any unlawful, illegal, fraudulent or harmful purpose or activity;\n(c)  use our website to copy, store, host, transmit, send, use, publish or distribute any material which consists of (or is linked to) any spyware, computer virus, Trojan horse, worm, keystroke logger, rootkit or other malicious computer software;\n(d)  conduct any systematic or automated data collection activities (including without limitation scraping, data mining, data extraction and data harvesting) on or in relation to our website without our express written consent;\n(e)  access or otherwise interact with our website using any robot, spider or other automated means;\n(f)  use data collected from our website for any direct marketing activity (including without limitation email marketing, SMS marketing, telemarketing and direct mailing)\n(g) use data collected from our website to contact individuals, companies or other persons or entities."
        case 3:
            cell.titleLabel.text = "Content"
            cell.messageLabel.text = "Rules\nYou warrant and represent that your content will comply with these terms and conditions.\n\nYour content must not be illegal or unlawful, must not infringe any person's legal rights, and must not be capable of giving rise to legal action against any person (in each case in any jurisdiction and under any applicable law).\n\nYour content, and the use of your content by us in accordance with these terms and conditions, must not:\n\n- be libellous or maliciously false;\n- be obscene or indecent;\n- infringe any copyright, moral right, database right, trade mark right, design right, right in passing off, or other intellectual property right;\n- infringe any right of confidence, right of privacy or right under data protection legislation;\n- constitute negligent advice or contain any negligent statement;\n- constitute an incitement to commit a crime;\n- be in contempt of any court, or in breach of any court order;\n- be in breach of racial or religious hatred or discrimination legislation;\n- be blasphemous;\n- be in breach of official secrets legislation;\n- be in breach of any contractual obligation owed to any person;\n- depict violence, in an explicit, graphic or gratuitous manner;\n- be pornographic;\n- constitute spam;\n- be offensive, deceptive, fraudulent, threatening, abusive, harassing, anti-social, menacing, hateful, discriminatory or inflammatory;\n- cause annoyance, inconvenience or needless anxiety to any person.\n\n\nLicense\nIn these terms and conditions, 'your content' means all works and materials (including without limitation text, graphics, images, audio material, video material, audio-visual material, scripts, software and files) that you submit to us or our website for storage or publication on, processing by, or transmission via, our website.\n\nYou grant to us a royalty-free licence to use, reproduce, store, adapt, publish, translate and distribute your content in any existing or future media / reproduce, store and publish your content on and in relation to this website and any successor website.\n\nYou hereby waive all your moral rights in your content to the maximum extent permitted by applicable law; and you warrant and represent that all other moral rights in your content have been waived to the maximum extent permitted by applicable law.\n\nYou may edit your content to the extent permitted using the editing functionality made available on our website.\n\nWithout prejudice to our other rights under these terms and conditions, if you breach any provision of these terms and conditions in any way, or if we reasonably suspect that you have breached these terms and conditions in any way, we may delete, unpublish or edit any or all of your content."
            //cell!.addSubview(titleLabel)
        case 4:
            cell.titleLabel.text = "Termination"
            cell.messageLabel.text = "We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\nAll provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity and limitations of liability.\n\nWe may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\nUpon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may simply discontinue using the Service.\n\nAll provisions of the Terms which by their nature should survive termination shall survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity and limitations of liability."
            //cell!.addSubview(titleLabel)
        case 5:
            cell.titleLabel.text = "Governing Law"
            cell.messageLabel.text = "These Terms shall be governed and construed in accordance with the laws of California, United States, without regard to its conflict of law provisions.\n\nOur failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service."
            //cell!.addSubview(titleLabel)
        case 6 :
            cell.titleLabel.text = "Copyright Notice"
            cell.messageLabel.text = "The trademarks, names, logos and service marks (collectively “trademarks”) displayed on this website are registered and unregistered trademarks of the website owner. Nothing contained on this website should be construed as granting any license or right to use any trademark without the prior written permission of the website owner. The written content displayed on this website is owned by its respective author and may not be reproduced in whole, or in part, without the express written permission of the author.\n\nCopyright (c) 2014-2015 @ Challfie.com\nSubject to the express provisions of these terms and conditions:\n\n(a) we, together with our licensors, own and control all the copyright and other intellectual property rights in our website and the material on our website; and\n(b) all the copyright and other intellectual property rights in our website and the material on our website are reserved"
        case 7 :
            cell.titleLabel.text = "Links To Other Web Sites"
            cell.messageLabel.text = "Our Service may contain links to third-party web sites or services that are not owned or controlled by Challfie.\n\nChallfie has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third party web sites or services. You further acknowledge and agree that Challfie shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such web sites or services.\n\nWe strongly advise you to read the terms and conditions and privacy policies of any third-party web sites or services that you visit."
        case 8 :
            cell.titleLabel.text = "Modifications"
            cell.messageLabel.text = "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.\n\nBy continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, please stop using the Service.\n\nLast updated: September 29, 2014\nGenerated by TermsFeed"
        default :
            cell.titleLabel.text = ""
            cell.messageLabel.text = ""
        }
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()

        return cell
    }
    
}
