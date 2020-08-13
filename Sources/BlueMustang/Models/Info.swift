//
//  Info.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

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
    
    init(withElement element: AEXMLElement) {
        self.name = element.attributes["name"] ?? ""
        self.author = element.attributes["author"] ?? ""
        self.rating = Int(element.attributes["rating"] ?? "0") ?? 0
        self.genre1 = Int(element.attributes["genre1"] ?? "-1") ?? -1
        self.genre2 = Int(element.attributes["genre2"] ?? "-1") ?? -1
        self.genre3 = Int(element.attributes["genre3"] ?? "-1") ?? -1
        self.tags = element.attributes["tags"] ?? ""
        self.fenderid = Int(element.attributes["fenderid"] ?? "0") ?? 0
    }
    
    func xml() -> AEXMLElement {
        let info = AEXMLElement(name: "Info",
                                attributes: ["name" : name,
                                             "author" : author,
                                             "rating" : "\(rating)",
                                             "genre1" : "\(genre1)",
                                             "genre2" : "\(genre2)",
                                             "genre3" : "\(genre3)",
                                             "tags" : tags,
                                             "fenderid" : "\(fenderid)"])
        return info
    }
    
}
