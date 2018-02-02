//
//  ErrorRecovery.swift
//  GEFoundation
//
//  Created by Grigory Entin on 10.12.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import protocol Foundation.RecoverableError

public struct RecoveryOption {

	public let title: String

	public let handler: () -> Bool

	public init(title: String, handler: @escaping () -> Bool) {
		self.title = title
		self.handler = handler
	}
	
}

public protocol RecoverableError : Foundation.RecoverableError {

	var recoveryOptions: [RecoveryOption] { get }
	
}

public extension RecoverableError {

	public var recoveryOptions: [String] {
		return recoveryOptions.map { $0.title }
	}
	
	public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
		return recoveryOptions[recoveryOptionIndex].handler()
	}
	
}
