//
//  DefaultLogger.swift
//  GEBase
//
//  Created by Grigory Entin on 14/02/16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import struct GETracing.LogRecord
import Foundation
import os

private var bundleLogAssoc: Void?

@available(iOS 10.0, *)
extension Bundle {
	public var log: OSLog {
		return associatedObjectRegeneratedAsNecessary(obj: self, key: &bundleLogAssoc) {
			OSLog(subsystem: self.bundleIdentifier!, category: "default")
		}
	}
}

let dateFormatter = DateFormatter() … {
	$0.dateFormat = "HH:mm.ss.SSS"
}

enum DefaultLogKind: String {
	case none, oslog, nslog, print
}

extension TypedUserDefaults {
	@NSManaged var defaultLogKind: String?
	@NSManaged var defaultLogPrintTimestamps: Bool
}

private let traceToNSLogEnabled = false

public func defaultLoggedText(for record: LogRecord) -> String {
	guard let location = record.location else {
		return "◾︎ \(record.message)"
	}
	let locationDescription = "\(location.function), \(record.playgroundName ?? location.fileURL.lastPathComponent):\(location.line)"
	guard let label = record.label else {
		return "\(locationDescription) ◾︎ \(record.message)"
	}
	return "\(locationDescription) ◾︎ \(label): \(record.message)"
}

public func defaultLoggedTextWithTimestampAndThread(for record: LogRecord) -> String {
	let text = defaultLoggedText(for: record)
	let dateDescription = dateFormatter.string(from: record.date)
	let threadDescription = Thread.isMainThread ? "-" : "\(DispatchQueue.global().label)"
	let textWithTimestampAndThread = "\(dateDescription) [\(threadDescription)] \(text)"
	return textWithTimestampAndThread
}

public func defaultLoggedTextWithThread(for record: LogRecord) -> String {
	let text = defaultLoggedText(for: record)
	let threadDescription = Thread.isMainThread ? "-" : "\(DispatchQueue.global().label)"
	let textWithThread = "[\(threadDescription)] \(text)"
	return textWithThread
}

// void rdar_os_log_object_with_type(void const *dso, os_log_t log, os_log_type_t type, id object);

@available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
@_silgen_name("rdar_os_log_object_with_type") private func rdar_os_log_object_with_type(_ dso: UnsafeRawPointer?, _ log: OSLog, _ type: OSLogType, _ object: AnyObject)

public func defaultLogger(record: LogRecord) {
	guard let defaultLogKind = defaults.defaultLogKind else { return }
	switch DefaultLogKind(rawValue: defaultLogKind)! {
	case .none: ()
	case .oslog:
		let text = defaultLoggedText(for: record)
		if #available(iOS 10.0, *), let location = record.location, case .dso(let dso) = location.moduleReference {
			let bundle = Bundle(for: dso)!
			rdar_os_log_object_with_type(dso, bundle.log, .default, text as NSString)
		} else {
			fallthrough
		}
	case .nslog:
		let text = defaultLoggedText(for: record)
		NSLog("%@", text)
	case .print:
		let textGenerator = defaults.defaultLogPrintTimestamps ? defaultLoggedTextWithTimestampAndThread(for:) : defaultLoggedTextWithThread(for:)
		let textWithTimestampAndThread = textGenerator(record)
		print(textWithTimestampAndThread)
	}
}
