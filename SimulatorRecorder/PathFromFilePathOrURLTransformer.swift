//
//  PathFromFilePathOrURLTransformer.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 05.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

extension NSValueTransformerName {
	
	static let pathFromFilePathOrURLTransformerName = NSValueTransformerName(rawValue: "PathFromFilePathOrURL")
}

/// Transforms (String|URL*) <-> String (favoring URLs); suitable for binding NSPathControl's value to user defaults.
class PathFromFilePathOrURLTransformer : ValueTransformer {

	override class func transformedValueClass() -> AnyClass {
		
		return NSURL.self
	}
	
	override class func allowsReverseTransformation() -> Bool {
		
		return true
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		
		guard let pathWithTilde = value as? String else {
			
			return value
		}
		let path = (pathWithTilde as NSString).expandingTildeInPath
		let url = URL(fileURLWithPath: path)
		return url
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		
		switch value {
		case nil:
			return nil
		case let url as URL:
			return url.path
		case let path as String:
			return path
		default:
			assert(false)
			return value
		}
	}
}
