//
//  File.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation
import CoreBluetooth

public class Amplifier {
    
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

    public var debugDescription: String {
        return String(format: "Amplifier. Name: %@, rssi: %@, state: %@", advertisedName ?? "Unknown", rssi ?? "Unknown", state )
    }

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.advertisedName = nil
        self.rssi = nil
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: Int) {
        self.peripheral = peripheral
        self.advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name
        self.peripheral = peripheral
        self.rssi = String(format: "%d", rssi)
    }
    
}
