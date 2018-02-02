//
//  TracingTests.swift
//  GEBase
//
//  Created by Grigory Entin on 22/11/15.
//  Copyright © 2015 Grigory Entin. All rights reserved.
//

@testable import GETracing
import XCTest

#if !swift(>=4.1)
extension Array {
func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
return try flatMap(transform)
}
}
#endif

class TraceAndLabelTestsBase: XCTestCase {
	let foo = "bar"
	let bar = "baz"
	var blocksForTearDown = [() -> Void]()
	// MARK:-
	override func setUp() {
		super.setUp()
		let sourceLabelsEnabledEnforcedOldValue = sourceLabelsEnabledEnforced
		blocksForTearDown += [{
			sourceLabelsEnabledEnforced = sourceLabelsEnabledEnforcedOldValue
		}]
		let traceEnabledEnforcedOldValue = traceEnabledEnforced
		blocksForTearDown += [{
			traceEnabledEnforced = traceEnabledEnforcedOldValue
		}]
	}
	override func tearDown() {
		blocksForTearDown.forEach {$0()}
		blocksForTearDown = []
		super.tearDown()
	}
}

class TraceTests : TraceAndLabelTestsBase {
	var tracedRecords = [LogRecord]()
	override func setUp() {
		super.setUp()
		let oldLoggers = loggers
		loggers.append({ record in
			self.tracedRecords += [record]
		})
		blocksForTearDown += [{
			loggers = oldLoggers
		}]
	}
	// MARK: -
	func testTraceWithAllThingsDisabled() {
		var evaluated = false
		x$({evaluated = true}())
		XCTAssertTrue(tracedRecords.isEmpty)
		XCTAssertTrue(evaluated)
	}
	func testNotraceWithAllThingsDisabled() {
		var evaluated = false
		•({evaluated = true}())
		XCTAssertTrue(tracedRecords.isEmpty)
		XCTAssertFalse(evaluated)
	}
	func testWithTraceEnabled() {
		traceEnabledEnforced = true
		let column =   #column
		let value = x$(foo); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, foo)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, [".\(column)"])
	}
	func testNestedWithTraceEnabled() {
		traceEnabledEnforced = true
		let column =   #column
		let column_2 =    #column
		let value = x$(x$(foo)); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, foo)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line, line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL, fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar", "bar"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, [".\(column_2)", ".\(column)"])
	}
	func testComplexNestedWithTraceEnabled() {
		traceEnabledEnforced = true
		let innerColumn =         #column
		let column =                   #column
		let value = x$("xxx" + x$(foo) + "baz"); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, "xxx" + foo + "baz")
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line, line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL, fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, [foo, "xxx" + foo + "baz"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, [".\(innerColumn)", ".\(column)"])
	}
	func testComplexWithTraceEnabled() {
		traceEnabledEnforced = true
		let column =               #column
		let value = x$("xxx" + foo + "baz"); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, "xxx" + foo + "baz")
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["xxx" + foo + "baz"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, [".\(column)"])
	}
	func testWithTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		x$(foo); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["foo"])
	}
	func testNestedWithTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let value = x$(x$(foo) + "baz"); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, foo + "baz")
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line, line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL, fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar", "barbaz"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["foo", "x$(foo) + \"baz\""])
	}
	func testComplexWithTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let value = x$("xxx" + (foo) + "baz"); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, "xxx" + (foo) + "baz")
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["xxx" + foo + "baz"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["\"xxx\" + (foo) + \"baz\""])
	}
	func testComplexWithAutoclosuresTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let value = z$("xxx" + (foo) + "baz"); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, "xxx" + (foo) + "baz")
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["xxx" + foo + "baz"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["\"xxx\" + (foo) + \"baz\""])
	}
	func testZeroWithTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let value = x$(0); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, 0)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["0"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["0"])
	}
	func testZeroWithAutoclosureTraceAndLabelsEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let value = z$(0); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(value, 0)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["0"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["0"])
	}
	func testWithTraceAndLabelsEnabledAndDumpInTraceEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		dumpInTraceEnabledEnforced = true; defer { dumpInTraceEnabledEnforced = nil }
		x$(foo); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["- \"bar\"\n"])
		XCTAssertEqual(tracedRecords.compactMap {$0.label}, ["foo"])
	}
	func testWithTraceLockAndTracingEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let dt = disableTrace(); defer { _ = dt }
		x$(foo)
		XCTAssertTrue(tracedRecords.isEmpty)
	}
	func testWithTraceLockAndTracingDisabled() {
		let dt = disableTrace(); defer { _ = dt }
		x$(foo)
		XCTAssertTrue(tracedRecords.isEmpty)
	}
	func testWithTraceUnlockAndTracingEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let dt = disableTrace(); defer { _ = dt }
		x$(bar)
		let et = enableTrace(); defer { _ = et }
		x$(foo); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["foo"])
	}
	func testWithTraceUnlockWithoutLockAndTracingEnabled() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let et = enableTrace(); defer { _ = et }
		x$(foo); let line = #line
		let fileURL = URL(fileURLWithPath: #file)
		XCTAssertEqual(tracedRecords.map {$0.location.line}, [line])
		XCTAssertEqual(tracedRecords.map {$0.location.fileURL}, [fileURL])
		XCTAssertEqual(tracedRecords.map {$0.message}, ["bar"])
		XCTAssertEqual(tracedRecords.map {$0.label!}, ["foo"])
	}
	func testWithTraceUnlockAndTracingDisabled() {
		let dt = disableTrace(); defer { _ = dt }
		x$(bar)
		let et = enableTrace(); defer { _ = et }
		x$(foo)
		XCTAssertTrue(tracedRecords.isEmpty)
	}
	func testWithDisabledFile() {
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		let oldFilesWithTracingDisabled = filesWithTracingDisabled
		defer { filesWithTracingDisabled = oldFilesWithTracingDisabled }
		filesWithTracingDisabled += [
			URL(fileURLWithPath: #file).lastPathComponent
		]
		x$(foo)
		XCTAssertTrue(tracedRecords.isEmpty)
	}
}

