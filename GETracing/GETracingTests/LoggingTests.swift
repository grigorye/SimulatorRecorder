//
//  LoggingTests.swift
//  GETracingTests
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

@testable import GETracing
import XCTest

class LoggingTests : TraceAndLabelTestsBase {
	
	func testTraceWithNoLoggers() {
		
		traceEnabledEnforced = true
		
		x$(0)
	}
	
	func testLogWithNoSourceOrLabel() {
		
		logWithNoSourceOrLabel("foo")
	}
}
