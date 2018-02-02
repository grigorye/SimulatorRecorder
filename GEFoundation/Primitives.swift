//
//  Primitives.swift
//  GEBase
//
//  Created by Grigory Entin on 18.07.15.
//  Copyright © 2015 Grigory Entin. All rights reserved.
//

// swiftlint:disable:next identifier_name
public var _1 = true

// swiftlint:disable:next identifier_name
public var _0 = false

public typealias Handler = () -> Void

private func performAndDropEachReversed(_ array: inout [Handler]) {
	for _ in 0..<array.count {
		let handler = array.last!
		handler()
		array = Array(array.dropLast(1))
	}
}

public struct ScheduledHandlers {

	private var handlers = [Handler]()
	
	public var hasHandlers: Bool {
		return 0 < handlers.count
	}
	
	public mutating func perform() {
		performAndDropEachReversed(&handlers)
	}

	public mutating func append(_ handler: @escaping Handler) {
		append(contentsOf: [handler])
	}
	
	public mutating func append(contentsOf extraHandlers: [Handler]) {
		handlers.append(contentsOf: extraHandlers)
	}
	
	// swiftlint:disable:next operator_whitespace
	public static func +=(_ handlers: inout ScheduledHandlers, extraHandlers: [Handler]) {
		handlers.append(contentsOf: extraHandlers)
	}

	public init() {}
	
}
