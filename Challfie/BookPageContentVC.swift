//
//  BookPageContent.swift
//  Challfie
//
//  Created by fcheng on 1/6/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class BookPageContentVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var lockerImage: UIImageView!
    @IBOutlet weak var numberOfChallenges: UILabel!
    @IBOutlet weak var challengeTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var itemIndex: Int = 0
    var book: Book! {
        didSet {
            if let imageView = self.bookImage {
                // Book Cover Image
                let bookImageStr = ApiLink.host + self.book.cover
                let bookImageURL:NSURL = NSURL(string: bookImageStr)!
                imageView.hnk_setImageFromURL(bookImageURL)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background Color
        self.view.backgroundColor = MP_HEX_RGB("1A596B")
        
        self.separatorLine.backgroundColor = MP_HEX_RGB("0A3845")
        
        // set Book name
        self.bookNameLabel.text = self.book.name
        
        // Book Cover Image
        let bookImageURL:NSURL = NSURL(string: self.book.show_book_pic())!
        self.bookImage.hnk_setImageFromURL(bookImageURL, success: { (book_image: UIImage) in
            //self.bookImage.image = book_image
            // Book is not unlocked yet
            if self.book.is_unlocked == false {
                if let image = UIImage(named: "book_lock") {
                    self.bookImage.image = self.convertToGrayscale(book_image)
                    self.lockerImage.image = self.convertToGrayscale(image)
                }
                self.bookNameLabel.textColor = MP_HEX_RGB("BABABA")
                // set number of challenge in a book
                self.numberOfChallenges.text = NSLocalizedString("book_locked", comment: "Book locked")
                self.numberOfChallenges.textColor = MP_HEX_RGB("9C9A9A")
                
                // Display a message when the table is empty
                var messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, 20.0))
                messageLabel.text = NSLocalizedString("book_is_locked", comment: "Unlock this book by getting your selfie challenges approved by your friends. Check your progress in the \"Level Progression\" tab")
                messageLabel.textColor = MP_HEX_RGB("FFFFFF")
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                messageLabel.font = UIFont(name: "Chinacat", size: 16.0)
                messageLabel.sizeToFit()
                
                self.challengeTableView.backgroundView = messageLabel
                self.challengeTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            } else {
                self.bookImage.image = book_image
                self.bookNameLabel.textColor = MP_HEX_RGB("8ceeff")
                // set number of challenge in a book
                self.numberOfChallenges.text = self.book.challenges_array.count.description + " challenges"
                
                // Set the height of a cell dynamically
                self.challengeTableView.rowHeight = UITableViewAutomaticDimension
                self.challengeTableView.estimatedRowHeight = 20.0
                
                // Register the xib for the Custom TableViewCell
                var nib = UINib(nibName: "ChallengeTVCell", bundle: nil)
                self.challengeTableView.registerNib(nib, forCellReuseIdentifier: "ChallengeCell")
                
                // Set Delegate and Datasource of challengeTableView
                self.challengeTableView.delegate = self
                self.challengeTableView.dataSource = self
                
                // Remove tableview Inset Separator
                self.challengeTableView.layoutMargins = UIEdgeInsetsZero
                self.challengeTableView.separatorInset = UIEdgeInsetsZero
                self.challengeTableView.separatorColor = MP_HEX_RGB("266E82")
                
                // Set the height of challengeTableView dynamically based on the height of each cell
                // Couldn't do it in cellForRowAtIndexPath as it returns the original height of the cell
                self.challengeTableView.reloadData()
                var tableView_newHeight: CGFloat = 0.0
                for var i:Int = 0; i < self.book.challenges_array.count; i++ {
                    tableView_newHeight += self.challengeTableView.rectForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)).size.height
                }
                self.tableViewHeightConstraint.constant = tableView_newHeight
            }
        })
        
        
        self.numberOfChallenges.font = UIFont.italicSystemFontOfSize(14.0)
        
        // Set Difficulty on Separator
        self.difficultyLabel.text = NSLocalizedString("difficulty", comment: "Difficulty")
        
        // Add constraints to force vertical scrolling of UIScrollView
        // Basically set the leading and trailing of contentView to the View's one (instead of the scrollView)
        // Can't be done in the Interface Builder (.xib)
        var leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        var rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)

        
    }
    
    func convertToGrayscale(image:UIImage) -> UIImage {
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        // Grayscale color space
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
        
        // Create bitmap content with current image size and grayscale colorspace
        let context: CGContextRef = CGBitmapContextCreate(nil, UInt(imageRect.size.width), UInt(imageRect.size.height), 8, 0, colorSpace, bitmapInfo)
        
        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        /* changes start here */
        // Create bitmap image info from pixel data in current context
        let grayImage: CGImageRef = CGBitmapContextCreateImage(context)
        
        // make a new alpha-only graphics context
        let bitmapInfo2 = CGBitmapInfo(CGImageAlphaInfo.Only.rawValue)
        let alpha_context = CGBitmapContextCreate(nil, UInt(image.size.width), UInt(image.size.height), 8, 0, nil, bitmapInfo2);
        
        // draw image into context with no colorspace
        CGContextDrawImage(alpha_context, imageRect, image.CGImage)
        
        // create alpha bitmap mask from current context
        let mask: CGImageRef = CGBitmapContextCreateImage(alpha_context)
        
        // make UIImage from grayscale image with alpha mask
        let grayScaleImage: UIImage = UIImage(CGImage: CGImageCreateWithMask(grayImage, mask))!
        
        // Create bitmap image info from pixel data in current context
        let imageRef: CGImageRef = CGBitmapContextCreateImage(context)
        
        return grayScaleImage
    }
    
    // UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.book.challenges_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ChallengeTVCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as ChallengeTVCell
        var challenge:Challenge = self.book.challenges_array[indexPath.row]
                        
        cell.challenge = challenge
        cell.loadItem()
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
}