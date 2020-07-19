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

class BluetoothScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    private let HIDUUID: CBUUID = CBUUID(string: "1812")
    private let AMPLIFIER_SERVICE_UUID: CBUUID            = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130000")
    private let AMPLIFIER_NAME_CHRC_UUID: CBUUID          = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130001")
    private let AMPLIFIER_PRESET_COUNT_CHRC_UUID: CBUUID  = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130002")
    private let AMPLIFIER_PRESET_CHRC_UUID: CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130003")
    private let AMPLIFIER_PRESET_NAME_CHRC_UUID : CBUUID  = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130004")
    private let AMPLIFIER_VOLUME_CHRC_UUID: CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130005")
    private let AMPLIFIER_MASTER_VOLUME_CHRC_UUID: CBUUID = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130006")
    private let AMPLIFIER_GAIN1_CHRC_UUID : CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130007")
    private let AMPLIFIER_GAIN2_CHRC_UUID: CBUUID         = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130008")
    private let AMPLIFIER_TREBLE_CHRC_UUID: CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130009")
    private let AMPLIFIER_MIDDLE_CHRC_UUID: CBUUID        = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000a")
    private let AMPLIFIER_BASS_CHRC_UUID: CBUUID          = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000b")
    private let AMPLIFIER_PRESENCE_CHRC_UUID: CBUUID      = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000c")
    private let AMPLIFIER_DEPTH_CHRC_UUID: CBUUID         = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000d")
    private let AMPLIFIER_BIAS_CHRC_UUID: CBUUID          = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000e")
    private let AMPLIFIER_NOISE_GATE_CHRC_UUID: CBUUID    = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac13000f")
    private let AMPLIFIER_THRESHOLD_CHRC_UUID: CBUUID     = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130010")
    private let AMPLIFIER_SAG_CHRC_UUID: CBUUID           = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130011")
    private let AMPLIFIER_BRIGHTNESS_CHRC_UUID: CBUUID    = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130012")
    private let AMPLIFIER_CABINET_CHRC_UUID: CBUUID       = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130013")
    private let AMPLIFIER_MODEL_CHRC_UUID: CBUUID         = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130014")
    
    private var centralManager: CBCentralManager!
    private var serviceDiscoveryInProgress = false

    private var onScannerReady: ((BluetoothScanner) -> Void)?
    private var onAmplifierDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierServicesDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierCharacteristicsDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierCharacteristicDiscovered: ((CBCharacteristic) -> Void)?
    private var onAmplifierConnected: ((Amplifier) -> Void)?
    private var onAmplifierDisconnected: ((Amplifier) -> Void)?

    public init(onScannerReady: @escaping (BluetoothScanner) -> Void) {
        self.onScannerReady = onScannerReady
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
    
    internal func amplifier(_ amplifier: Amplifier, getPreset slot: UInt8, _ didGetPreset: @escaping (Preset) -> Void) {
        var data = Data(repeating: 0, count: 1)
        data[0] = slot
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID,
                          value: data,
                          forAmplifier: amplifier) {
                            self.getCharacteristics([self.AMPLIFIER_PRESET_CHRC_UUID],
                                                    forAmplifier: amplifier) { preset in
                                                        didGetPreset(preset)
                            }
        }
    }
    
    internal func amplifier(_ amplifier: Amplifier, setPreset slot: UInt8, _ didSetPreset: @escaping (Preset) -> Void) {
        var data = Data(repeating: 0, count: 1)
        data[0] = slot
        setCharacteristic(AMPLIFIER_PRESET_CHRC_UUID,
                          value: data,
                          forAmplifier: amplifier) {
                           self.getCharacteristics([self.AMPLIFIER_PRESET_CHRC_UUID],
                                                   forAmplifier: amplifier) { preset in
                                                       didSetPreset(preset)
                           }
        }
    }
    
    open func getCharacteristics(_ uuids: [CBUUID], forAmplifier amplifier: Amplifier, _ onDiscover: @escaping (Preset) -> Void) {
        onAmplifierCharacteristicDiscovered = { characteristic in
            var preset = Preset()
            switch characteristic.uuid {
            case self.AMPLIFIER_PRESET_CHRC_UUID:
                if let value = characteristic.value {
                    preset.slot = Int(value[0])
                    preset.volume = Float(value[1]) / 255.0
                    preset.masterVolume = Float(value[2]) / 255.0
                    preset.gain1 = Float(value[3]) / 255.0
                    preset.gain2 = Float(value[4]) / 255.0
                    preset.treble = Float(value[5]) / 255.0
                    preset.middle = Float(value[6]) / 255.0
                    preset.bass = Float(value[7]) / 255.0
                    preset.presence = Float(value[8]) / 255.0
                    preset.depth = Int(value[9])
                    preset.bias = Int(value[10])
                    preset.noiseGate = Int(value[11])
                    preset.threshold = Int(value[12])
                    preset.sag = Int(value[13])
                    preset.brightness = Int(value[14])
                    preset.cabinet = Int(value[15])
                    preset.cabinetName = preset.cabinetName(preset.cabinet)
                    preset.model = Int(value[16])
                    preset.modelName = preset.modelName(preset.model)
                    preset.name = String(data: value.advanced(by: 17), encoding: .utf8)
                }
                break
            case self.AMPLIFIER_PRESET_NAME_CHRC_UUID:
                break // preset.name = String(data: characteristic.value, encoding: .utf8)
            case self.AMPLIFIER_VOLUME_CHRC_UUID:
                break
            case self.AMPLIFIER_MASTER_VOLUME_CHRC_UUID:
                break
            case self.AMPLIFIER_GAIN1_CHRC_UUID:
                break
            case self.AMPLIFIER_GAIN2_CHRC_UUID:
                break
            case self.AMPLIFIER_TREBLE_CHRC_UUID:
                break
            case self.AMPLIFIER_MIDDLE_CHRC_UUID:
                break
            case self.AMPLIFIER_BASS_CHRC_UUID:
                break
            case self.AMPLIFIER_PRESENCE_CHRC_UUID:
                break
            case self.AMPLIFIER_DEPTH_CHRC_UUID:
                break
            case self.AMPLIFIER_BIAS_CHRC_UUID:
                break
            case self.AMPLIFIER_NOISE_GATE_CHRC_UUID:
                break
            case self.AMPLIFIER_THRESHOLD_CHRC_UUID:
                break
            case self.AMPLIFIER_SAG_CHRC_UUID:
                break
            case self.AMPLIFIER_BRIGHTNESS_CHRC_UUID:
                break
            case self.AMPLIFIER_CABINET_CHRC_UUID:
                break
            case self.AMPLIFIER_MODEL_CHRC_UUID:
                break
            default:
                    ULog.error("Unexpected characteristic %@", characteristic.uuid.uuidString)
            }
            onDiscover(preset)
        }
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
    
    open func setCharacteristic(_ uuid: CBUUID, value: Data, forAmplifier amplifier: Amplifier, _ onComplete: @escaping () -> Void) {
        guard let services = amplifier.peripheral.services else { return }
        services.forEach { (service) in
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == uuid {
                    amplifier.peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
                    onComplete()
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
            onScannerReady?(self)
            onScannerReady = nil
        case .poweredOff:
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
            ULog.error("peripheral didDiscoverCharacteristicsFor service error: %@", service, error?.localizedDescription ?? "Unknown")
        }
        ULog.verbose("Service %@ has %d characteristics", service.uuid, service.characteristics?.count ?? -1)
        service.characteristics?.forEach { ( characteristic) in
            peripheral.readValue(for: characteristic)
        }
        onAmplifierCharacteristicsDiscovered?(peripheral.asAmplifier())
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverDescriptorsFor service %@ error: %@", characteristic, error?.localizedDescription ?? "Unknown")
        }
        ULog.verbose("Characteristic %@ has %d descriptors", characteristic.uuid, characteristic.descriptors?.count ?? -1)
        characteristic.descriptors?.forEach { descriptor in
            peripheral.readValue(for: descriptor)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            if value.count == 0 {
                ULog.verbose("Characteristic value: []")
            } else {
                ULog.verbose("Characteristic value: 0x%@", value.map { String(format: "%02x", $0) }.joined())
            }
        } else {
            ULog.verbose("Characteristic value: nil")
        }
        onAmplifierCharacteristicDiscovered?(characteristic)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
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
}
