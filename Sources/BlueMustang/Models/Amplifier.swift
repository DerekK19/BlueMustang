//
//  File.swift
//  
//
//  Created by Derek Knight on 19/07/20.
//

import Foundation
import CoreBluetooth

public class Amplifier {
    
    var vendor: Int?
    var product: Int?
    var name: String?
    var manufacturer: String?
    var presets: [Preset]?
    internal var peripheral: CBPeripheral
    internal let advertisedName: String?
    internal let rssi: String?
    internal var state: String { return peripheral.state.stringRepresentation }
    internal var uuid: String { return peripheral.identifier.uuidString }

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
