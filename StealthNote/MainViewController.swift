//
//  ViewController.swift
//  StealthNote
//
//  Created by Nicolas on 07/05/2015.
//  Copyright (c) 2015 Nicolas Chourrout. All rights reserved.
//

import UIKit
import MessageUI
import AudioToolbox
import SwiftyUserDefaults

class MainViewController: UIViewController, RenderViewDelegate, MFMailComposeViewControllerDelegate {
    
    var recognizer:DBPathRecognizer?
    
    struct RecognizerKeys {
        static let backspace = "[Backspace]"
        static let send = "[Send]"
    }
    
    @IBOutlet weak var renderView: RenderView!
    @IBOutlet weak var letter: UILabel!
    @IBOutlet weak var message: UILabel!
    
    enum FilterOperation {
        case Maximum
        case Minimum
    }
    
    enum FilterField {
        case LastPointX
        case LastPointY
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let recognizer = DBPathRecognizer(sliceCount: 8, deltaMove: 16.0)
        
        let maxy3 = MainViewController.customFilter(self)(.Maximum, .LastPointY, 0.3)
        let miny3 = MainViewController.customFilter(self)(.Minimum, .LastPointY, 0.3)
        let maxy7 = MainViewController.customFilter(self)(.Maximum, .LastPointY, 0.7)
        let miny7 = MainViewController.customFilter(self)(.Minimum, .LastPointY, 0.7)
        
        // TODO: Move this to a plist
        recognizer.addModel(PathModel(directions: [7, 1], datas:"A"))
        recognizer.addModel(PathModel(directions: [2,6,0,1,2,3,4,0,1,2,3,4], datas:"B"))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0], datas:"C"))
        recognizer.addModel(PathModel(directions: [2,6,7,0,1,2,3,4], datas:"D", filter:miny7))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0,4,3,2,1,0], datas:"E"))
        recognizer.addModel(PathModel(directions: [4,2], datas:"F"))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0,7,6,5,0], datas:"G", filter:miny3))
        recognizer.addModel(PathModel(directions: [2,6,7,0,1,2], datas:"H"))
        recognizer.addModel(PathModel(directions: [2], datas:"I"))
        recognizer.addModel(PathModel(directions: [2,3,4], datas:"J"))
        recognizer.addModel(PathModel(directions: [3,4,5,6,7,0,1], datas:"K"))
        recognizer.addModel(PathModel(directions: [2,0], datas:"L"))
        recognizer.addModel(PathModel(directions: [6,1,7,2], datas:"M"))
        recognizer.addModel(PathModel(directions: [6,1,6], datas:"N"))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0,7,6,5,4], datas:"O", filter:maxy3))
        recognizer.addModel(PathModel(directions: [2,6,7,0,1,2,3,4], datas:"P", filter:maxy7))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0,7,6,5,4,0], datas:"Q", filter: maxy3))
        recognizer.addModel(PathModel(directions: [2,6,7,0,1,2,3,4,1], datas:"R"))
        recognizer.addModel(PathModel(directions: [4,3,2,1,0,1,2,3,4], datas:"S"))
        recognizer.addModel(PathModel(directions: [0,2], datas:"T"))
        recognizer.addModel(PathModel(directions: [2,1,0,7,6], datas:"U"))
        recognizer.addModel(PathModel(directions: [1,7,0], datas:"V"))
        recognizer.addModel(PathModel(directions: [2,7,1,6], datas:"W"))
        recognizer.addModel(PathModel(directions: [1,0,7,6,5,4,3], datas:"X"))
        recognizer.addModel(PathModel(directions: [2,1,0,7,6,2,3,4,5,6,7], datas:"Y"))
        recognizer.addModel(PathModel(directions: [0,3,0], datas:"Z"))
        recognizer.addModel(PathModel(directions: [0], datas:" "))
        
        // Special characters
        recognizer.addModel(PathModel(directions: [4], datas:RecognizerKeys.backspace)) // Backspace
        recognizer.addModel(PathModel(directions: [0, 2 ,4], datas:RecognizerKeys.send)) // Send
        
        self.recognizer = recognizer
        self.renderView.delegate = self
        
        // Settings - default values
        Defaults[NSUserDefaults.kRecipientsKey] ?= ["your@email.com"]
        Defaults[NSUserDefaults.kVibrateKey] ?= true
        Defaults[NSUserDefaults.kStayAwakeKey] ?= false
    }
    
    func minLastY(cost:Int, infos:PathInfos, minValue:Double)->Int {
        var py:Double = (Double(infos.deltaPoints.last!.y) - Double(infos.boundingBox.top)) / Double(infos.height)
        return py < minValue ? Int.max : cost
    }
    
    func maxLastY(cost:Int, infos:PathInfos, maxValue:Double)->Int {
        var py:Double = (Double(infos.deltaPoints.last!.y) - Double(infos.boundingBox.top)) / Double(infos.height)
        return py > maxValue ? Int.max : cost
    }
    
    func customFilter(operation:FilterOperation,_ field:FilterField, _ value:Double)(cost:Int, infos:PathInfos)->Int {
        
        var pvalue:Double
        
        switch field {
        case .LastPointY:
            pvalue = (Double(infos.deltaPoints.last!.y) - Double(infos.boundingBox.top)) / Double(infos.height)
        case .LastPointX:
            pvalue = (Double(infos.deltaPoints.last!.x) - Double(infos.boundingBox.left)) / Double(infos.width)
        }
        
        switch operation {
        case .Maximum:
            return pvalue > value ? Int.max : cost
        case .Minimum:
            return pvalue < value ? Int.max : cost
        }
    }
    
    func buzz() {
        if (Defaults[NSUserDefaults.kVibrateKey].bool ?? true) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func sendMail () {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        let textToSend = message.text
        mailComposerVC.setToRecipients(Defaults[NSUserDefaults.kRecipientsKey].array as! [String])
        mailComposerVC.setSubject(textToSend)
        mailComposerVC.setMessageBody("\(textToSend!)\n\nSent by StealthNote", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could not send email",
            message:"Please check email settings and try again.",
            delegate: self,
            cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        buzz()
    }
    
    // MARK: RenderViewDelegate
    
    func analyzePath(path:Path) {
        var gesture:PathModel? = self.recognizer!.recognizePath(path)
        
        if gesture != nil {
            let char = gesture!.datas as? String
            let text = message.text!
            switch char! {
            case RecognizerKeys.backspace:
                if count(text) > 0 {
                    message.text = text.substringToIndex(text.endIndex.predecessor())
                } else {
                    buzz()
                }
                break
            case RecognizerKeys.send:
                sendMail()
                break
            default:
                letter.text = char
                self.letter.alpha = 1
                let oldFrame = letter.frame
                UIView.animateWithDuration(0.2, animations: {
                    self.letter.alpha = 0
                    self.letter.frame = self.message.frame
                    }, completion: { _ in
                        self.message.text = self.message.text! + char!
                        self.letter.frame = oldFrame
                })
            }
        }
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
}

