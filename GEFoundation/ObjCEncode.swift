//
//  ObjCEncode.swift
//  GEFoundation
//
//  Created by Grigory Entin on 23.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
enum ObjCEncode : String {
	case Bool = "c"
	case Int = "i"
	case Long = "l"
	case LongLong = "q"
	case C99Bool = "B"
	case AnyObject = "@"
	case Float = "f"
}
// swiftlint:enable identifier_name

public func objCEncode<T>(_ type: T.Type) -> String {
	switch type {
	case is Int.Type:
		return String(validatingUTF8: (1 as NSNumber).objCType)!
	case is Bool.Type:
		return String(validatingUTF8: (true as NSNumber).objCType)!
	case is AnyObject.Type:
		return "@"
	default:
		abort()
	}
}

public func objCValue(forProperty property: objc_property_t, attributeName: String) -> String? {
	let valueCString = property_copyAttributeValue(property, attributeName)!
	let x = String(validatingUTF8: valueCString)
	free(valueCString)
	return x
}
