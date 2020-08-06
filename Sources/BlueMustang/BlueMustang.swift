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
    func blueMustangDidSetPreset(_ blueMustang: BlueMustang)
    func blueMustangDidConfirmPresetSet(_ blueMustang: BlueMustang)
    func blueMustangDidSavePreset(_ blueMustang: BlueMustang)
    func blueMustang(_ blueMustang: BlueMustang, didChangeVolume volume: Float)
    func blueMustang(_ blueMustang: BlueMustang, didChangeGain gain: Float)
    func blueMustang(_ blueMustang: BlueMustang, didChangeTreble treble: Float)
    func blueMustang(_ blueMustang: BlueMustang, didChangeMiddle middle: Float)
    func blueMustang(_ blueMustang: BlueMustang, didChangeBass bass: Float)
    func blueMustang(_ blueMustang: BlueMustang, didChangeReverb reverb: Float)
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
        NotificationCenter.default.addObserver(self, selector: #selector(presetSet), name: .presetSet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetSetConfirmed), name: .presetSetConfirmed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetSaved), name: .presetSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: .volumeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gainChanged), name: .gainChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trebleChanged), name: .trebleChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(middleChanged), name: .middleChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bassChanged), name: .bassChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reverbChanged), name: .reverbChanged, object: nil)
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
    
    public func amplifier(_ amplifier: Amplifier, setPreset preset: Preset) {
        scanner.amplifier(amplifier, setPreset: preset)
    }
    
    public func amplifierConfirmSetPreset(_ amplifier: Amplifier) {
        scanner.amplifierConfirmSetPreset(amplifier)
    }
    
    public func amplifier(_ amplifier: Amplifier, savePreset slot: Int, name: String) {
        scanner.amplifier(amplifier, savePreset: UInt8(truncatingIfNeeded: slot), name: name)
    }
    
    public func amplifierConfirmSavePreset(_ amplifier: Amplifier) {
        scanner.amplifierConfirmSavePreset(amplifier)
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
    
    @objc func presetSet(_ notification: Notification) {
        delegate.blueMustangDidSetPreset(self)
    }
    
    @objc func presetSetConfirmed(_ notification: Notification) {
        delegate.blueMustangDidConfirmPresetSet(self)
    }
    
    @objc func presetSaved(_ notification: Notification) {
        delegate.blueMustangDidSavePreset(self)
    }
    
    @objc func volumeChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeVolume: value)
    }
    
    @objc func gainChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeGain: value)
    }
    
    @objc func trebleChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeTreble: value)
    }
    
    @objc func middleChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeMiddle: value)
    }
    
    @objc func bassChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeBass: value)
    }
    
    @objc func reverbChanged(_ notification: Notification) {
        guard let value = notification.object as? Float else { return }
        delegate.blueMustang(self, didChangeReverb: value)
    }

}
