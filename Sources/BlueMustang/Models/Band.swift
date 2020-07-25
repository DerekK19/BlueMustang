//
//  Band.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

public struct Band {
    
    public var type: Int
    public var iRepeat: Int
    public var audioMix: Int
    public var balance: Int
    public var speed: Int
    public var pitch: Int
    public var songFile: SongFile?

    public init(type: Int, iRepeat: Int, audioMix: Int, balance: Int, speed: Int, pitch: Int, songFile: SongFile?) {
        self.type = type
        self.iRepeat = iRepeat
        self.audioMix = audioMix
        self.balance = balance
        self.speed = speed
        self.pitch = pitch
        self.songFile = songFile
    }
    
    init(withElement element: XMLElement) {
        self.type = element.attribute(forName: "Type")?.intValue ?? 0
        self.iRepeat = element.attribute(forName: "Repeat")?.intValue ?? 0
        self.audioMix = element.elements(forName: "AudioMix").first?.intValue ?? 0
        self.balance = element.elements(forName: "Balance").first?.intValue ?? 0
        self.speed = element.elements(forName: "Speed").first?.intValue ?? 0
        self.pitch = element.elements(forName: "Pitch").first?.intValue ?? 0
        if let songElement = element.elements(forName: "SongFile").first {
            self.songFile = SongFile.init(withElement: songElement)
        }
    }
    
    func xml() -> XMLElement {
        let band = XMLElement(name: "Band")
        band.addAttribute(XMLNode.attribute(withName: "Type", stringValue: "\(type)") as! XMLNode)
        band.addAttribute(XMLNode.attribute(withName: "Repeat", stringValue: "\(iRepeat)") as! XMLNode)
        band.addChild(songFile?.xml() ?? XMLElement(name: "SongFile"))
        band.addChild(name: "AudioMix", value: "\(audioMix)", attributes: [:])
        band.addChild(name: "Balance", value: "\(balance)", attributes: [:])
        band.addChild(name: "Speed", value: "\(speed)", attributes: [:])
        band.addChild(name: "Pitch", value: "\(pitch)", attributes: [:])
        band.addChild(XMLElement(name: "Tempo"))
        band.addChild(XMLElement(name: "Transpose"))
        band.addChild(XMLElement(name: "DrumSolo"))
        band.addChild(XMLElement(name: "CountIn"))
        return band
    }
    

}
