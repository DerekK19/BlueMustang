//
//  BlueMustang.swift
//
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation

public protocol BlueMustangDelegate {
    func blueMustangIsReadyToScan(_ blueMustang: BlueMustang)
    func blueMustang(_ blueMustang: BlueMustang, didFindAmplifier amplifier: Amplifier)
    func blueMustang(_ blueMustang: BlueMustang, didConnectAmplifier amplifier: Amplifier)
    func blueMustang(_ blueMustang: BlueMustang, didDisconnectAmplifier amplifier: Amplifier)
    func blueMustang(_ blueMustang: BlueMustang, didDiscoverAmplifierName name: String)
    func blueMustang(_ blueMustang: BlueMustang, didDiscoverPresetCount count: Int)
    func blueMustang(_ blueMustang: BlueMustang, didDiscoverPreset preset: Preset)
    func blueMustangCannotScan(_ blueMustang: BlueMustang)
}

public class BlueMustang {
    
    private let delegate: BlueMustangDelegate
    private let scanner: BluetoothScanner
    
    public init(withDelegate delegate: BlueMustangDelegate) {
        self.delegate = delegate
        scanner = BluetoothScanner()
        NotificationCenter.default.addObserver(self, selector: #selector(readyToScan), name: .readyToScan, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(amplifierNameDiscovered), name: .amplifierNameDiscovered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetCountDiscovered), name: .presetCountDiscovered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetDiscovered), name: .presetDiscovered, object: nil)
    }
    
    public func connect(_ amplifier: Amplifier) {
        scanner.connect(amplifier,
                         onConnect: { amplifier in
                            ULog.verbose("Amplifier connected")
                         },
                         onServices: { amplifier in
                            ULog.verbose("Found Services")
                         },
                         onCharacteristics: { amplifier in
                            ULog.verbose("Found Characteristics")
                            self.delegate.blueMustang(self, didConnectAmplifier: amplifier)
        })
    }
    
    public func disconnect(_ amplifier: Amplifier) {
        scanner.disconnect(amplifier) { amplifier in
            self.delegate.blueMustang(self, didDisconnectAmplifier: amplifier)
        }
    }

    public func amplifier(_ amplifier: Amplifier, getPreset slot: Int) {
        scanner.amplifier(amplifier, getPreset: UInt8(truncatingIfNeeded: slot))
    }
    
    public func amplifier(_ amplifier: Amplifier, setPreset slot: Int) {
        scanner.amplifier(amplifier, setPreset: UInt8(truncatingIfNeeded: slot))
    }
    
    // MARK: - Notification handlers
    
    @objc func readyToScan(_ notification: Notification) {
        guard let ready = notification.object as? Bool else { return }
        if ready {
            delegate.blueMustangIsReadyToScan(self)
            scanner.startScanning { amplifier in
                self.delegate.blueMustang(self, didFindAmplifier: amplifier)
            }
        } else {
            delegate.blueMustangCannotScan(self)
        }
    }
    
    @objc func amplifierNameDiscovered(_ notification: Notification) {
        guard let name = notification.object as? String else { return }
        delegate.blueMustang(self, didDiscoverAmplifierName: name)
    }

    @objc func presetCountDiscovered(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        delegate.blueMustang(self, didDiscoverPresetCount: count)
    }

    @objc func presetDiscovered(_ notification: Notification) {
        guard let preset = notification.object as? Preset else { return }
        delegate.blueMustang(self, didDiscoverPreset: preset)
    }
}
