//
//  Effect.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation
import AEXML

public enum EffectType : String {
    case unknown = ""
    case stomp = "Stomp Box"
    case modulation = "Modulation"
    case delay = "Delay"
    case reverb = "Reverb"
}

public struct Effect {

    public let type : EffectType
    public let module: UInt16
    public var slot: Int
    public var enabled: Bool
    public var colour: Int
    public var knobs: [Knob] = []
    public let name: String?
    public let aValue1: Int? = nil
    public let aValue2: Int? = nil
    public let aValue3: Int? = nil

    public init(slot: Int, type: EffectType, module: Int, enabled: Bool, knobs: [Knob]) {
        let names: (String?, [String])
        self.module = UInt16(module)
        switch type {
        case .stomp:
            names = Effect.stompNames(self.module)
        case .modulation:
            names = Effect.modulationNames(self.module)
        case .delay:
            names = Effect.delayNames(self.module)
        case .reverb:
            names = Effect.reverbNames(self.module)
        default:
            names = (nil, [])
        }
        self.slot = slot
        self.type = type
        self.enabled = enabled
        self.colour = self.type == .stomp ? 14 : self.type == .modulation ? 1 : self.type == .delay ? 2 : self.type == .reverb ? 10 : 0
        self.knobs = Array(knobs[..<names.1.count])
        for i in 0..<self.knobs.count {
            self.knobs[i].name = names.1[i]
        }
        name = names.0
    }

    internal init(slot: Int, type: UInt8, module: UInt16, enabled: Bool, knobs: [Knob]) {
        let names: (String?, [String])
        switch type {
        case 0x06:
            self.type = .stomp
            names = Effect.stompNames(module)
        case 0x07:
            self.type = .modulation
            names = Effect.modulationNames(module)
        case 0x08:
            self.type = .delay
            names = Effect.delayNames(module)
        case 0x09:
            self.type = .reverb
            names = Effect.reverbNames(module)
        default:
            self.type = .unknown
            names = (nil, [])
        }
        self.slot = slot
        self.enabled = enabled
        self.module = module
        self.colour = self.type == .stomp ? 14 : self.type == .modulation ? 1 : self.type == .delay ? 2 : self.type == .reverb ? 10 : 0
        self.knobs = Array(knobs[..<names.1.count])
        for i in 0..<self.knobs.count {
            self.knobs[i].name = names.1[i]
        }
        name = names.0
    }

    init(withType type: EffectType, element: AEXMLElement) {
        if let module = element.firstDescendant(where: { $0.name == "Module" }) {
            if let id = Int(module.attributes["ID"] ?? "xx") {
                if let pos = Int(module.attributes["POS"] ?? "xx") {
                    self.module = UInt16(id).byteSwapped
                    self.slot = pos
                    self.enabled = pos > 0
                    let names: (String?, [String])
                    switch type {
                    case .stomp:
                        names = Effect.stompNames(self.module)
                        self.type = type
                        self.colour = 14
                    case .modulation:
                        names = Effect.modulationNames(self.module)
                        self.type = type
                        self.colour = 1
                    case .delay:
                        names = Effect.delayNames(self.module)
                        self.type = type
                        self.colour = 2
                    case .reverb:
                        names = Effect.reverbNames(self.module)
                        self.type = type
                        self.colour = 10
                    default:
                        self.type = .unknown
                        self.colour = 0
                        names = (nil, [])
                    }
                    name = names.0
//                    self.aValue1 = 0
//                    self.aValue2 = 0
//                    self.aValue3 = 0
                    self.knobs = [Knob]()
                    for param in module.allDescendants(where:  { $0.name == "Param"} ) {
                        if let index = Int(param.attributes["ControlIndex"] ?? "xx") {
                            if let value = param.intValue {
                                let shiftRightValue = value >> 8
                                switch index {
                                case 0...5:
                                    let knob = Knob(withValue: shiftRightValue)
                                    self.knobs.append(knob)
                                default:
                                    NSLog("Param: \(param)")
                                    NSLog("Can't process effect control index \(index) - value '\(value) - \(shiftRightValue)'")
                                }
                            }
                        }
                    }
                    return
                }
            }
        }
        self.module = 0
        self.slot = 0
        self.enabled = false
        self.colour = 0
        self.type = .unknown
        self.name = nil
    }
    
