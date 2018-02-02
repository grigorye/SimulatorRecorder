//
//  AssociatedObjects.swift
//  GEBase
//
//  Created by Grigory Entin on 03.04.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public func associatedObjectRegeneratedAsNecessary<T>(obj: AnyObject!, key: UnsafeRawPointer, generator: () -> T) -> T {
	•(NSValue(pointer: Unmanaged.passUnretained(obj).toOpaque()))
	guard let existingObject = objc_getAssociatedObject(obj, key) as! T? else {
		let newObject = generator()
		objc_setAssociatedObject(obj, key, newObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		return newObject
	}
	return existingObject
}

#if false
func associatedObjectRegeneratedAsNecessary<T>(cls obj: AnyClass!, key: UnsafeRawPointer, type: T.Type) -> T {
	•(NSValue(pointer: Unmanaged.passUnretained(obj as Any!).toOpaque()))
	guard let existingObject = objc_getAssociatedObject(obj, key) as! T! else {
		let newObject = (type as! NSObject.Type).init()
		objc_setAssociatedObject(obj, key, newObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		return newObject as! T
	}
	return existingObject
}
#endif
