//
//  XMLElement+child.swift
//
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

extension XMLElement {
    func addChild(name: String, value: Any, attributes : [String : String]) {
        let element = XMLElement(name: name, stringValue: "\(value)")
        for (key, attributeValue) in attributes {
            element.addAttribute(XMLNode.attribute(withName: key, stringValue: attributeValue) as! XMLNode)
        }
        self.addChild(element)
    }
}
