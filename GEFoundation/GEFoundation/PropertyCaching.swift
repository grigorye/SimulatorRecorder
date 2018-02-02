//
//  PropertyCaching.swift
//  GEBase
//
//  Created by Grigory Entin on 02.04.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public protocol PropertyCacheable {
	var actualizedValuesCache: NSMutableDictionary? { get }
}

private class CacheRecord<T> : NSObject {
	let value: T
	init(value: T) {
		self.value = value
		super.init()
	}
}

// MARK:-

private func dispatchGetter(p: IMP, _self: NSObject, _cmd: Selector) -> Int {
	typealias GetterType = @convention(c) (NSObject, Selector) -> Int
	return unsafeBitCast(p, to: GetterType.self)(_self, _cmd)
}
private func dispatchSetter(p: IMP, _self: NSObject, _cmd: Selector, value: Int) {
	typealias SetterType = @convention(c) (NSObject, Selector, Int) -> Void
	return unsafeBitCast(p, to: SetterType.self)(_self, _cmd, value)
}
private func dispatchGetter(p: IMP, _self: NSObject, _cmd: Selector) -> Bool {
	typealias GetterType = @convention(c) (NSObject, Selector) -> Bool
	return unsafeBitCast(p, to: GetterType.self)(_self, _cmd)
}
private func dispatchSetter(p: IMP, _self: NSObject, _cmd: Selector, value: Bool) {
	typealias SetterType = @convention(c) (NSObject, Selector, Bool) -> Void
	return unsafeBitCast(p, to: SetterType.self)(_self, _cmd, value)
}
private func dispatchGetter(p: IMP, _self: NSObject, _cmd: Selector) -> AnyObject? {
	typealias GetterType = @convention(c) (NSObject, Selector) -> AnyObject?
	return unsafeBitCast(p, to: GetterType.self)(_self, _cmd)
}
private func dispatchSetter(p: IMP, _self: NSObject, _cmd: Selector, value: AnyObject?) {
	typealias SetterType = @convention(c) (NSObject, Selector, AnyObject?) -> Void
	return unsafeBitCast(p, to: SetterType.self)(_self, _cmd, value)
}

// MARK:-

private func cachedGetterImp<T>(_ _self: PropertyCacheable, _cmd: Selector, propertyName: String, dispatch: (IMP, NSObject, Selector) -> T, oldImp: IMP) -> T {
	let valuesCache = _self.actualizedValuesCache
	if let cacheRecord = valuesCache?[propertyName] as! CacheRecord<T>? {
		return cacheRecord.value
	}
	let value: T = dispatch(oldImp, _self as! NSObject, _cmd)
	if let valuesCache = valuesCache {
		valuesCache[propertyName] = CacheRecord(value: value)
	}
	return value
}

private func cachedSetterImp<T>(_ _self: PropertyCacheable, _cmd: Selector, propertyName: String, value: T, dispatch: (IMP, NSObject, Selector, T) -> Void, oldImp: IMP) {
	let valuesCache = _self.actualizedValuesCache
	dispatch(oldImp, _self as! NSObject, _cmd, value)
	if let valuesCache = valuesCache {
		valuesCache[propertyName] = nil
	}
}

// MARK:-

private func cachedGetterImpForPropertyTypeEncoding(_ propertyTypeEncoding: String, sel: Selector, propertyName: String, oldImp: IMP) -> IMP {
	switch propertyTypeEncoding {
	case objCEncode(Int.self):
		let block: @convention(block) (AnyObject?) -> Int = { _self in
			return cachedGetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, dispatch: dispatchGetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	case objCEncode(Bool.self), "B":
		let block: @convention(block) (AnyObject?) -> Bool = { _self in
			return cachedGetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, dispatch: dispatchGetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	case _ where propertyTypeEncoding.hasPrefix("@"), objCEncode(NSObject.self):
		let block: @convention(block) (AnyObject?) -> AnyObject? = { _self in
			return cachedGetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, dispatch: dispatchGetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	default:
		abort()
	}
}

private func cachedSetterImpForPropertyTypeEncoding(_ propertyTypeEncoding: String, sel: Selector, propertyName: String, oldImp: IMP) -> IMP {
	switch propertyTypeEncoding {
	case objCEncode(Int.self):
		let block: @convention(block) (AnyObject, Int) -> Void = { _self, value in
			cachedSetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, value: value, dispatch: dispatchSetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	case objCEncode(Bool.self), "B":
		let block: @convention(block) (AnyObject, Bool) -> Void = { _self, value in
			cachedSetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, value: value, dispatch: dispatchSetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	case objCEncode(NSObject.self):
		let block: @convention(block) (AnyObject, AnyObject?) -> Void = { _self, value in
			cachedSetterImp(_self as! PropertyCacheable, _cmd: sel, propertyName: propertyName, value: value, dispatch: dispatchSetter, oldImp: oldImp)
		}
		return imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
	default:
		abort()
	}
}

// MARK:-

public func cachePropertyWithName(_ cls: AnyClass!, name propertyName: String) {
	let dt = disableTrace(); defer { _ = dt }
	let property = class_getProperty(cls, propertyName)!
	let propertyTypeEncoding = objCValue(forProperty: property, attributeName: "T")!
	do {
		let getterName = objCValue(forProperty: property, attributeName: "G") ?? propertyName
		let getterSel = NSSelectorFromString(getterName)
		let getterMethod = class_getInstanceMethod(x$(cls), getterSel)
		let getterTypeEncoding = String(validatingUTF8: method_getTypeEncoding(getterMethod!)!)!
		let oldGetterImp = method_getImplementation(getterMethod!)
		let cachedGetterImp = cachedGetterImpForPropertyTypeEncoding(propertyTypeEncoding, sel: getterSel, propertyName: propertyName, oldImp: oldGetterImp)
		let oldGetterImpAfterReplacingMethod = class_replaceMethod(cls, x$(getterSel), x$(cachedGetterImp), getterTypeEncoding)
		assert(oldGetterImp == oldGetterImpAfterReplacingMethod)
	}
	if nil == objCValue(forProperty: property, attributeName: "R") {
		let setterName = objCValue(forProperty: property, attributeName: "S") ?? objCDefaultSetterName(forPropertyName: propertyName)
		let setterSel = NSSelectorFromString(setterName)
		let setterMethod = class_getInstanceMethod(x$(cls), setterSel)
		let setterTypeEncoding = String(validatingUTF8: method_getTypeEncoding(setterMethod!)!)!
		let oldSetterImp = method_getImplementation(setterMethod!)
		let cachedSetterImp = cachedSetterImpForPropertyTypeEncoding(propertyTypeEncoding, sel: setterSel, propertyName: propertyName, oldImp: oldSetterImp)
		let oldSetterImpAfterReplacingMethod = class_replaceMethod(cls, x$(setterSel), x$(cachedSetterImp), setterTypeEncoding)
		assert(oldSetterImp == oldSetterImpAfterReplacingMethod)
	}
}
