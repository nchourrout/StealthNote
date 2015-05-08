//
//  String+White.swift
//  StealthNote
//
//  Created by Nicolas on 08/05/2015.
//  Copyright (c) 2015 Nicolas Chourrout. All rights reserved.
//

import Foundation

extension String {
    func condenseWhitespace() -> String {
        let components = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!Swift.isEmpty($0)})
        return " ".join(components)
    }
}