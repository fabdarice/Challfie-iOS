//
//  ChallengeVC.swift
//  Challfie
//
//  Created by fcheng on 12/4/14.
//  Copyright (c) 2014 Fabrice Cheng. All rights reserved.
//

import Foundation

class ChallengeVC : UIViewController {
    
    @IBOutlet weak var label1Label: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
//    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("ENTER CHALLENGE")                        
        
        var leftConstraint = NSLayoutConstraint(item: self.contentView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)

        
        var rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        
        self.view.addConstraint(rightConstraint)
        
     //   self.scrollView.addSubview(self.contentView)
       // self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        

        //contentView.frame.size = CGSizeMake(310.0, 800.0)
      //  let screenRect: CGRect = UIScreen.mainScreen().bounds
        
      //  let screenWidth : CGFloat = screenRect.size.width
//        self.contentView.frame = CGRectMake(0.0, 0.0, screenWidth, self.contentView.frame.height)
        //Setting the right content size - only height is being calculated depenging on content.
      //  let contentSize: CGSize = CGSizeMake(screenWidth, 1000.0)
      ///  self.scrollView.contentSize = contentSize
        //self.navigationController?.navigationBar.hidden = false

  //      println(self.contentView.bounds.width)
    //    println(self.contentView.frame.width)
      


        //self.contentView.setNeedsUpdateConstraints()
        //self.contentView.updateConstraints()
        
        self.label1Label.text = "Seize jours après la chute du président Blaise Compaoré, le Burkina Faso a un nouveau chef d'EtatA l'issue d'ultimes tractions, civils et militaires se sont accordés, lundi 17 novembre, sur le nom du diplomate Michel KafandoSeize jours après la chute du président Blaise Compaoré, le Burkina Faso a un nouveau chef d'EtatA l'issue d'ultimes tractions, civils et militaires se sont accordés, lundi 17 novembre, sur le nom du diplomate Michel Kafando"
        self.label1Label.numberOfLines = 0
        self.label1Label.sizeToFit()
        
        //println(self.scrollView.frame.width)
        
//        self.scrollView.contentSize = CGSizeMake(400.0, 600.0)
//        contentView.frame.width
//        self.scrollView.contentSize = CGSizeMake(320, 1000)
  
//        self.view.frame
  //      CGRect scrollFrame = CGRrectMake(x, y, w, h);
//        self.scrollView.contentSize = 
        
    }

    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
                println(UIScreen.mainScreen().bounds.height)
    //    self.scrollView.frame = UIScreen.mainScreen().bounds // Instead of using auto layout
         // Or whatever you want it to be.
        //self.label1Label.text = "Seize jours après la chute du président Blaise Compaoré, le Burkina Faso a un nouveau chef d'EtatA l'issue d'ultimes tractions, civils et militaires se sont accordés, lundi 17 novembre, sur le nom du diplomate Michel KafandoSeize jours après la chute du président Blaise Compaoré, le Burkina Faso a un nouveau chef d'EtatA l'issue d'ultimes tractions, civils et militaires se sont accordés, lundi 17 novembre, sur le nom du diplomate Michel Kafando"
//        self.label1Label.numberOfLines = 0
  //      self.label1Label.sizeToFit()
        println(UIScreen.mainScreen().bounds.height)
    //    self.scrollView.contentSize.height = UIScreen.mainScreen().bounds.height
    }
    
    
}