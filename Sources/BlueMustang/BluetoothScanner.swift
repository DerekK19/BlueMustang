//
//  BluetoothScanner.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation
import CoreBluetooth

extension CBPeripheralState {
    var stringRepresentation: String {
        switch self {
        case .disconnected: return "disconnected"
        case .connected: return "connected"
        case .connecting: return "connecting"
        case .disconnecting: return "disconnecting"
        default: return "Unknown"
        }
    }
}

extension CBPeripheral {
    public func asAmplifier() -> Amplifier {
        return Amplifier(peripheral: self)
    }
    public func asAmplifier(advertisementData: [String: Any], rssi: Int) -> Amplifier {
        return Amplifier(peripheral: self, advertisementData: advertisementData, rssi: rssi)
    }
}

internal extension Notification.Name {
    static let readyToScan = Notification.Name("BlueMustang.readyToScan")
    static let amplifierNameDiscovered = Notification.Name("BlueMustang.amplifierNameDiscovered")
    static let presetCountDiscovered = Notification.Name("BlueMustang.presetCountDiscovered")
    static let presetDiscovered = Notification.Name("BlueMustang.presetDiscovered")
    static let presetSet = Notification.Name("BlueMustang.presetSet")
    static let presetSetConfirmed = Notification.Name("BlueMustang.presetSetConfirmed")
    static let presetSaved = Notification.Name("BlueMustang.presetSaved")
    static let volumeChanged = Notification.Name("BlueMustang.volumeChanged")
    static let gainChanged = Notification.Name("BlueMustang.gainChanged")
    static let trebleChanged = Notification.Name("BlueMustang.trebleChanged")
    static let middleChanged = Notification.Name("BlueMustang.middleChanged")
    static let bassChanged = Notification.Name("BlueMustang.bassChanged")
    static let reverbChanged = Notification.Name("BlueMustang.reverbChanged")
}

class BluetoothScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    private let HIDUUID: CBUUID = CBUUID(string: "1812")
    private let AMPLIFIER_SERVICE_UUID: CBUUID            = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130000")
    private let AMPLIFIER_NAME_CHRC_UUID: CBUUID          = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130001")
    private let AMPLIFIER_PRESET_COUNT_CHRC_UUID: CBUUID  = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130002")
    private let AMPLIFIER_PRESET_CHRC_UUID: CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130003")
    private let AMPLIFIER_CONTROL_CHRC_UUID : CBUUID      = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130004")

    private var centralManager: CBCentralManager!
    private var serviceDiscoveryInProgress = false

    private var onAmplifierDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierServicesDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierCharacteristicsDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierConnected: ((Amplifier) -> Void)?
    private var onAmplifierDisconnected: ((Amplifier) -> Void)?

    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    internal func startScanning(_ onDiscover: @escaping (Amplifier) -> Void) {
        self.onAmplifierDiscovered = onDiscover
        centralManager.scanForPeripherals(withServices: [HIDUUID], options: nil)
    }
    
    internal func connect(_ amplifier: Amplifier, onConnect: @escaping (Amplifier) -> Void, onServices: @escaping (Amplifier) -> Void, onCharacteristics: @escaping (Amplifier) -> Void) {
        self.onAmplifierConnected = onConnect
        self.onAmplifierServicesDiscovered = onServices
        self.onAmplifierCharacteristicsDiscovered = onCharacteristics
        serviceDiscoveryInProgress = false
        centralManager.connect(amplifier.peripheral, options: nil)
    }
    
    internal func amplifier(_ amplifier: Amplifier, getPreset slot: UInt8) {
        var data = Data(repeating: 0, count: 2)
        data[0] = 0x00 // Choose preset in the supplied slot
        data[1] = slot
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID, value: data, forAmplifier: amplifier)
    }
    
    internal func amplifier(_ amplifier: Amplifier, setPreset preset: Preset) {
        let name = Data((preset.name ?? "").utf8)
        var data = Data(repeating: 0, count: 20 + name.count + ((preset.effects?.count ?? 0) * 11))
        data[0] = 0x01 // Change the settings for the current preset
        data[1] = UInt8(truncatingIfNeeded: preset.slot ?? 0)
        data[2] = UInt8(truncatingIfNeeded: Int((preset.volume ?? 0.0) * 255))
        data[3] = UInt8(truncatingIfNeeded: Int((preset.masterVolume ?? 0.0) * 255))
        data[4] = UInt8(truncatingIfNeeded: Int((preset.gain1 ?? 0.0) * 255))
        data[5] = UInt8(truncatingIfNeeded: Int((preset.gain2 ?? 0.0) * 255))
        data[6] = UInt8(truncatingIfNeeded: Int((preset.treble ?? 0.0) * 255))
        data[7] = UInt8(truncatingIfNeeded: Int((preset.middle ?? 0.0) * 255))
        data[8] = UInt8(truncatingIfNeeded: Int((preset.bass ?? 0.0) * 255))
        data[9] = UInt8(truncatingIfNeeded: Int((preset.presence ?? 0.0) * 255))
        data[10] = UInt8(truncatingIfNeeded: preset.depth ?? 0)
        data[11] = UInt8(truncatingIfNeeded: preset.bias ?? 0)
        data[12] = UInt8(truncatingIfNeeded: preset.noiseGate ?? 0)
        data[13] = UInt8(truncatingIfNeeded: preset.threshold ?? 0)
        data[14] = UInt8(truncatingIfNeeded: preset.sag ?? 0)
        data[15] = UInt8(truncatingIfNeeded: preset.brightness ?? 0)
        data[16] = UInt8(truncatingIfNeeded: preset.cabinet ?? 0)
        data[17] = UInt8(truncatingIfNeeded: preset.model ?? 0)
        data[18] = UInt8(name.count)
        for i in 0 ..< name.count {
            data[19+i] = name[i]
        }
        data[19+name.count] = 0x00
        if let effects = preset.effects {
            data[19+name.count] = UInt8(effects.count)
            var index: Int = 0
            effects.forEach { effect in
                let effectPosition = 20+name.count+(index * 11)
                data[effectPosition] = UInt8(effect.slot)
                data[effectPosition+1] = effect.type == .stomp ? 0x06 : effect.type == .modulation ? 0x07 : effect.type == .delay ? 0x08 : effect.type == .reverb ? 0x09 : 0x00
                data[effectPosition+2] = UInt8((effect.module & 0xff00) >> 8)
                data[effectPosition+3] = UInt8(effect.module & 0x00ff)
                data[effectPosition+4] = effect.enabled ? 0x01 : 0x00
                data[effectPosition+5] = effect.knobs.count > 0 ? UInt8(truncatingIfNeeded: Int((effect.knobs[0].value) * 255)) : 0x00
                data[effectPosition+6] = effect.knobs.count > 1 ? UInt8(truncatingIfNeeded: Int((effect.knobs[1].value) * 255)) : 0x00
                data[effectPosition+7] = effect.knobs.count > 2 ? UInt8(truncatingIfNeeded: Int((effect.knobs[2].value) * 255)) : 0x00
                data[effectPosition+8] = effect.knobs.count > 3 ? UInt8(truncatingIfNeeded: Int((effect.knobs[3].value) * 255)) : 0x00
                data[effectPosition+9] = effect.knobs.count > 4 ? UInt8(truncatingIfNeeded: Int((effect.knobs[4].value) * 255)) : 0x00
                data[effectPosition+10] = effect.knobs.count > 5 ? UInt8(truncatingIfNeeded: Int((effect.knobs[5].value) * 255)) : 0x00
                index += 1
            }
        }
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID, value: data, forAmplifier: amplifier)
    }
    
    internal func amplifierConfirmSetPreset(_ amplifier: Amplifier) {
        var data = Data(repeating: 0, count: 1)
        data[0] = 0x02  // Confirm the settings
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID, value: data, forAmplifier: amplifier)
    }
    
    internal func amplifier(_ amplifier: Amplifier, savePreset slot: UInt8, name: String) {
        let name = Data(name.utf8)
        var data = Data(repeating: 0, count: 3 + name.count)
        data[0] = 0x03  // Save the preset in the supplied slot
        data[1] = UInt8(truncatingIfNeeded: slot)
        data[2] = UInt8(name.count)
        for i in 0 ..< name.count {
            data[2+i] = name[i]
        }
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID, value: data, forAmplifier: amplifier)
    }
    
    internal func amplifierConfirmSavePreset(_ amplifier: Amplifier) {
        var data = Data(repeating: 0, count: 1)
        data[0] = 0x04  // Confirm the save
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID, value: data, forAmplifier: amplifier)
    }
    
    private func onAmplifierCharacteristicDiscovered(_ characteristic: CBCharacteristic) {
        var preset = Preset()
        switch characteristic.uuid {
        case self.AMPLIFIER_NAME_CHRC_UUID:
            if let value = characteristic.value {
                let name = String(data: value, encoding: .utf8) ?? "Not known"
                ULog.debug("Amplifier name: %@", name)
                NotificationCenter.default.post(name: .amplifierNameDiscovered, object: name)
            }
            
        case self.AMPLIFIER_PRESET_COUNT_CHRC_UUID:
            if let value = characteristic.value {
                let count = Int(value[0])
                ULog.debug("Preset count is %d", count)
                NotificationCenter.default.post(name: .presetCountDiscovered, object: count)
            }
            
        case self.AMPLIFIER_PRESET_CHRC_UUID:
            if let value = characteristic.value {
                switch value[0] {
                case 0x00:
                    preset.slot = Int(value[1])
                    preset.volume = Float(value[2]) / 255.0
                    preset.masterVolume = Float(value[3]) / 255.0
                    preset.gain1 = Float(value[4]) / 255.0
                    preset.gain2 = Float(value[5]) / 255.0
                    preset.treble = Float(value[6]) / 255.0
                    preset.middle = Float(value[7]) / 255.0
                    preset.bass = Float(value[8]) / 255.0
                    preset.presence = Float(value[9]) / 255.0
                    preset.depth = Int(value[10])
                    preset.bias = Int(value[11])
                    preset.noiseGate = Int(value[12])
                    preset.threshold = Int(value[13])
                    preset.sag = Int(value[14])
                    preset.brightness = Int(value[15])
                    preset.cabinet = Int(value[16])
                    preset.cabinetName = preset.cabinetName(preset.cabinet)
                    preset.model = Int(value[17])
                    preset.modelName = preset.modelName(preset.model)
                    let nameLength = Int(value[18])
                    preset.name = String(data: value[19..<19+nameLength], encoding: .utf8)
                    let effectCount = Int(value[19 + nameLength])
                    let effects = 20 + nameLength
                    preset.effects = [Effect]()
                    for index in 0 ..< effectCount {
                        let effectPosition = effects + (index * 11)
                        let module = (UInt16(value[effectPosition+2])<<8) | UInt16(value[effectPosition+3])
                        var knobs = [Knob]()
                        knobs.append(Knob(value: Float(value[effectPosition+5]) / 255.0))
                        knobs.append(Knob(value: Float(value[effectPosition+6]) / 255.0))
                        knobs.append(Knob(value: Float(value[effectPosition+7]) / 255.0))
                        knobs.append(Knob(value: Float(value[effectPosition+8]) / 255.0))
                        knobs.append(Knob(value: Float(value[effectPosition+9]) / 255.0))
                        knobs.append(Knob(value: Float(value[effectPosition+10]) / 255.0))
                        let effect = Effect(slot: Int(value[effectPosition]), type: value[effectPosition+1], module: module, enabled: value[effectPosition+4] == 0x01, knobs: knobs)
                        preset.effects?.append(effect)
                    }
                    NotificationCenter.default.post(name: .presetDiscovered, object: preset)
                case 0x01:
                    NotificationCenter.default.post(name: .presetSet, object: nil)
                case 0x02:
                    NotificationCenter.default.post(name: .presetSetConfirmed, object: nil)
                case 0x03:
                    NotificationCenter.default.post(name: .presetSaved, object: nil)
                default:
                    ULog.error("Unexpected command code 0x%02x in preset characteristic", value[0])
                }
            }
    
        case self.AMPLIFIER_CONTROL_CHRC_UUID:
            if let value = characteristic.value {
                ULog.debug("Control change %d %d %d %d %d %d %d %d %d", Int(value[0]), Int(value[1]), Int(value[2]), Int(value[3]), Int(value[4]), Int(value[5]), Int(value[6]), Int(value[7]), Int(value[8]))
                let floatValue = (Float(value[8]) / 256.0)
                switch value[3] {
                case 0x00:
                    switch value[5] {
                    case 0x0c:
                        ULog.debug("Volume %.2f", floatValue)
                        NotificationCenter.default.post(name: .volumeChanged, object: floatValue)
                    case 0x01:
                        ULog.debug("Reverb %.2f", floatValue)
                        NotificationCenter.default.post(name: .reverbChanged, object: floatValue)
                    default: break
                    }
                case 0x01:
                    ULog.debug("Gain %.2f", floatValue)
                    NotificationCenter.default.post(name: .gainChanged, object: floatValue)
                case 0x04:
                    ULog.debug("Treble %.2f", floatValue)
                    NotificationCenter.default.post(name: .trebleChanged, object: floatValue)
                case 0x05:
                    ULog.debug("Middle %.2f", floatValue)
                    NotificationCenter.default.post(name: .middleChanged, object: floatValue)
                case 0x06:
                    ULog.debug("Bass %.2f", floatValue)
                    NotificationCenter.default.post(name: .bassChanged, object: floatValue)
                default: break
                }

            }
            
        default:
                ULog.error("Unexpected characteristic %@", characteristic.uuid.uuidString)
        }
    }
    
    open func getCharacteristics(_ uuids: [CBUUID], forAmplifier amplifier: Amplifier) {
        guard let services = amplifier.peripheral.services else { return }
        services.forEach { (service) in
            for characteristic in service.characteristics ?? [] {
                if uuids.contains(characteristic.uuid) {
                    amplifier.peripheral.readValue(for: characteristic)
                    return
                }
            }
        }
    }
    
    open func setCharacteristic(_ uuid: CBUUID, value: Data, forAmplifier amplifier: Amplifier) {
        guard let services = amplifier.peripheral.services else { return }
        services.forEach { (service) in
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == uuid {
                    amplifier.peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
                    return
                }
            }
        }
    }
    
    internal func disconnect(_ amplifier: Amplifier, _ onDisconnect: @escaping (Amplifier) -> Void) {
        self.onAmplifierDisconnected = onDisconnect
        centralManager.cancelPeripheralConnection(amplifier.peripheral)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            NotificationCenter.default.post(name: .readyToScan, object: true)
        case .poweredOff:
            NotificationCenter.default.post(name: .readyToScan, object: false)
            central.stopScan()
        case .unsupported: fatalError("Unsupported BLE module")
        default: break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.onAmplifierDiscovered?(peripheral.asAmplifier(advertisementData: advertisementData, rssi: RSSI.intValue))
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        if self.serviceDiscoveryInProgress { return }
        if peripheral.services != nil {
            self.peripheral(peripheral, didDiscoverServices: nil) //already discovered services before, DO NOT do it again
        } else {
            serviceDiscoveryInProgress = true
            peripheral.discoverServices([AMPLIFIER_SERVICE_UUID])
        }
        onAmplifierConnected?(peripheral.asAmplifier())
    }
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        onAmplifierDisconnected?(peripheral.asAmplifier())
    }
    
    // MARK: - CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverServices error: %@", error?.localizedDescription ?? "Unknown")
            return
        }
        ULog.verbose("Peripheral has %d services", peripheral.services?.count ?? -1)
        onAmplifierServicesDiscovered?(peripheral.asAmplifier())
        guard let services = peripheral.services else { return }
        services.forEach { (service) in
            if service.characteristics != nil {
                self.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil) //already discovered characteristics before, DO NOT do it again
            } else {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverCharacteristicsFor service %@. error: %@", service.uuid.uuidString, error?.localizedDescription ?? "Unknown")
            return
        }
        ULog.verbose("Service %@ has %d characteristics", service.uuid, service.characteristics?.count ?? -1)
        service.characteristics?.forEach { ( characteristic) in
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
        onAmplifierCharacteristicsDiscovered?(peripheral.asAmplifier()) // Note this will happen before the readValue calls have completed
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverDescriptorsFor service %@. error: %@", characteristic.uuid.uuidString, error?.localizedDescription ?? "Unknown")
            return
        }
        ULog.verbose("Characteristic %@ has %d descriptors", characteristic.uuid, characteristic.descriptors?.count ?? -1)
        characteristic.descriptors?.forEach { descriptor in
            peripheral.readValue(for: descriptor)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            ULog.error("peripheral didUpdateValueFor characteristic %@. error: %@", characteristic.uuid.uuidString, error?.localizedDescription ?? "Unknown")
            return
        }
        if let value = characteristic.value {
            if value.count == 0 {
                ULog.verbose("Characteristic value: []")
            } else {
                ULog.verbose("Characteristic value: 0x%@", value.map { String(format: "%02x", $0) }.joined())
            }
        } else {
            ULog.verbose("Characteristic value: nil")
        }
        onAmplifierCharacteristicDiscovered(characteristic)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil {
            ULog.error("peripheral didUpdateValueFor descriptor %@. error: %@", descriptor.uuid.uuidString, error?.localizedDescription ?? "Unknown")
            return
        }
        if let value = descriptor.value {
            if value is String {
                ULog.debug("Descriptor: %@", value as! String)
            } else if value is Data {
                ULog.debug("Descriptor: 0x%@", (value as! Data).map { String(format: "%02x", $0) }.joined())
            } else {
                ULog.debug("Descriptor: %@", String(describing: value))
            }
        } else {
            ULog.debug("Descriptor: nil")
        }
        guard let descriptors = descriptor.characteristic.descriptors else { return }
        for desc in descriptors {
            if desc.value == nil { return }
        }
        let char_value: String
        if let value = descriptor.characteristic.value {
            if value.count == 0 {
                char_value = "[]"
            } else {
                char_value = String(format: "0x%@", value.map { String(format: "%02x", $0) }.joined())
            }
        } else {
            char_value = "nil"
        }
        let descs: String = descriptors.map { desc in
            if let value = desc.value {
                if value is String {
                    return value as! String
                } else if value is Data {
                    return String(format: "0x%@", (value as! Data).map { String(format: "%02x", $0) }.joined())
                } else {
                    return String(describing: value)
                }
            } else {
                return "nil"
            }
        }.joined(separator: ". ")
        ULog.debug("%@ - %@: %@", descriptor.characteristic.uuid, descs, char_value)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            ULog.error("peripheral didUpdateNotificationStateFor characteristic %@: error: %@", characteristic.uuid.uuidString, error?.localizedDescription ?? "Unknown")
            return
        }
        ULog.verbose("Characteristic %@ %@ notify", characteristic.uuid, characteristic.isNotifying ? "will" : "will not")
    }
}
