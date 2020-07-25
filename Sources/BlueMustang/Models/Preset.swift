//
//  Preset.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public enum DataLayerError: Error {
    case invalidXML
}

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
    private var unknown1: UInt8 = 0
    private var unknown2: UInt8 = 0
    private var unknown3: UInt8 = 0
    private var unknown4: UInt8 = 0
    private var unknown5: UInt8 = 0
    private var unknown6: UInt8 = 0
    private var unknown7: UInt8 = 0
    private var unknown8: UInt8 = 0
    public var band: Band? = nil
    public var fuse: Fuse? = nil
    private var usbGain: Int? = nil
    private var amplifier: Amplifier?
    private var expressionPedal: ExpressionPedal? = nil


    public init() {    
    }
    
    public init(xml document: XMLDocument) throws {
        if let root = document.rootElement() {
            self.slot = nil
            self.current = false
            self.effects = [Effect]()
            self.usbGain = root.elements(forName: "UsbGain").first?.intValue
            if let bandElement = root.elements(forName: "Band").first {
                self.band = Band(withElement: bandElement)
            }
            if let fuseElement = root.elements(forName: "FUSE").first {
                self.fuse = Fuse(withElement: fuseElement)
            }
            if let expressionPedalElement = root.elements(forName: "FirstExpressionPedal").first {
                self.expressionPedal = ExpressionPedal(withElement: expressionPedalElement)
            }
            self.name = self.fuse?.info?.name ?? "Preset"
            if let amp = root.elements(forName: "Amplifier").first {
                if let module = amp.elements(forName: "Module").first {
                    if let id = module.attribute(forName: "ID")?.intValue {
                        self.model = id
                    }
                    for param in module.elements(forName: "Param") {
                        if let index = param.attribute(forName: "ControlIndex")?.intValue {
                            if let value = param.intValue {
                                let uValue = UInt8(value & 0xff)
                                let shiftRightValue = value >> 8
                                let uShiftRightValue = UInt8(shiftRightValue)
                                let floatValue = Float(uShiftRightValue) / 255.0
                                switch index {
                                case 0: self.volume = floatValue
                                case 1: self.gain1 = floatValue
                                case 2: self.gain2 = floatValue
                                case 3: self.masterVolume = floatValue
                                case 4: self.treble = floatValue
                                case 5: self.middle = floatValue
                                case 6: self.bass = floatValue
                                case 7: self.presence = floatValue
                                case 8: self.unknown1 = uShiftRightValue
                                case 9: self.depth = shiftRightValue
                                case 10: self.bias = shiftRightValue
                                case 11: self.unknown2 = uShiftRightValue
                                case 12: self.unknown3 = uValue
                                case 13: self.unknown4 = uValue
                                case 14: self.unknown5 = uValue
                                case 15: self.noiseGate = value
                                case 16: self.threshold = value
                                case 17: self.cabinet = value
                                case 18: self.unknown6 = uValue
                                case 19: self.sag = value
                                case 20: self.brightness = value
                                case 21: self.unknown7 = uValue
                                case 22: self.unknown8 = uValue
                                default:
                                    NSLog("Param: \(param)")
                                    NSLog("Can't process preset control index \(index) - value '\(String(describing: param.stringValue))'")
                                }
                            }
                        }
                    }
                }
            }
            if let fx = root.elements(forName: "FX").first {
                if let stomp = fx.elements(forName: "Stompbox").first {
                    let effect = Effect(withType: .stomp, element: stomp)
                    if effect.knobs.count > 0 {
                        self.effects?.append(effect)
                    }
                }
                if let mod = fx.elements(forName: "Modulation").first {
                    let effect = Effect(withType: .modulation, element: mod)
                    if effect.knobs.count > 0 {
                        self.effects?.append(effect)
                    }
                }
                if let delay = fx.elements(forName: "Delay").first {
                    let effect = Effect(withType: .delay, element: delay)
                    if effect.knobs.count > 0 {
                        self.effects?.append(effect)
                    }
                }
                if let reverb = fx.elements(forName: "Reverb").first {
                    let effect = Effect(withType: .reverb, element: reverb)
                    if effect.knobs.count > 0 {
                        self.effects?.append(effect)
                    }
                }
            }
            return
        }
        throw DataLayerError.invalidXML

    }
    
    public func xml() -> XMLDocument {
        let doc = XMLDocument()
        let preset = XMLElement(name: "Preset")
        preset.addAttribute(XMLNode.attribute(withName: "amplifier", stringValue: amplifier?.name ?? "Unknown Mustang") as! XMLNode)
        preset.addAttribute(XMLNode.attribute(withName: "ProductID", stringValue: "\(amplifier?.product ?? 0)") as! XMLNode)
        let amp = XMLElement(name: "Amplifier")
        let module = XMLElement(name: "Module")
        module.addAttribute(XMLNode.attribute(withName: "ID", stringValue: "\(self.model!)") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "POS", stringValue: "0") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "BypassState", stringValue: "1") as! XMLNode)
        module.addChild(name: "Param", value: UInt8(self.volume ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "0"])
        module.addChild(name: "Param", value: UInt8(self.gain1 ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "1"])
        module.addChild(name: "Param", value: UInt8(self.gain2 ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "2"])
        module.addChild(name: "Param", value: UInt8(self.masterVolume ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "3"])
        module.addChild(name: "Param", value: UInt8(self.treble ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "4"])
        module.addChild(name: "Param", value: UInt8(self.middle ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "5"])
        module.addChild(name: "Param", value: UInt8( self.bass ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "6"])
        module.addChild(name: "Param", value: UInt8(self.presence ?? 0 * 255.0) << 8, attributes: ["ControlIndex" : "7"])
        module.addChild(name: "Param", value: Int(self.unknown1) << 8, attributes: ["ControlIndex" : "8"])
        module.addChild(name: "Param", value: self.depth ?? 0 << 8, attributes: ["ControlIndex" : "9"])
        module.addChild(name: "Param", value: self.bias ?? 0 << 8, attributes: ["ControlIndex" : "10"])
        module.addChild(name: "Param", value: Int(self.unknown2) << 8, attributes: ["ControlIndex" : "11"])
        module.addChild(name: "Param", value: Int(self.unknown3), attributes: ["ControlIndex" : "12"])
        module.addChild(name: "Param", value: Int(self.unknown4), attributes: ["ControlIndex" : "13"])
        module.addChild(name: "Param", value: Int(self.unknown5), attributes: ["ControlIndex" : "14"])
        module.addChild(name: "Param", value: self.noiseGate as Any, attributes: ["ControlIndex" : "15"])
        module.addChild(name: "Param", value: self.threshold as Any, attributes: ["ControlIndex" : "16"])
        module.addChild(name: "Param", value: self.cabinet as Any, attributes: ["ControlIndex" : "17"])
        module.addChild(name: "Param", value: Int(self.unknown6), attributes: ["ControlIndex" : "18"])
        module.addChild(name: "Param", value: self.sag as Any, attributes: ["ControlIndex" : "19"])
        module.addChild(name: "Param", value: self.brightness as Any, attributes: ["ControlIndex" : "20"])
        module.addChild(name: "Param", value: Int(self.unknown7), attributes: ["ControlIndex" : "21"])
        module.addChild(name: "Param", value: Int(self.unknown8), attributes: ["ControlIndex" : "22"])
        amp.addChild(module)
        preset.addChild(amp)
        let effects = XMLElement(name: "FX")
        effects.addChild(xmlForEffect(ofType: .stomp))
        effects.addChild(xmlForEffect(ofType: .modulation))
        effects.addChild(xmlForEffect(ofType: .delay))
        effects.addChild(xmlForEffect(ofType: .reverb))
        preset.addChild(effects)
        if let band = band { preset.addChild(band.xml()) }
        if let fuse = fuse { preset.addChild(fuse.xml()) }
        if let expressionPedal = expressionPedal { preset.addChild(expressionPedal.xml()) }
        preset.addChild(name: "UsbGain", value: usbGain as Any, attributes: [:])
        doc.addChild(preset)
        
        return doc
    }
    
    private func xmlForEffect(ofType type: EffectType) -> XMLElement {
        let module = XMLElement(name: "Module")
        var id: String = "0"
        var pos: String? = nil
        for oneEffect in self.effects ?? [] {
            if oneEffect.type != type { continue }
            id = "\(oneEffect.module >> 8)"
            pos = "\(oneEffect.slot)"
            var index = 0
            for knob in oneEffect.knobs {
                module.addChild(name: "Param", value: UInt8(knob.value * 255.0) << 8, attributes: ["ControlIndex" : "\(index)"])
                index += 1
            }
            break
        }
        var effect: XMLElement!
        switch type as EffectType {
        case .stomp:
            effect = XMLElement(name: "Stompbox")
            pos = pos ?? "5"
        case .modulation:
            effect = XMLElement(name: "Modulation")
            pos = pos ?? "5"
        case .delay:
            effect = XMLElement(name: "Delay")
            pos = pos ?? "6"
        case .reverb:
            effect = XMLElement(name: "Reverb")
            pos = pos ?? "7"
        default:
            effect = XMLElement(name: "Effect")
            pos = pos ?? "5"
        }
        effect.addAttribute(XMLNode.attribute(withName: "ID", stringValue: "\(type.rawValue)") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "ID", stringValue: id) as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "POS", stringValue: pos!) as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "BypassState", stringValue: "1") as! XMLNode)
        effect.addChild(module)

        return effect
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
            text += String(format: "slot %d (%d %d %d)\n", effect.slot, effect.aValue1 ?? 0, effect.aValue2 ?? 0, effect.aValue3 ?? 0)
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
