//
//  Info.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

public struct Info {
    public var name: String
    public var author: String
    public var rating: Int
    public var genre1: Int
    public var genre2: Int
    public var genre3: Int
    public var tags: String
    public var fenderid: Int

    public init(name: String, author: String, rating: Int, genre1: Int, genre2: Int, genre3: Int, tags: String, fenderid: Int) {
        self.name = name
        self.author = author
        self.rating = rating
        self.genre1 = genre1
        self.genre2 = genre2
        self.genre3 = genre3
        self.tags = tags
        self.fenderid = fenderid
    }

    init(withElement element: XMLElement) {
        self.name = element.attribute(forName: "name")?.stringValue ?? ""
        self.author = element.attribute(forName: "author")?.stringValue ?? ""
        self.rating = element.attribute(forName: "rating")?.intValue ?? 0
        self.genre1 = element.attribute(forName: "genre1")?.intValue ?? -1
        self.genre2 = element.attribute(forName: "genre2")?.intValue ?? -1
        self.genre3 = element.attribute(forName: "genre3")?.intValue ?? -1
        self.tags = element.attribute(forName: "tags")?.stringValue ?? ""
        self.fenderid = element.attribute(forName: "fenderid")?.intValue ?? 0
    }
    
    func xml() -> XMLElement {
        let info = XMLElement(name: "Info")
        info.addAttribute(XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "author", stringValue: author) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "rating", stringValue: "\(rating)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre1", stringValue: "\(genre1)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre2", stringValue: "\(genre2)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre3", stringValue: "\(genre3)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "tags", stringValue: tags) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "fenderid", stringValue: "\(fenderid)") as! XMLNode)
        return info
    }
    
}
