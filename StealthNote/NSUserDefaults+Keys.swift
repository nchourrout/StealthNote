//
//  NSUserDefaults+StealthNote.swift
//  StealthNote
//
//  Created by Nicolas on 08/05/2015.
//  Copyright (c) 2015 Nicolas Chourrout. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    // FIX ME: Should work with static let
    static var kRecipientsKey : String {
        get {
            return "recipients"
        }
    }
    
    static var kStayAwakeKey : String {
        get {
            return "stayAwake"
        }
    }
    static var kVibrateKey : String {
        get {
            return "vibrate"
        }
    }
}
