//
//  File.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public struct Preset {
    
    public var slot: Int8?
    var name: String?
    let current: Bool
    public var volume: Float?
    public var gain1: Float?
    public var gain2: Float?
    public var masterVolume: Float?
    public var treble: Float?
    public var middle: Float?
    public var bass: Float?
    public var presence: Float?
    public var depth: Int?
    public var bias: Int?
    public var noiseGate: Int?
    public var threshold: Int?
    public var sag: Int?
    public var brightness: Int?
    public var cabinet: Int?
    public var cabinetName: String?
    public var model: Int?
    public var modelName: String?
    var effects: [Effect]

    var debugDescription: String {
        var text = "\n"
        if let slot = slot {
            text += String(format:"  Preset %d - %@\n", slot, name ?? "-unknown-")
        } else {
            text += String(format:"  Preset -unknown- - %@\n", name ?? "-unknown-")
        }
        if let gain1 = gain1 {
            text += String(format: "   Gain 1: %0.2f\n", gain1)
        } else {
            text += "   Gain 1: -unset-\n"
        }
        if let gain2 = gain2 {
            text += String(format: "   Gain 2: %0.2f\n", gain2)
        } else {
            text += "   Gain 2: -unset-\n"
        }
        if let volume = volume {
            text += String(format: "   Volume: %0.2f\n", volume)
        } else {
            text += "   Volume: -unset-\n"
        }
        if let treble = treble {
            text += String(format: "   Treble: %0.2f\n", treble)
        } else {
            text += "   Treble: -unset-\n"
        }
        if let middle = middle {
            text += String(format: "   Middle: %0.2f\n", middle)
        } else {
            text += "   Middle: -unset-\n"
        }
        if let bass = bass {
            text += String(format: "   Bass: %0.2f\n", bass)
        } else {
            text += "   Bass: -unset-\n"
        }
        if let presence = presence {
            text += String(format: "   Reverb/Presence: %0.2f\n", presence)
        } else {
            text += "   Reverb/Presence: -unset-\n"
        }
        text += String(format: "   Model: %@\n", modelName ?? "-unknown-")
        text += String(format: "   Cabinet: %@\n", cabinetName ?? "-unknown-")
        for effect in effects {
            text += String(format: "   %@: %@ - %@ (colour %d)\n", effect.type.rawValue, effect.name ?? "-empty-", effect.enabled ? "ON" : "OFF", effect.colour)
            text += String(format: "    Knobs: %d - ", effect.knobs.count)
            effect.knobs.forEach { text += String(format: "%0.2f ", $0.value) }
            text += String(format: "slot %d (%d %d %d)\n", effect.slot, effect.aValue1, effect.aValue2, effect.aValue3)
        }
        return text
    }
    

}
