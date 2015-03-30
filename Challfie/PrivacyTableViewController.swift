//
//  TermsTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
//import Alamofire

class PrivacyTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        //tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.whiteColor()
        //tableView.scrollsToTop = false
        
        // Hide on swipe & keboard Appears
        self.navigationController?.hidesBarsOnSwipe = true
        // Add Background for status bar
        let statusBarViewBackground = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, 20.0))
        statusBarViewBackground.backgroundColor = MP_HEX_RGB("30768A")
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarViewBackground)
        
        // Set the height of a cell dynamically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        // Register the xib for the Custom TableViewCell
        var nib = UINib(nibName: "ExtraPagesTVCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ExtraPagesCell")
        
        self.navigationItem.title = "Privacy"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18.0)!, NSForegroundColorAttributeName: MP_HEX_RGB("FFFFFF")]
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
        return 13
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExtraPagesCell") as ExtraPagesTVCell
        
        cell.userInteractionEnabled = false
        cell.loadItem()
        
        switch indexPath.row {
        case 0 :
            cell.titleLabel.text = nil
            cell.messageLabel.text = "This privacy policy has been compiled to better serve those who are concerned with how their 'Personally identifiable information' (PII) is being used online. PII, as used in US privacy law and information security, is information that can be used on its own or with other information to identify, contact, or locate a single person, or to identify an individual in context. Please read our privacy policy carefully to get a clear understanding of how we collect, use, protect or otherwise handle your Personally Identifiable Information in accordance with our website."
        case 1 :
            cell.titleLabel.text = "What personal information do we collect from the people that visit our blog, website or app?"
            cell.messageLabel.text = "When registering on our site, as appropriate, you may be asked to enter your name, email address or other details to help you with your experience."
        case 2 :
            cell.titleLabel.text = "When do we collect information?"
            cell.messageLabel.text = "We collect information from you when you register on our site or enter information on our site."
        case 3:
            cell.titleLabel.text = "How do we use your information?"
            cell.messageLabel.text = "We may use the information we collect from you when you register, make a purchase, sign up for our newsletter, respond to a survey or marketing communication, surf the website, or use certain other site features in the following ways:\n\n(a) To personalize user's experience and to allow us to deliver the type of content and product offerings in which you are most interested.\n(b) To improve our website in order to better serve you.\n(c) To quickly process your transactions."
            //cell!.addSubview(titleLabel)
        case 4:
            cell.titleLabel.text = "How do we protect visitor information?"
            cell.messageLabel.text = "We do not use vulnerability scanning and/or scanning to PCI standards. Your personal information is contained behind secured networks and is only accessible by a limited number of persons who have special access rights to such systems, and are required to keep the information confidential.\nIn addition, all sensitive/credit information you supply is encrypted via Secure Socket Layer (SSL) technology.\n\nWe implement a variety of security measures when a user submits, or accesses their information to maintain the safety of your personal information.\n\nAll transactions are processed through a gateway provider and are not stored or processed on our servers."
            //cell!.addSubview(titleLabel)
        case 5:
            cell.titleLabel.text = "Do we use 'cookies'?"
            cell.messageLabel.text = "Yes. Cookies are small files that a site or its service provider transfers to your computer's hard drive through your Web browser (if you allow) that enables the site's or service provider's systems to recognize your browser and capture and remember certain information. For instance, we use cookies to help us remember and process the items in your shopping cart. They are also used to help us understand your preferences based on previous or current site activity, which enables us to provide you with improved services. We also use cookies to help us compile aggregate data about site traffic and site interaction so that we can offer better site experiences and tools in the future.\n\nWe use cookies to:\n(a) Help remember and process the items in the shopping cart.\n(b) Understand and save user's preferences for future visits.\n(c)You can choose to have your computer warn you each time a cookie is being sent, or you can choose to turn off all cookies. You do this through your browser (like Internet Explorer) settings. Each browser is a little different, so look at your browser's Help menu to learn the correct way to modify your cookies.\n\nIf you disable cookies off, some features will be disabled It won't affect the users experience that make your site experience more efficient and some of our services will not function properly."
            //cell!.addSubview(titleLabel)
        case 6 :
            cell.titleLabel.text = "Third Party Disclosure"
            cell.messageLabel.text = "We do not sell, trade, or otherwise transfer to outside parties your personally identifiable information unless we provide you with advance notice. This does not include website hosting partners and other parties who assist us in operating our website, conducting our business, or servicing you, so long as those parties agree to keep this information confidential. We may also release your information when we believe release is appropriate to comply with the law, enforce our site policies, or protect ours or others' rights, property, or safety.\n\nHowever, non-personally identifiable visitor information may be provided to other parties for marketing, advertising, or other uses."
        case 7 :
            cell.titleLabel.text = "Third party links"
            cell.messageLabel.text = "Occasionally, at our discretion, we may include or offer third party products or services on our website. These third party sites have separate and independent privacy policies. We therefore have no responsibility or liability for the content and activities of these linked sites. Nonetheless, we seek to protect the integrity of our site and welcome any feedback about these sites."
        case 8 :
            cell.titleLabel.text = "Google"
            cell.messageLabel.text = "Google's advertising requirements can be summed up by Google's Advertising Principles. They are put in place to provide a positive experience for users. https://support.google.com/adwordspolicy/answer/1316548?hl=en\n\nWe have not enabled Google AdSense on our site but we may do so in the future."
        case 9 :
            cell.titleLabel.text = "California Online Privacy Protection Act"
            cell.messageLabel.text = "CalOPPA is the first state law in the nation to require commercial websites and online services to post a privacy policy. The law's reach stretches well beyond California to require a person or company in the United States (and conceivably the world) that operates websites collecting personally identifiable information from California consumers to post a conspicuous privacy policy on its website stating exactly the information being collected and those individuals with whom it is being shared, and to comply with this policy. - See more at: http://consumercal.org/california-online-privacy-protection-act-caloppa/#sthash.0FdRbT51.dpuf\n\nAccording to CalOPPA we agree to the following:\nUsers can visit our site anonymously. Once this privacy policy is created, we will add a link to it on our home page, or as a minimum on the first significant page after entering our website. Our Privacy Policy link includes the word 'Privacy', and can be easily be found on the page specified above.\n\nUsers will be notified of any privacy policy changes on our Privacy Policy Page.\nUsers are able to change their personal information by logging in to their account."
        case 10 :
            cell.titleLabel.text = "How does our site handle do not track signals?"
            cell.messageLabel.text = "We honor do not track signals and do not track, plant cookies, or use advertising when a Do Not Track (DNT) browser mechanism is in place."
        case 11 :
            cell.titleLabel.text = "Does our site allow third party behavioral tracking?"
            cell.messageLabel.text = "It's also important to note that we do not allow third party behavioral tracking"
        case 12 :
            cell.titleLabel.text = "COPPA (Children Online Privacy Protection Act)"
            cell.messageLabel.text = "When it comes to the collection of personal information from children under 13, the Children's Online Privacy Protection Act (COPPA) puts parents in control. The Federal Trade Commission, the nation's consumer protection agency, enforces the COPPA Rule, which spells out what operators of websites and online services must do to protect children's privacy and safety online.\n\nWe do not specifically market to children under 13."
        default :
            cell.titleLabel.text = "Fair Information Practices"
            cell.messageLabel.text = "The Fair Information Practices Principles form the backbone of privacy law in the United States and the concepts they include have played a significant role in the development of data protection laws around the globe. Understanding the Fair Information Practice Principles and how they should be implemented is critical to comply with the various privacy laws that protect personal information.\n\nIn order to be in line with Fair Information Practices we will take the following responsive action, should a data breach occur:\n\n\nWe will notify the users via email within 7 business days.\nWe will notify the users via in site notification within 7 business days.\n\nWe also agree to the individual redress principle, which requires that individuals have a right to pursue legally enforceable rights against data collectors and processors who fail to adhere to the law. This principle requires not only that individuals have enforceable rights against data users, but also that individuals have recourse to courts or a government agency to investigate and/or prosecute non-compliance by data processors."
        }
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
    
}
