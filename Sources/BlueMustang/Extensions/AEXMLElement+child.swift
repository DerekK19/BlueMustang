//
//  XMLElement+child.swift
//
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

extension AEXMLElement {
    func addChild(name: String, value: Any, attributes : [String : String]) {
        let element = AEXMLElement(name: name, value: "\(value)", attributes: attributes)
        self.addChild(element)
    }
}
