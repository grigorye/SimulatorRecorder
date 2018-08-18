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

