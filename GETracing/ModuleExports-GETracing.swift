//
//  ModuleExports-GETracing.swift
//  GETracing
//
//  Created by Grigory Entin on 09.12.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import GETracing
import Foundation

internal var moduleTracingEnabled: Bool = {
	let bundle = Bundle(for: #dsohandle)!
	let valueInInfoPlist = (bundle.object(forInfoDictionaryKey: "GEModuleTracingEnabled") as! NSNumber?)?.boolValue ?? true
	return valueInInfoPlist
}()

@discardableResult
internal func x$<T>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, dso: UnsafeRawPointer = #dsohandle, _ valueClosure: @autoclosure () throws -> T) rethrows -> T
{
	guard moduleTracingEnabled else {
		return try valueClosure()
	}
	return try GETracing.x$(file: file, line: line, column: column, function: function, dso: dso, valueClosure)
}

internal prefix func •<T>(argument: @autoclosure () -> T) {
	// swiftlint:disable:previous identifier_name
}

internal func L<T>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, dso: UnsafeRawPointer = #dsohandle, _ valueClosure: @autoclosure () -> T) -> String {
	// swiftlint:disable:previous identifier_name
	return GETracing.L(file: file, line: line, column: column, function: function, dso: dso, valueClosure)
}

internal func disableTrace(file: String = #file, function: String = #function) -> Any? {
	return GETracing.disableTrace(file: file, function: function)
}
