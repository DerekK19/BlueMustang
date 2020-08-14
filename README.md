[![Swift 5.2](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS | macOS](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgray.svg?style=flat)](http://www.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AEXML/blob/master/LICENSE)
# BlueMustang

**BlueMustang is a framework written in Swift that interfaces to a Fender Mustang Amplifier through a Bluetooth bridge application**

## Related

### blue_mustang Bluetooth bridge application
A Bluetooth application can be found on [Github](https://github.com/derekk19/blue_mustang). It is a Python module that can run on a Raspberry Pi. When the Raspberry Pi is connected to a Fender Mustang amplifier though USB, blue_mustang acts as a USB-Bluetooth bridge.

### Defender client application
A macOS/iOS application that uses BlueMustang to control a Fender Mustang amplifier. Because Defender uses BlueMustang, it means the client device (be it a Mac or an iPad/iPhone) does not need to be physically connected to the amplifier. This resolves the major issue with controlling a Fender Mustang amplifier from an iOS device.

> I made this software for personal use, but feel free to use it or contribute. My amplifier is a Fender Mustang III V2 and is connected to a Raspberry Pi Rev 3 running blue_mustang

## Specification
If writing a Bluetooth module from scratch, You should implement a Bluetooth Low Energy (BLE) peripheral with the following UUIDS:

### 1812
The Bluetooth service must advertise itself as a Human Interface Device, and use this UUID
### abc9a576-c710-11ea-87d0-0242ac130000
The Bluetooth service must use this UUID
### abc9a576-c710-11ea-87d0-0242ac130001
This characteristic should return the name of the amplifier
### abc9a576-c710-11ea-87d0-0242ac130002
This characteristic should return the number of presets the amplifier provides (typically this is 100)
### abc9a576-c710-11ea-87d0-0242ac130003
This characteristic should return the names of the presets as follows:  
* When the characteristic is read, it should return as many names as will fit in 100 bytes  
* When the characteristic is written to (passing two single byte integers), this should set up the next read; the first byte will be the number of bytes that may be returned by the read (this should be 100), the second byte will be the number from which preset names should be returned next
### abc9a576-c710-11ea-87d0-0242ac130004
This characteristic is used for reading and writing preset values
### abc9a576-c710-11ea-87d0-0242ac130005
This characteristic is used for reading and setting the amplifier's Volume, Tone etc knobs

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

    ```swift
    .package(url: "https://github.com/derekk19/BlueMustang.git", from: "1.0.0")
    ```

## License
BlueMustang is released under the MIT license. See [LICENSE](LICENSE) for details.
