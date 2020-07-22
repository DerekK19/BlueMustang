//
//  File.swift
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
    }
    
}
