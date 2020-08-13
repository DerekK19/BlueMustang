//
//  SongFile.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

public struct SongFile {
    
    public var location: Int
    public var name: String?

    public init(location: Int, name: String?) {
        self.location = location
        self.name = name
    }
    
    init(withElement element: AEXMLElement) {
        self.location = Int(element.attributes["Location"] ?? "0") ?? 0
        self.name = element.value
    }

    func xml() -> AEXMLElement {
        let songFile = AEXMLElement(name: "SongFile", value: name, attributes: ["Location" : "\(location)"])
        return songFile
    }

}
