//
//  TypedUserDefaults.swift
//  GEBase
//
//  Created by Grigory Entin on 15/11/15.
//  Copyright © 2015 Grigory Entin. All rights reserved.
//

import Foundation

typealias _Self = TypedUserDefaults

// swiftlint:disable identifier_name

private let objectValueIMP: @convention(c) (_Self, Selector) -> AnyObject? = { _self, _cmd in
	let propertyName = NSStringFromSelector(_cmd)
	let value = _self.defaults.object(forKey: propertyName) as AnyObject?
	•(propertyName)
	return (value)
}
private let setObjectValueIMP: @convention(c) (_Self, Selector, NSObject?) -> Void = { _self, _cmd, value in
	let defaultName = _Self.defaultNameForSelector(_cmd)
	_self.suiteDefaults.set(value, forKey:(defaultName))
}
private let boolValueIMP: @convention(c) (_Self, Selector) -> Bool = { _self, _cmd in
	let propertyName = NSStringFromSelector(_cmd)
	let value = _self.defaults.bool(forKey: propertyName)
	•(propertyName)
	return (value)
}
private let longValueIMP: @convention(c) (_Self, Selector) -> CLong = { _self, _cmd in
	let propertyName = NSStringFromSelector(_cmd)
	let value = _self.defaults.integer(forKey: propertyName)
	•(propertyName)
	return (value)
}
private let longLongValueIMP: @convention(c) (_Self, Selector) -> CLongLong = { _self, _cmd in
	let propertyName = NSStringFromSelector(_cmd)
	let value = _self.defaults.integer(forKey: propertyName)
	•(propertyName)
	return CLongLong(value)
}
private let floatValueIMP: @convention(c) (_Self, Selector) -> CFloat = { _self, _cmd in
	let propertyName = NSStringFromSelector(_cmd)
	let value = _self.defaults.float(forKey: propertyName)
	•(propertyName)
	return CFloat(value)
}

private let setBoolValueIMP: @convention(c) (_Self, Selector, Bool) -> Void = { _self, _cmd, value in
	let propertyName = _Self.defaultNameForSelector(_cmd)
	x$(propertyName)
	_self.suiteDefaults.set(value, forKey: propertyName)
}
private let setLongValueIMP: @convention(c) (_Self, Selector, CLong) -> Void = { _self, _cmd, value in
    let propertyName = _Self.defaultNameForSelector(_cmd)
	x$(propertyName)
	_self.suiteDefaults.set(value, forKey: propertyName)
}
private let setLongLongValueIMP: @convention(c) (_Self, Selector, CLongLong) -> Void = { _self, _cmd, value in
    let propertyName = _Self.defaultNameForSelector(_cmd)
	x$(propertyName)
	_self.suiteDefaults.set(Int(value), forKey: propertyName)
}
private let setFloatValueIMP: @convention(c) (_Self, Selector, CFloat) -> Void = { _self, _cmd, value in
    let propertyName = _Self.defaultNameForSelector(_cmd)
	x$(propertyName)
	_self.suiteDefaults.set(value, forKey: propertyName)
}

// swiftlint:enable identifier_name

extension TypedUserDefaults {
	typealias _Self = TypedUserDefaults

	static func defaultNameForSelector(_ sel: Selector) -> String {
		let selName = NSStringFromSelector(sel)
		let propertyInfo = getterAndSetterMap[selName]!
		•(propertyInfo)
		let defaultName = propertyInfo.name
		return defaultName
	}

	// MARK: -

	static let (propertyInfoMap, getterAndSetterMap): ([String : PropertyInfo], [String : PropertyInfo]) = {
		var propertyInfoMap = [String : PropertyInfo]()
		var getterAndSetterMap = [String : PropertyInfo]()
		var propertyCount = UInt32(0)
		let propertyList = class_copyPropertyList(_Self.self, &propertyCount)!
		for i in 0..<Int(propertyCount) {
			let property = propertyList[i]
			let propertyInfo = PropertyInfo(property: property)
			let attributesDictionary = propertyInfo.attributesDictionary
			let propertyName = propertyInfo.name
			guard isDefaultName(propertyName) else {
				continue
			}
			let customSetterName = attributesDictionary["S"]
			let customGetterName = attributesDictionary["G"]
			let defaultGetterName = propertyName
			let defaultSetterName = objCDefaultSetterName(forPropertyName: propertyName)
			getterAndSetterMap[customGetterName ?? defaultGetterName] = propertyInfo
			getterAndSetterMap[customSetterName ?? defaultSetterName] = propertyInfo
			propertyInfoMap[propertyName] = propertyInfo
		}
		free(propertyList)
		return (propertyInfoMap, getterAndSetterMap)
	}()

	static func isDefaultName(_ name: String) -> Bool {
		return ![#keyPath(defaults)].contains(name)
	}
}

public class TypedUserDefaults : NSObject {

	@objc let defaults: UserDefaults
	let suiteDefaults: UserDefaults
	
	override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
		guard nil != getterAndSetterMap[key] else {
			return keyPaths
		}
		keyPaths.insert(#keyPath(defaults) + "." + key)
		return keyPaths
	}
	
	public override static func resolveInstanceMethod(_ sel: Selector) -> Bool {
		guard !super.resolveClassMethod(sel) else {
			return true
		}
		let selName = NSStringFromSelector(sel)
		guard let propertyInfo = getterAndSetterMap[selName] else {
			return super.resolveInstanceMethod(sel)
		}
		•(propertyInfo)
		let isSetter = selName.hasSuffix(":")
		let valueTypeEncoded = propertyInfo.valueTypeEncoded
		let methodIMP: IMP = {
			switch ObjCEncode(rawValue: valueTypeEncoded)! {
			case .Bool, .C99Bool:
				return isSetter ? unsafeBitCast(setBoolValueIMP, to: IMP.self) : unsafeBitCast(boolValueIMP, to: IMP.self)
			case .Long, .Int:
				return isSetter ? unsafeBitCast(setLongValueIMP, to: IMP.self) : unsafeBitCast(longValueIMP, to: IMP.self)
			case .LongLong:
				return isSetter ? unsafeBitCast(setLongLongValueIMP, to: IMP.self) : unsafeBitCast(longLongValueIMP, to: IMP.self)
			case .Float:
				return isSetter ? unsafeBitCast(setFloatValueIMP, to: IMP.self) : unsafeBitCast(floatValueIMP, to: IMP.self)
			case .AnyObject:
				return isSetter ? unsafeBitCast(setObjectValueIMP, to: IMP.self) : unsafeBitCast(objectValueIMP, to: IMP.self)
			}
		}()
		let types = isSetter ? "v@:\(valueTypeEncoded)" : "\(valueTypeEncoded)@:"
		types.withCString { typesCString in
			_ = class_addMethod(self, sel, methodIMP, typesCString)
		}
		return true
	}
	
	public init?(suiteName: String? = nil) {
		guard let suiteDefaults = UserDefaults(suiteName: suiteName) else {
			return nil
		}
		self.suiteDefaults = suiteDefaults
		self.defaults = UserDefaults() … {
			guard let suiteName = suiteName else {
				return
			}
			$0.addSuite(named: suiteName)
		}
		super.init()
	}
	
	override public convenience init() {
		self.init(suiteName: nil)!
	}
}

public var defaults = TypedUserDefaults()
