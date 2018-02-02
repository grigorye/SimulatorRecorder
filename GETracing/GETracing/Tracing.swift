//
//  Tracing.swift
//  GEBase
//
//  Created by Grigory Entin on 16/02/16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public func traceAsNecessary<T>(_ value: T, file: String, line: Int, column: Int, function: String, moduleReference: SourceLocation.ModuleReference, traceFunctionName: String) {
	// swiftlint:disable:previous function_parameter_count
#if GE_TRACE_ENABLED
	guard traceEnabled else {
		return
	}
	let location = SourceLocation(file: file, line: line, column: column, function: function, moduleReference: moduleReference)
	guard tracingEnabled(for: location) else {
		return
	}
	log(value, on: Date(), at: location, traceFunctionName: traceFunctionName)
#endif
}

public var traceEnabledEnforced: Bool?

var traceEnabled: Bool {
	return traceEnabledEnforced ?? UserDefaults.standard.bool(forKey: "traceEnabled")
}