class LabelTests : TraceAndLabelTestsBase {
	override func setUp() {
		super.setUp()
		let oldSourceLabelsEnabledEnforced = sourceLabelsEnabledEnforced
		sourceLabelsEnabledEnforced = true
		blocksForTearDown += [{
			sourceLabelsEnabledEnforced = oldSourceLabelsEnabledEnforced
		}]
	}
	// MARK: -
	func testLabeledString() {
		let foo = "bar"
		XCTAssertEqual(L(foo), "foo: bar")
		sourceLabelsEnabledEnforced = false
		let cln = #column
		let l = L(foo)
		XCTAssertEqual(l, ".\(cln): bar")
	}
	func testNestedLabeledString() {
		let foo = "bar"
		XCTAssertEqual(L(L(foo)), "L(foo): foo: bar")
		sourceLabelsEnabledEnforced = false
		let cln = #column
		let cln_2 = #column
		let l = L(L(foo))
		XCTAssertEqual(l, ".\(cln): .\(cln_2): bar")
	}
	func testLabelWithMissingSource() {
		let s = "foo"
		let sourceFile = "/tmp/Missing.swift"
		let sourceFilename = URL(fileURLWithPath: sourceFile).lastPathComponent
		let cls = type(of: self)
		let bundleFilename = Bundle(for: cls).bundleURL.lastPathComponent
		let cln = #column - 1
		let l = L(file: sourceFile, s)
		XCTAssertEqual(l, "\(bundleFilename)/\(sourceFilename)[missing]:.\(cln):?: foo")
	}
	func testLabelWithNoSource() {
		let s = "foo"
		var v = "foo"
		let sourceFilename = URL(fileURLWithPath: #file).lastPathComponent
		withUnsafePointer(to: &v) { p in
			let l = L(dso: p, s)
			XCTAssertEqual(l, "\(sourceFilename):?: foo")
		}
	}
	func testLabeledCompoundExpressions() {
		let foo = "bar"
		let optionalFoo = Optional("bar")
		XCTAssertEqual(L("baz" + String(foo.reversed())), "\"baz\" + String(foo.reversed()): bazrab")
		XCTAssertEqual(L(String(foo.reversed())), "String(foo.reversed()): rab")
		XCTAssertEqual(L(optionalFoo!), "optionalFoo!: bar")
		let fileManager = FileManager.default
		let storePath = "/tmp/xxx"
		XCTAssertEqual(L(fileManager.fileExists(atPath: storePath)), "fileManager.fileExists(atPath: storePath): false")
	}
}
