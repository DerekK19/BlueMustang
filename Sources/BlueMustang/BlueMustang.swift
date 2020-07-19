//
//  BlueMustang.swift
//
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation


public protocol BlueMustangDelegate {
    func blueMustang(_ blueMustang: BlueMustang, didFindAmplifier amplifier: Amplifier)
    func blueMustang(_ blueMustang: BlueMustang, didConnectAmplifier amplifier: Amplifier)
    func blueMustang(_ blueMustang: BlueMustang, didDisconnectAmplifier amplifier: Amplifier)
}
public class BlueMustang {
    
    private var delegate: BlueMustangDelegate?
    private var scanner: BluetoothScanner?
    
    public init(withDelegate delegate: BlueMustangDelegate) {
        self.delegate = delegate
    }
    
    public func findAmplifier() {
        if let scanner = scanner {
            scanner.startScanning { amplifier in
                self.delegate?.blueMustang(self, didFindAmplifier: amplifier)
            }
        } else {
            scanner = BluetoothScanner { scanner in
                scanner.startScanning { amplifier in
                   self.delegate?.blueMustang(self, didFindAmplifier: amplifier)
               }
            }
        }
    }
    
    public func connect(_ amplifier: Amplifier) {
        scanner?.connect(amplifier,
                         onConnect: { amplifier in
                            ULog.verbose("Amplifier connected")
                         },
                         onServices: { amplifier in
                            ULog.verbose("Found Services")
                         },
                         onCharacteristics: { amplifier in
                            ULog.verbose("Found Characteristics")
                            self.delegate?.blueMustang(self, didConnectAmplifier: amplifier)
        })
    }
    
    public func disconnect(_ amplifier: Amplifier) {
        scanner?.disconnect(amplifier) { amplifier in
            self.delegate?.blueMustang(self, didDisconnectAmplifier: amplifier)
        }
    }

    public func amplifier(_ amplifier: Amplifier, getPreset slot: Int, onDidGetPreset didGetPreset: @escaping (Preset) -> Void) {
        scanner?.amplifier(amplifier, getPreset: UInt8(truncatingIfNeeded: slot)) { preset in
            didGetPreset(preset)
        }
    }
    
    public func amplifier(_ amplifier: Amplifier, setPreset slot: Int, onDidGetPreset didGetPreset: @escaping (Preset) -> Void) {
        scanner?.amplifier(amplifier, setPreset: UInt8(truncatingIfNeeded: slot)) { preset in
            didGetPreset(preset)
        }
    }
}
