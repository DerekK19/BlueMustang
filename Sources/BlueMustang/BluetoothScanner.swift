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
    
    private let BlueMustangServiceUUUID: CBUUID = CBUUID(string: "abc9a576-c710-11ea-87d0-0242ac130000")
    
    private var centralManager: CBCentralManager!
    private var serviceDiscoveryInProgress = false

    private var onScannerReady: ((BluetoothScanner) -> Void)?
    private var onAmplifierDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierServicesDiscovered: ((Amplifier) -> Void)?
    private var onAmplifierConnected: ((Amplifier) -> Void)?
    private var onAmplifierDisconnected: ((Amplifier) -> Void)?

    public init(onScannerReady: @escaping (BluetoothScanner) -> Void) {
        self.onScannerReady = onScannerReady
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    internal func startScanning(_ onDiscover: @escaping (Amplifier) -> Void) {
        self.onAmplifierDiscovered = onDiscover
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    internal func connect(_ amplifier: Amplifier, onConnect: @escaping (Amplifier) -> Void, onServices: @escaping (Amplifier) -> Void) {
        self.onAmplifierConnected = onConnect
        self.onAmplifierServicesDiscovered = onServices
        serviceDiscoveryInProgress = false
        centralManager.connect(amplifier.peripheral, options: nil)
    }
    
    open func getCharacteristics(_ uuids: [CBUUID], forAmplifier amplifier: Amplifier) {
        guard let services = amplifier.peripheral.services else { return }
        services.forEach { (service) in
            if service.characteristics != nil {
                self.peripheral(amplifier.peripheral, didDiscoverCharacteristicsFor: service, error: nil) //already discovered characteristics before, DO NOT do it again
            } else {
                amplifier.peripheral.discoverCharacteristics(uuids, for: service)
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
        self.onAmplifierDiscovered?(peripheral.asAmplifier())
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        if self.serviceDiscoveryInProgress { return }
        if peripheral.services != nil {
            self.peripheral(peripheral, didDiscoverServices: nil) //already discovered services before, DO NOT do it again
        } else {
            serviceDiscoveryInProgress = true
            peripheral.discoverServices([BlueMustangServiceUUUID])
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
        ULog.debug("Peripheral has %d services", peripheral.services?.count ?? -1)
        onAmplifierServicesDiscovered?(peripheral.asAmplifier())
//        peripheral.services?.forEach { (service) in
//            if service.characteristics != nil {
//                self.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil) //already discovered characteristics before, DO NOT do it again
//            } else {
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
//        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverCharacteristicsFor service error: %@", service, error?.localizedDescription ?? "Unknown")
        }
        ULog.debug("Service %@ has %d characteristics", service.uuid, service.characteristics?.count ?? -1)
        service.characteristics?.forEach { ( characteristic) in
            peripheral.readValue(for: characteristic)
            if characteristic.descriptors != nil {
                self.peripheral(peripheral, didDiscoverDescriptorsFor: characteristic, error: nil)
            } else {
                 peripheral.discoverDescriptors(for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            ULog.error("peripheral didDiscoverDescriptorsFor service %@ error: %@", characteristic, error?.localizedDescription ?? "Unknown")
        }
        ULog.debug("Characteristic %@ has %d descriptors", characteristic.uuid, characteristic.descriptors?.count ?? -1)
        characteristic.descriptors?.forEach { descriptor in
            peripheral.readValue(for: descriptor)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            if value.count == 0 {
                ULog.debug("Characteristic value: []")
            } else {
                ULog.debug("Characteristic value: 0x%@", value.map { String(format: "%02x", $0) }.joined())
            }
        } else {
            ULog.debug("Characteristic value: nil")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let value = descriptor.value {
            if value is String {
                ULog.verbose("Descriptor: %@", value as! String)
            } else if value is Data {
                ULog.verbose("Descriptor: 0x%@", (value as! Data).map { String(format: "%02x", $0) }.joined())
            } else {
                ULog.verbose("Descriptor: %@", String(describing: value))
            }
        } else {
            ULog.verbose("Descriptor: nil")
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