    private static func stompNames(_ module: UInt16?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x3c00: return ("Overdrive", ["Level", "Gain", "Low", "Mid", "High"])
            case 0x4900: return ("Wah", ["Mix", "Freq", "Heel Freq", "Toe Freq", "High Q"])
            case 0x4a00: return ("Touch Wah", ["Mix", "Sensitivity", "Min Freq", "Max Freq", "High Q"])
            case 0x1a00: return ("Fuzz", ["Level", "Gain", "Octave", "Low", "High"])
            case 0x1c00: return ("Fuzz Wah", ["Level", "Gain", "Sensitivity", "Octave", "Peak"])
            case 0x8800: return ("Simple Comp", ["Type"])
            case 0x0700: return ("Compressor", ["Level", "Threshold", "Ratio", "Attack", "Release"])
            case 0x0301: return ("Ranger", ["Level", "Gain", "Locut", "Bright"])
            case 0xba00: return ("Greenbox", ["Level", "Gain", "Tone", "Blend"])
            case 0x1001: return ("Orangebox", ["Level", "Dist", "Tone"])
            case 0x1101: return ("Blackbox", ["Level", "Distortion", "Filter"])
            case 0x0f01: return ("Big Fuzz", ["Level", "Tone", "Sustain"])
            default: break
            }
        }
        return (nil, [])
    }

    private static func modulationNames(_ module: UInt16?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x1200: return ("Sine Chorus", ["Level", "Rate", "Depth", "Avg Delay", "LT Phase"])
            case 0x1300: return ("Tri Chorus", ["Level", "Rate", "Depth", "Avg Delay", "LT Phase"])
            case 0x1800: return ("Sine Flanger", ["Level", "Rate", "Depth", "Feedbacky", "LT Phase"])
            case 0x1900: return ("Tri Flanger", ["Level", "Rate", "Depth", "Feedbacky", "LT Phase"])
            case 0x2d00: return ("Vibratone", ["Level", "Rate", "Depth", "Feedbacky", "Rotor"])
            case 0x4000: return ("Vintage Trem", ["Level", "Rate", "Dut Cycle", "Attach", "Release"])
            case 0x4100: return ("Sine Trem", ["Level", "Rate", "Dut Cycle", "LFO Clip", "Shape"])
            case 0x2200: return ("Ring Mod", ["Level", "Frequency", "Depth", "Shape", "Phase"])
            case 0x2900: return ("Step Filt", ["Level", "Rate", "Resonance", "Min Freq", "Max Freq"])
            case 0x4f00: return ("Phaser", ["Level", "Rate", "Depth", "Feedback", "Shape"])
            case 0x1f00: return ("Pitch Shift", ["Mix", "Pitch", "Pre Delay", "Feedback", "Tone"])
            case 0xf400: return ("Wah", ["Mix", "Freq", "Heel Freq", "Toe Freq", "High Q"])
            case 0xf500: return ("Touch Wah", ["Mix", "Sensitivity", "Min Freq", "Max Freq", "High Q"])
            case 0x1f10: return ("Dia Pitch", ["Mix", "Pitch", "Key", "Scale", "Tone"])
            default: break
            }
        }
        return (nil, [])
    }

    private static func delayNames(_ module: UInt16?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x1600: return ("Mono", ["Level", "Delay", "Feedback", "Bright", "Attenuation"])
            case 0x4300: return ("Mono Echo", ["Level", "Delay", "Feedback", "Frequency", "Level", "In Level"])
            case 0x4800: return ("Stereo Echo", ["Level", "Delay", "Feedback", "Frequency", "Level", "In Level"])
            case 0x4400: return ("Multi Tap", ["Level", "Delay", "Bright", "Mode", ""])
            case 0x4500: return ("Ping Pong", ["Level", "Delay", "Feedback", "Bright", ""])
            case 0x1500: return ("Ducking", ["Level", "Delay", "Feedback", "Release", "Threshold"])
            case 0x4600: return ("Reverse", ["Level", "Delay", "Feedback", "Tone", "Rev Feedback"])
            case 0x2b00: return ("Tape", ["Level", "Delay", "Feedback", "Bright", "Flutter", "Stereo"])
            case 0x2a00: return ("Stereo Tape", ["Level", "Delay", "Feedback", "Bright", "Flutter", "Stereo"])
            default: break
            }
        }
        return (nil, [])
    }

    private static func reverbNames(_ module: UInt16?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x2400: return ("Small Hall", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x3a00: return ("Large Hall", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x2600: return ("Small Room", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x3b00: return ("Large Room", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4e00: return ("Small Plate", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4b00: return ("Large Plate", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4c00: return ("Ambient", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4d00: return ("Arena", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x2100: return ("'63 Spring", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x0b00: return ("'65 Spring", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            default: break
            }
        }
        return (nil, [])
    }
}
