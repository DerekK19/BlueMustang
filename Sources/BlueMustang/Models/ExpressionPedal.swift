//
//  ExpressionPedal.swift
//  
//
//  Created by Derek Knight on 30/07/20.
//

import Foundation

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
    
    init(withElement element: XMLElement) {
        self.volumeModeBehavior = element.attribute(forName: "VolumeModeBehavior")?.intValue ?? 0
        self.expressionModeBehavior = element.attribute(forName: "ExpressionModeBehavior")?.intValue ?? 0
        self.heelSetting = element.attribute(forName: "HeelSetting")?.intValue ?? 0
        self.toeSetting = element.attribute(forName: "ToeSetting")?.intValue ?? 0
        self.pedalMode = element.attribute(forName: "PedalMode")?.intValue ?? 0
        self.bypassEffectWhenVolumeMode = element.attribute(forName: "BypassEffectWhenVolumeMode")?.intValue ?? 0
        self.volumeSwitchRevert = element.attribute(forName: "VolumeSwitchRevert")?.intValue ?? 0
        self.defaultPedalState = element.attribute(forName: "DefaultPedalState")?.intValue ?? 0
        self.pedalOverrideState = element.attribute(forName: "PedalOverrideState")?.intValue ?? 0
        self.parameterIndex = element.attribute(forName: "ParameterIndex")?.intValue ?? 0
    }
    
    func xml() -> XMLElement {
        let info = XMLElement(name: "FirstExpressionPedal")
        info.addAttribute(XMLNode.attribute(withName: "VolumeModeBehavior", stringValue: "\(String(describing: volumeModeBehavior))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ExpressionModeBehavior", stringValue: "\(String(describing: expressionModeBehavior))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "HeelSetting", stringValue: "\(String(describing: heelSetting))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ToeSetting", stringValue: "\(String(describing: toeSetting))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "PedalMode", stringValue: "\(String(describing: pedalMode))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "BypassEffectWhenVolumeMode", stringValue: "\(String(describing: bypassEffectWhenVolumeMode))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "VolumeSwitchRevert", stringValue: "\(String(describing: volumeSwitchRevert))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "DefaultPedalState", stringValue: "\(String(describing: defaultPedalState))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "PedalOverrideState", stringValue: "\(String(describing: pedalOverrideState))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ParameterIndex", stringValue: "\(String(describing: parameterIndex))") as! XMLNode)
        return info
    }

}
