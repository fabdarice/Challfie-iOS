//
//  UIAutoCompleteTextField.swift
//  Challfie
//
//  Created by fcheng on 10/31/15.
//  Copyright © 2015 Fabrice Cheng. All rights reserved.
//

import Foundation

class UIAutoCompleteTextField: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    let autocompleteTableView = UITableView(frame: CGRectMake(0,80,320,120), style: UITableViewStyle.Plain)
    
    var pastUrls = ["Men", "Women", "Cats", "Dogs", "Children"]
    var autocompleteUrls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        autocompleteTableView.hidden = false
        let substring = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        searchAutocompleteEntriesWithSubstring(substring)
        return true     // not sure about this - could be false
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autocompleteUrls.removeAll(keepCapacity: false)
        
        for curString in pastUrls
        {
            let myString:NSString! = curString as NSString
            
            let substringRange :NSRange! = myString.rangeOfString(substring)
            
            if (substringRange.location  == 0)
            {
                autocompleteUrls.append(curString)
            }
        }
        
        autocompleteTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as UITableViewCell
        let index = indexPath.row as Int
        
        cell.textLabel!.text = autocompleteUrls[index]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        textField.text = selectedCell.textLabel!.text        
    }
}