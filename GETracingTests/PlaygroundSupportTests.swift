//
//  PlaygroundSupportTests.swift
//  GETracingTests
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

@testable import GETracing
import XCTest

fileprivate func log(_ record: LogRecord) {
	let text = defaultLoggedTextWithThread(for: record)
	print(text)
}

let playgroundFile = #file

fileprivate func x$<T>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ valueClosure: @autoclosure () -> T ) -> T
{
	let value = valueClosure()
	// Substitute something more humane-readable for #function of top level code of the playground, that is otherwise something like "__lldb_expr_xxx"
	let playgroundAwareFunction = function.hasPrefix("__lldb_expr_") ? "<top-level>" : function
	traceAsNecessary(value, file: playgroundFile, line: line, column: column, function: playgroundAwareFunction, moduleReference: .playground(name: file), traceFunctionName: "x$")
	return value
}

func defaultLoggedTextWithThread(for record: LogRecord) -> String {
	let text = defaultLoggedText(for: record)
	let threadDescription = Thread.isMainThread ? "-" : "\(DispatchQueue.global().label)"
	let textWithThread = "[\(threadDescription)] \(text)"
	return textWithThread
}

func defaultLoggedText(for record: LogRecord) -> String {
	let location = record.location!
	let locationDescription = "\(location.function), \(record.playgroundName ?? location.fileURL.lastPathComponent):\(location.line)"
	guard let label = record.label else {
		return "\(locationDescription) ◾︎ \(record.message)"
	}
	return "\(locationDescription) ◾︎ \(label): \(record.message)"
}

class PlaygroundSupportTests : TraceAndLabelTestsBase {
	
	override func setUp() {
		
		super.setUp()
		
		let oldLoggers = loggers
		loggers.append({ record in
			log(record)
		})
		blocksForTearDown.append({
			loggers = oldLoggers
		})
	}
	
	func testSimple() {
		
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		
		_ = x$(0)
	}
}
