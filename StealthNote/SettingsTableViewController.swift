//
//  KGDrawerSettingsTableViewController.swift
//  StealthNote
//
//  Created by Nicolas on 07/05/2015.
//  Copyright (c) 2015 Nicolas Chourrout. All rights reserved.
//

import UIKit
import KGFloatingDrawer
import SwiftyUserDefaults

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var recipientTextfield: UITextField!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var autoLockSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadValues()
        
        // Dismissing keyboard when tapping outside of control
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func loadValues () {
        let arr = Defaults[NSUserDefaults.kRecipientsKey].array as! [String]
        recipientTextfield.text = ", ".join(arr)
        vibrateSwitch.on = Defaults[NSUserDefaults.kVibrateKey].bool!
        autoLockSwitch.on = Defaults[NSUserDefaults.kStayAwakeKey].bool!
    }

    // MARK: Outlets
    
    @IBAction func vibrateChanged(switchState: UISwitch) {
        Defaults[NSUserDefaults.kVibrateKey] = switchState.on
    }
    
    @IBAction func autolockChanged(switchState: UISwitch) {
        Defaults[NSUserDefaults.kStayAwakeKey] = switchState.on
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateAwakeness()
    }
    
    // MARK: Navigation
    
    @IBAction func toggleLeftDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleLeftDrawer(sender, animated: false)
    }
    
    @IBAction func toggleRightDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
    }
    
    // MARK: Tap outside controls
    
    func didTapView() {
        self.view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        Defaults[NSUserDefaults.kRecipientsKey] = split(textField.text.condenseWhitespace()) { $0 == "," }
    }
}
