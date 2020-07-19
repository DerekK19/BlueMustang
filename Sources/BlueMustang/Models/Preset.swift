//
//  File.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public struct Preset {
    
    public var slot: Int? = nil
    public var name: String? = nil
    public var current: Bool = false
    public var volume: Float? = nil
    public var gain1: Float? = nil
    public var gain2: Float? = nil
    public var masterVolume: Float? = nil
    public var treble: Float? = nil
    public var middle: Float? = nil
    public var bass: Float? = nil
    public var presence: Float? = nil
    public var depth: Int? = nil
    public var bias: Int? = nil
    public var noiseGate: Int? = nil
    public var threshold: Int? = nil
    public var sag: Int? = nil
    public var brightness: Int? = nil
    public var cabinet: Int? = nil
    public var cabinetName: String? = nil
    public var model: Int? = nil
    public var modelName: String? = nil
    public var effects: [Effect]? = nil

    public init() {    
    }
    
    public var debugDescription: String {
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
        for effect in effects ?? [] {
            text += String(format: "   %@: %@ - %@ (colour %d)\n", effect.type.rawValue, effect.name ?? "-empty-", effect.enabled ? "ON" : "OFF", effect.colour)
            text += String(format: "    Knobs: %d - ", effect.knobs.count)
            effect.knobs.forEach { text += String(format: "%0.2f ", $0.value) }
            text += String(format: "slot %d (%d %d %d)\n", effect.slot, effect.aValue1, effect.aValue2, effect.aValue3)
        }
        return text
    }
    
    internal func modelName(_ model: Int?) -> String? {
        if let model = model {
            switch model {
            case 0x67: return "'57 Deluxe"
            case 0x64: return "'59 Bassman"
            case 0x7c: return "'57 Champ"
            case 0x53: return "'65 Deluxe"
            case 0x6a: return "'65 Princeton"
            case 0x75: return "'65 Twin"
            case 0x72: return "Super-Sonic"
            case 0x61: return "British '60s"
            case 0x79: return "British '70s"
            case 0x5e: return "British '80s"
            case 0x5d: return "American '90s"
            case 0x6d: return "Metal 2000"
            case 0xf1: return "Studio Pre"
            case 0xf6: return "'57 Twin"
            case 0xf9: return "'60s Thrift"
            case 0xfc: return "Brit Colour"
            case 0xff: return "Brit Watts"
            default: return nil
            }
        }
        return nil
    }
    
    internal func cabinetName(_ cabinet: Int?) -> String? {
        if let cabinet = cabinet {
            switch cabinet {
            case 0x00: return "off"
            case 0x01: return "1x10 Modern"
            case 0x02: return "2x10 Modern"
            case 0x03: return "4x10 Modern"
            case 0x04: return "4x10 Hi-Fi"
            case 0x05: return "8x10 Modern"
            case 0x06: return "8x10 Vintage"
            case 0x07: return "1x12 Modern"
            case 0x08: return "2x15 Vintage"
            case 0x09: return "4x12 Modern"
            case 0x0a: return "1x15 Vintage"
            case 0x0b: return "1x15 Modern"
            case 0x0c: return "1x18 Vintage"
            case 0x0d: return "4x10 Vintage"
            default: return nil
            }
        }
        return nil
    }

}
