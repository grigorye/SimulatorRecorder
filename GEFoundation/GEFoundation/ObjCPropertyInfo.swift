//
//  ObjCPropertyInfo.swift
//  GEBase
//
//  Created by Grigory Entin on 02.04.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public func objCDefaultSetterName(forPropertyName propertyName: String) -> String {
    let head = propertyName.uppercased().first!
    let tail = propertyName[propertyName.index(after: propertyName.startIndex)...]
	return "set\(head)\(tail):"
}

struct PropertyInfo {
	let name: String
	let attributes: String
	let attributesDictionary: [String : String]
}

extension PropertyInfo {
	var valueTypeEncoded: String {
		let type = attributesDictionary["T"]!
		let valueTypeEncoded = String(type.utf8.prefix(1))!
		return valueTypeEncoded
	}
}

extension PropertyInfo {
	init(property: objc_property_t) {
		self.name = String(validatingUTF8: property_getName(property))!
		self.attributes = String(validatingUTF8: property_getAttributes(property)!)!
		self.attributesDictionary = {
			var attributesCount = UInt32(0)
			let attributesList = property_copyAttributeList(property, &attributesCount)!
			var x = [String : String]()
			for i in 0..<Int(attributesCount) {
				let attribute = attributesList[i]
				let attributeName = String(validatingUTF8: attribute.name)!
				let attributeValue = String(validatingUTF8: attribute.value)!
				x[attributeName] = attributeValue
			}
			free(attributesList)
			return x
		}()
	}
}
