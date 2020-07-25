//
//  Fuse.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

public struct Fuse {
    
    public var info: Info?

    public init(info: Info?) {
        self.info = info
    }

    init(withElement element: XMLElement) {
        if let infoElement = element.elements(forName: "Info").first {
            self.info = Info(withElement: infoElement)
        }
    }
    
    func xml() -> XMLElement {
        let fuse = XMLElement(name: "FUSE")
        if info != nil { fuse.addChild(info!.xml()) }
        let colours = XMLElement(name: "PedalColors")
        colours.addChild(name: "Color", value: 14, attributes: ["ID" : "1"])
        colours.addChild(name: "Color", value: 1, attributes: ["ID" : "2"])
        colours.addChild(name: "Color", value: 2, attributes: ["ID" : "3"])
        colours.addChild(name: "Color", value: 10, attributes: ["ID" : "4"])
        fuse.addChild(colours)
        return fuse
    }
    
}
