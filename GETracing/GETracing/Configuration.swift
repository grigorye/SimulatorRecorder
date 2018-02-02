//
//  Conditionals.swift
//  GETracing
//
//  Created by Grigory Entin on 24.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

/// List of files that might be used for disabling tracing on file basis.
public var filesWithTracingDisabled = [String]()

public func disableTrace(file: String = #file, function: String = #function) -> Any? {
#if !GE_TRACE_ENABLED
	return nil
#else
	guard traceEnabled else {
		return nil
	}
	return TraceLocker(file: file, function: function)
#endif
}

public func enableTrace(file: String = #file, function: String = #function) -> Any? {
#if !GE_TRACE_ENABLED
	return nil
#else
	guard traceEnabled else {
		return nil
	}
	return TraceUnlocker(file: file, function: function)
#endif
}

func tracingEnabled(for location: SourceLocation) -> Bool {
	guard !filesWithTracingDisabled.contains(location.fileURL.lastPathComponent) else {
		return false
	}
	guard 0 == (traceLockCountForFileAndFunction[location.fileAndFunction] ?? 0) else {
		return false
	}
	return true
}

private var traceLockCountForFileAndFunction: [SourceFileAndFunction : Int] = [:]

private class TraceLocker {

	let sourceFileAndFunction: SourceFileAndFunction
	
	init(file: String = #file, function: String = #function) {
		self.sourceFileAndFunction = SourceFileAndFunction(fileURL: URL(fileURLWithPath: file), function: function)
		let oldValue = traceLockCountForFileAndFunction[self.sourceFileAndFunction] ?? 0
		traceLockCountForFileAndFunction[self.sourceFileAndFunction] = oldValue + 1
	}
	
	deinit {
		let oldValue = traceLockCountForFileAndFunction[self.sourceFileAndFunction]!
		traceLockCountForFileAndFunction[self.sourceFileAndFunction] = oldValue - 1
	}
	
}

private class TraceUnlocker {

	let sourceFileAndFunction: SourceFileAndFunction
	
	let unlockingWithNoLock: Bool
	
	init(file: String = #file, function: String = #function) {
		self.sourceFileAndFunction = SourceFileAndFunction(fileURL: URL(fileURLWithPath: file), function: function)
		let oldValue = traceLockCountForFileAndFunction[self.sourceFileAndFunction] ?? 0
		let unlockingWithNoLock = oldValue == 0
		if !unlockingWithNoLock {
			traceLockCountForFileAndFunction[self.sourceFileAndFunction] = oldValue - 1
		}
		self.unlockingWithNoLock = unlockingWithNoLock
	}
	
	deinit {
		if !self.unlockingWithNoLock {
			let oldValue = traceLockCountForFileAndFunction[self.sourceFileAndFunction]!
			traceLockCountForFileAndFunction[self.sourceFileAndFunction] = oldValue + 1
		}
	}
	
}
