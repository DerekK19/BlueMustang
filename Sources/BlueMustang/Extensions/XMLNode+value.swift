//
//  XMLNode+value.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

extension AEXMLElement {
    var intValue: Int? {
        get {
            if let str = value {
                return Int(str)
            }
            return nil
        }
    }
}
