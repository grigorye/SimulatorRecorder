//
//  Flattenable.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 10.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

@objc public protocol Flattenable {
	
	@objc func flattenWithPrefix(_ prefix: String?) -> [String : Any]
	
}

extension NSObject: Flattenable {
	
	public func flattenWithPrefix(_ prefix: String?) -> [String : Any] {
		return [prefix! : self]
	}
	
}

extension NSDictionary {
	
	public override func flattenWithPrefix(_ prefix: String?) -> [String : Any] {
		var x = [String : Any]()
		for (key, value) in self {
			let subprefix = (prefix?.appending(".") ?? "") + "\(key)"
			let flattenableValue = value as! Flattenable
			for (subkey, subvalue) in flattenableValue.flattenWithPrefix(subprefix) {
				x[subkey] = subvalue
			}
		}
		return x
	}
	
}

extension NSArray {
	
	public override func flattenWithPrefix(_ prefix: String?) -> [String : Any] {
		var x = [String : Any]()
		for (i, value) in self.enumerated() {
			let subprefix = (prefix?.appending(".") ?? "") + "\(i)"
			let flattenableValue = value as! Flattenable
			for (subkey, subvalue) in flattenableValue.flattenWithPrefix(subprefix) {
				x[subkey] = subvalue
			}
		}
		return x
	}
	
}
