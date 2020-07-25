//
//  XMLNode+value.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

extension XMLNode {
    var intValue: Int? {
        get {
            if let str = stringValue {
                return Int(str)
            }
            return nil
        }
    }
}
