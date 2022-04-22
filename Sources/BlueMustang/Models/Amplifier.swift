//
//  Amplifier.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation
import CoreBluetooth

public class Amplifier : NSObject {
    
    public var vendor: Int?
    public var product: Int?
    public var name: String?
    public var manufacturer: String?
    public var presets: [Preset]?
    internal var peripheral: CBPeripheral
    public let advertisedName: String?
    public let rssi: String?
    public var state: String { return peripheral.state.stringRepresentation }
    public var uuid: String { return peripheral.identifier.uuidString }

    public override var debugDescription: String {
        return String(format: "Amplifier. Name: %@, rssi: %@, state: %@", advertisedName ?? "Unknown", rssi ?? "Unknown", state )
    }

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.advertisedName = peripheral.name
        self.rssi = nil
        super.init()
        peripheral.delegate = self
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: Int) {
        self.peripheral = peripheral
        self.advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name
        self.peripheral = peripheral
        self.rssi = String(format: "%d", rssi)
        super.init()
        peripheral.delegate = self
    }
    
}

extension Amplifier : CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        ULog.verbose("Peripheral didModifyServices %d", invalidatedServices.count)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        ULog.verbose("Peripheral didOpen")
    }
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        ULog.verbose("peripheralDidUpdateName")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        ULog.verbose("Peripheral didDiscoverServices")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        ULog.verbose("Peripheral didDiscoverDescriptorsFor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        ULog.verbose("Peripheral didReadRSSI")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        ULog.verbose("Peripheral didDiscoverCharacteristicsFor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        ULog.verbose("Peripheral didDiscoverIncludedServicesFor")
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        ULog.verbose("Peripheral didWriteValueFor")
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        ULog.verbose("Peripheral didWriteValueFor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        ULog.verbose("Peripheral didUpdateValueFor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        ULog.verbose("Peripheral didWriteValueFor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        ULog.verbose("Peripheral didUpdateValueFor")
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        ULog.verbose("peripheralIsReady toSendWriteWithoutResponse")
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        ULog.verbose("peripheralDidUpdateRSSI")
    }
    
}
