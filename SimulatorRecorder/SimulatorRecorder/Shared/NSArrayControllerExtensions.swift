//
//  NSArrayControllerExtensions.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 18/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit.NSArrayController

enum KeyPathGroupOp: String {
	case nop = "self"
	case max = "@max"
	case min = "@min"
}

func arrangedObjectsKeyPath<T>(_ groupOp: KeyPathGroupOp = .nop, _ keyPath: PartialKeyPath<T>) -> String {
	return [#keyPath(NSArrayController.arrangedObjects), groupOp.rawValue, keyPath._kvcKeyPathString!].joined(separator: ".")
}

class ObservableBool : NSObject {
	@objc dynamic var value: Bool { return false }
}

class ObservableArrayPredicateValue : ObservableBool {
	let arrayController: NSArrayController
	let keyPath: String
	let nullPlaceholder: Bool
	
	init(_ arrayController: NSArrayController, keyPath: String, nullPlaceholder: Bool) {
		self.arrayController = arrayController
		self.keyPath = keyPath
		self.nullPlaceholder = nullPlaceholder
	}
	
	@objc override dynamic var value: Bool {
		_ = valueBinding
		return valueImp
	}
	
	@objc private dynamic class var keyPathsForValuesAffectingValue: Set<String> {
		return [#keyPath(valueImp)]
	}
	
	private lazy var valueBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(valueImp)),
			to: arrayController,
			withKeyPath: keyPath,
			options: [
				.nullPlaceholder: self.nullPlaceholder
			]
		)
	}()
	
	@objc private dynamic var valueImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}
}
