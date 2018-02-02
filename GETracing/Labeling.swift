//
//  Labeling.swift
//  GETracing
//
//  Created by Grigory Entin on 24.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

func descriptionImp<T>(of value: T) -> String {
	if dumpInTraceEnabled {
		var s = ""
		dump(value, to: &s)
		return s
	}
	return description(of: value)
}

public func description<T>(of value: T) -> String {
	return "\(value)"
}

public func L<T>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, dso: UnsafeRawPointer = #dsohandle, _ valueClosure: @autoclosure () -> T) -> String {
	// swiftlint:disable:previous identifier_name
	let value = valueClosure()
	let location = SourceLocation(file: file, line: line, column: column, function: function, moduleReference: .dso(dso))
	let sourceExtractedInfo = GETracing.sourceExtractedInfo(for: location, traceFunctionName: "L")
	let labeled = "\(sourceExtractedInfo.label): \(descriptionImp(of: value))"
	return labeled
}

var dumpInTraceEnabledEnforced: Bool?
private var dumpInTraceEnabled: Bool {
	return dumpInTraceEnabledEnforced ?? UserDefaults.standard.bool(forKey: "dumpInTraceEnabled")
}
