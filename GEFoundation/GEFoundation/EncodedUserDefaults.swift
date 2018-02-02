//
//  EncodedUserDefaults.swift
//  GEBase
//
//  Created by Grigory Entin on 15.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

extension UserDefaults {
	public func decodeObject<T>(forKey key: String) -> T? {
		guard let data = self.data(forKey: key) else {
			return nil
		}
		let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(with: data) as! T
		return Optional(unarchivedObject)
	}
	public func encode<T>(_ object: T?, forKey key: String) {
		let encodedObjectData: Data? = {
			guard let object = object else {
				return nil
			}
			return NSKeyedArchiver.archivedData(withRootObject: object as! NSObject)
		}()
		self.set(encodedObjectData, forKey: key)
	}
}

func keyForGetter(_ function: String) -> String {
	return function
}
func keyForSetter(_ function: String) -> String {
	return function
}

extension UserDefaults {
	public func decodeInGetter<T>(function: String = #function) -> T? {
		return decodeObject(forKey: keyForGetter(function))
	}
	public func encodeInSetter<T>(_ object: T?, function: String = #function) {
		encode(object, forKey: keyForSetter(function))
	}
}
