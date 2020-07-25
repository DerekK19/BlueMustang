//
//  SongFile.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

public struct SongFile {
    
    public var location: Int
    public var name: String?

    public init(location: Int, name: String?) {
        self.location = location
        self.name = name
    }
    
    init(withElement element: XMLElement) {
        self.location = element.attribute(forName: "Location")?.intValue ?? 0
        self.name = element.stringValue
    }

    func xml() -> XMLElement {
        let songFile = XMLElement(name: "SongFile")
        songFile.addAttribute(XMLNode.attribute(withName: "Location", stringValue: "\(location)") as! XMLNode)
        songFile.stringValue = name
        return songFile
    }

}
