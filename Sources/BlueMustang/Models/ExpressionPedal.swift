//
//  ExpressionPedal.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation
import AEXML

public class ExpressionPedal {
    
    public var volumeModeBehavior: Int
    public var expressionModeBehavior: Int
    public var heelSetting: Int
    public var toeSetting: Int
    public var pedalMode: Int
    public var bypassEffectWhenVolumeMode: Int
    public var volumeSwitchRevert: Int
    public var defaultPedalState: Int
    public var pedalOverrideState: Int
    public var parameterIndex: Int
    
    public init() {
        self.volumeModeBehavior = 0
        self.expressionModeBehavior = 0
        self.heelSetting = 0
        self.toeSetting = 0
        self.pedalMode = 0
        self.bypassEffectWhenVolumeMode = 0
        self.volumeSwitchRevert = 0
        self.defaultPedalState = 0
        self.pedalOverrideState = 0
        self.parameterIndex = 0
    }
    
    init(withElement element: AEXMLElement) {
        self.volumeModeBehavior = Int(element.attributes["VolumeModeBehavior"] ?? "0") ?? 0
        self.expressionModeBehavior = Int(element.attributes["ExpressionModeBehavior"] ?? "0") ?? 0
        self.heelSetting = Int(element.attributes["HeelSetting"] ?? "0") ?? 0
        self.toeSetting = Int(element.attributes["ToeSetting"] ?? "0") ?? 0
        self.pedalMode = Int(element.attributes["PedalMode"] ?? "0") ?? 0
        self.bypassEffectWhenVolumeMode = Int(element.attributes["BypassEffectWhenVolumeMode"] ?? "0") ?? 0
        self.volumeSwitchRevert = Int(element.attributes["VolumeSwitchRevert"] ?? "0") ?? 0
        self.defaultPedalState = Int(element.attributes["DefaultPedalState"] ?? "0") ?? 0
        self.pedalOverrideState = Int(element.attributes["PedalOverrideState"] ?? "0") ?? 0
        self.parameterIndex = Int(element.attributes["ParameterIndex"] ?? "0") ?? 0
    }
    
    func xml() -> AEXMLElement {
        let info = AEXMLElement(name: "FirstExpressionPedal",
                                attributes: ["VolumeModeBehavior" : "\(String(describing: volumeModeBehavior))",
                                             "ExpressionModeBehavior" : "\(String(describing: expressionModeBehavior))",
                                             "HeelSetting" : "\(String(describing: heelSetting))",
                                             "ToeSetting" : "\(String(describing: toeSetting))",
                                             "PedalMode" : "\(String(describing: pedalMode))",
                                             "BypassEffectWhenVolumeMode" : "\(String(describing: bypassEffectWhenVolumeMode))",
                                             "VolumeSwitchRevert" : "\(String(describing: volumeSwitchRevert))",
                                             "DefaultPedalState" : "\(String(describing: defaultPedalState))",
                                             "PedalOverrideState" : "\(String(describing: pedalOverrideState))",
                                             "ParameterIndex" : "\(String(describing: parameterIndex))"])
        return info
    }

}
