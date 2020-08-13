//
//  Band.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

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
    
    init(withElement element: AEXMLElement) {
        self.type = Int(element.attributes["Type"] ?? "0") ?? 0
        self.iRepeat = Int(element.attributes["Repeat"] ?? "0") ?? 0
        self.audioMix = element.firstDescendant(where: { $0.name == "AudioMix" })?.intValue ?? 0
        self.balance = element.firstDescendant(where: { $0.name == "Balance" })?.intValue ?? 0
        self.speed = element.firstDescendant(where: { $0.name == "Speed" })?.intValue ?? 0
        self.pitch = element.firstDescendant(where: { $0.name == "Pitch" })?.intValue ?? 0
        if let songElement = element.firstDescendant(where: { $0.name == "SongFile"}) {
            self.songFile = SongFile.init(withElement: songElement)
        }
    }
    
    func xml() -> AEXMLElement {
        let band = AEXMLElement(name: "Band",
                                attributes: ["Type" : "\(type)",
                                             "Repeat" : "\(iRepeat)"])
        band.addChild(songFile?.xml() ?? AEXMLElement(name: "SongFile"))
        band.addChild(name: "AudioMix", value: "\(audioMix)")
        band.addChild(name: "Balance", value: "\(balance)")
        band.addChild(name: "Speed", value: "\(speed)")
        band.addChild(name: "Pitch", value: "\(pitch)")
        band.addChild(AEXMLElement(name: "Tempo"))
        band.addChild(AEXMLElement(name: "Transpose"))
        band.addChild(AEXMLElement(name: "DrumSolo"))
        band.addChild(AEXMLElement(name: "CountIn"))
        return band
    }
    

}
