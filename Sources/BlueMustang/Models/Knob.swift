//
//  Knob.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public struct Knob {

    public var name: String? = nil
    public var value: Float

    public init(value: Float, name: String? = nil) {
        self.value = value
        self.name = name
    }
    
    init(withValue value: Int, name: String?) {
        let floatValue = Float(value) / 255.0
        self.value = floatValue
        self.name = name
    }    
    
}
