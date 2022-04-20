//
//  ULog.swift
//  Readuino
//
//  Created by Derek Knight on 20/11/19.
//  Copyright © 2019 Derek Knight. All rights reserved.
//

import Foundation
import os.log
#if os(iOS)
    #if USE_FLOGGER
        import Flogger
    #endif
#endif

private let subsystem = Bundle.main.bundleIdentifier!
private let category = "uLogger"
private let stringFormat: StaticString = "%{public}@"

internal class ULog {
    static var _verboseLogging = false
    
    static func setup() {
    }
    
    static func verboseLogging() {
        _verboseLogging = true
    }

    static func debug(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .debug, s)
    }

    static func error(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .error, s)
    }

    static func info(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .info, s)
    }

    static func verbose(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        if _verboseLogging {
            os_log(stringFormat, log: .uLogger, type: .debug, s)
        }
    }
}

extension OSLog {
    static let uLogger = OSLog(subsystem: subsystem, category: category)
}
