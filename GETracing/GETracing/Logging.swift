//
//  Logging.swift
//  GETracing
//
//  Created by Grigory Entin on 24.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

/// Nothing more than a wrapper around log parameters.

public struct SourceExtractedInfo {
	public let label: String
	public let playgroundName: String?
	init(label: String, playgroundName: String? = nil) {
		self.label = label
		self.playgroundName = playgroundName
	}
}

public struct LogRecord {
	public let message: String
	public let sourceExtractedInfo: SourceExtractedInfo?
	public let date: Date
	public let location: SourceLocation!
}

extension LogRecord {
	public var label: String? {
		return self.sourceExtractedInfo?.label
	}
	public var playgroundName: String? {
		return self.sourceExtractedInfo?.playgroundName
	}
}

public typealias Logger = (LogRecord) -> ()

/// Loggers used with `trace`.
public var loggers: [Logger] = [
]

public func log(_ record: LogRecord) {
	for logger in loggers {
		logger(record)
	}
}

public func log<T>(_ value: T, on date: Date, at location: SourceLocation, traceFunctionName: String) {
	guard 0 < loggers.count else {
		return
	}
	let sourceExtractedInfo = GETracing.sourceExtractedInfo(for: location, traceFunctionName: traceFunctionName)
	let message = descriptionImp(of: value)
	let record = LogRecord(message: message, sourceExtractedInfo: sourceExtractedInfo, date: date, location: location)
	log(record)
}

public func logWithNoSourceOrLabel(_ message: String) {
	let record = LogRecord(message: message, sourceExtractedInfo: nil, date: Date(), location: nil)
	log(record)
}
