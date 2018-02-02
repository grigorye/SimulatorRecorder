//
//  NSLogRedirector.swift
//  GEFoundation
//
//  Created by Grigory Entin on 14.01.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import func GETracing.logWithNoSourceOrLabel
import Foundation

// https://support.apple.com/kb/TA45403?locale=en_US&viewlocale=en_US

#if DEBUG
typealias LogCStringF = @convention(c) (_ message: UnsafeMutableRawPointer, _ length: CUnsignedInt, _ banner: CBool) -> Void

@available(iOS 9.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
@_silgen_name("_NSSetLogCStringFunction") private func NSSetLogCStringFunction(_: LogCStringF)

let logCString: LogCStringF = { messageBytes, length, banner in
	let message = String(bytesNoCopy: messageBytes, length: Int(length), encoding: .utf8, freeWhenDone: false)!
	logWithNoSourceOrLabel(message)
}

public let nslogRedirectorInitializer: Void = {
	NSSetLogCStringFunction(logCString)
}()
#endif
