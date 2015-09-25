//
//  BookPageContent.swift
//  Challfie
//
//  Created by fcheng on 1/6/15.
//  Copyright (c) 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class BookPageContentVC : UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    var imageToSave: UIImage!
    var imagePicker: UIImagePickerController!
    var use_camera: Bool = true
    var challenge_selected : String = ""
    var book: Book! {
        didSet {
            if let imageView = self.bookImage {
                // Book Cover Image
                let bookImageURL:NSURL = NSURL(string: self.book.cover)!
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
        self.bookImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        let bookImageURL:NSURL = NSURL(string: self.book.show_book_pic())!
        self.bookImage.hnk_setImageFromURL(bookImageURL, success: { (book_image: UIImage) in
            //self.bookImage.image = book_image
            // Book is not unlocked yet
            if self.book.is_unlocked == false {
                if let image = UIImage(named: "level_lock") {
                    self.bookImage.image = self.convertToGrayscale(book_image)
                    self.lockerImage.image = self.convertToGrayscale(image)
                }
                self.bookNameLabel.textColor = MP_HEX_RGB("BABABA")
                // set number of challenge in a book
                self.numberOfChallenges.text = NSLocalizedString("book_locked", comment: "Book locked")
                self.numberOfChallenges.textColor = MP_HEX_RGB("9C9A9A")
                
                // Display a message when the table is empty
                let messageLabel = UILabel(frame: CGRectMake(20, 0, UIScreen.mainScreen().bounds.width - 40, 20.0))
                messageLabel.text = NSLocalizedString("book_is_locked", comment: "Unlock this book by getting your selfie challenges approved by your friends. Check your progress in the \"Level Progression\" tab")
                messageLabel.textColor = MP_HEX_RGB("FFFFFF")
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
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
                let nib = UINib(nibName: "ChallengeTVCell", bundle: nil)
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
        let leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        let rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        self.view.addConstraint(rightConstraint)

        
    }
    
    func convertToGrayscale(image:UIImage) -> UIImage {
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        // Grayscale color space
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
        //let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        
        // Create bitmap content with current image size and grayscale colorspace
        
        let context  = CGBitmapContextCreate(nil, Int(imageRect.size.width), Int(imageRect.size.height), 8, 0, colorSpace, CGImageAlphaInfo.None.rawValue)
        
        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        /* changes start here */
        // Create bitmap image info from pixel data in current context
        let grayImage: CGImageRef = CGBitmapContextCreateImage(context)!
        
        // make a new alpha-only graphics context
        //let bitmapInfo2 = CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue)
        let alpha_context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, nil, CGImageAlphaInfo.Only.rawValue);
        
        // draw image into context with no colorspace
        CGContextDrawImage(alpha_context, imageRect, image.CGImage)
        
        // create alpha bitmap mask from current context
        let mask: CGImageRef = CGBitmapContextCreateImage(alpha_context)!
        
        // make UIImage from grayscale image with alpha mask
        let grayScaleImage: UIImage = UIImage(CGImage: CGImageCreateWithMask(grayImage, mask)!)
        
        // Create bitmap image info from pixel data in current context
        //let imageRef: CGImageRef = CGBitmapContextCreateImage(context)!
        
        return grayScaleImage
    }
    
    // UITableViewDelegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.book.challenges_array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ChallengeTVCell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! ChallengeTVCell
        let challenge:Challenge = self.book.challenges_array[indexPath.row]
                        
        cell.challenge = challenge
        cell.loadItem()
        
        // Remove the inset for cell separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        
        // Background of Selected Cell of TableViewCell
        let selectionView = UIView()
        selectionView.backgroundColor = MP_HEX_RGB("3993ad")
        cell.selectedBackgroundView = selectionView

        
        // Update Cell Constraints
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : ChallengeTVCell = tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ChallengeTVCell
        
        self.challenge_selected = cell.challenge.description
        
        // Show Pop-op to options to choose between camera and photo library
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oneAction = UIAlertAction(title: NSLocalizedString("take_picture", comment: "Take a Picture"), style: .Default) { (_) in
            self.use_camera = true
            self.showCamera()
        }
        let twoAction = UIAlertAction(title: NSLocalizedString("choose_from_gallery", comment: "Choose From Your Gallery"), style: .Default) { (_) in
            self.use_camera = false
            self.showPhotoLibrary()
        }
        let thirdAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel) { (_) in }
        
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(thirdAction)
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    // MARK: - When the user is taking a picture from the device camera
    func showCamera() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            GlobalFunctions().displayAlert(title: "No Camera Found", message: " ", controller: self)
        }
    }
    
    // MARK: - When the user is selecting a picture from the gallery
    func showPhotoLibrary() {
        // Add Background for status bar
        let statusBarViewBackground  = UIApplication.sharedApplication().keyWindow?.viewWithTag(22)
        statusBarViewBackground?.hidden = true
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            GlobalFunctions().displayAlert(title: "No access to photo library", message: " ", controller: self)
        }
    }
    
    // MARK: - UIImagePickerController Delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        if let pickedImage = image {
            self.imageToSave = pickedImage
            
            // Save to Challfie Album
            if self.use_camera == true {
                self.imageToSave = self.fixOrientation(image)
                UIImageWriteToSavedPhotosAlbum(self.imageToSave, nil, nil, nil)
                // Push to TakePictureVC
                if let allTabViewControllers = self.tabBarController?.viewControllers,
                    let navController:UINavigationController = allTabViewControllers[2] as? UINavigationController,
                    let takePictureVC: TakePictureVC = navController.viewControllers[0] as? TakePictureVC {
                    takePictureVC.imageToSave = self.imageToSave
                    takePictureVC.challenge_selected = self.challenge_selected
                    self.tabBarController?.selectedViewController = navController
                    picker.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.hidesBottomBarWhenPushed = true
                let photoLibraryPreviewVC = PhotoLibraryPreviewVC(nibName: "PhotoLibraryPreview", bundle: nil)
                photoLibraryPreviewVC.imageToSave = self.imageToSave
                photoLibraryPreviewVC.homeTabBarController = self.tabBarController as! HomeTBC
                photoLibraryPreviewVC.imagePicker = picker
                photoLibraryPreviewVC.challenge_selected = self.challenge_selected
                picker.pushViewController(photoLibraryPreviewVC, animated: true)
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.drawInRect(rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
}