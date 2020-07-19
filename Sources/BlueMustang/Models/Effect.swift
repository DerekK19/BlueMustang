//
//  File.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public enum EffectType : String {
    case Unknown = ""
    case Stomp = "Stomp Box"
    case Modulation = "Modulation"
    case Delay = "Delay"
    case Reverb = "Reverb"
}

public struct Effect {

    let type : EffectType
    let module: Int
    var slot: Int
    var enabled: Bool
    var colour: Int
    var knobs: [Knob]
    let name: String?
    var knobCount: Int
    let aValue1: Int
    let aValue2: Int
    let aValue3: Int

}
