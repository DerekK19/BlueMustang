//
//  Fuse.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

public struct Fuse {
    
    public var info: Info?

    public init(info: Info?) {
        self.info = info
    }

    init(withElement element: AEXMLElement) {
        if let infoElement = element.firstDescendant(where: { $0.name == "Info"} ) {
            self.info = Info(withElement: infoElement)
        }
    }
    
    func xml() -> AEXMLElement {
        let fuse = AEXMLElement(name: "FUSE")
        if info != nil { fuse.addChild(info!.xml()) }
        let colours = AEXMLElement(name: "PedalColors")
        colours.addChild(name: "Color", value: 14, attributes: ["ID" : "1"])
        colours.addChild(name: "Color", value: 1, attributes: ["ID" : "2"])
        colours.addChild(name: "Color", value: 2, attributes: ["ID" : "3"])
        colours.addChild(name: "Color", value: 10, attributes: ["ID" : "4"])
        fuse.addChild(colours)
        return fuse
    }
    
}
