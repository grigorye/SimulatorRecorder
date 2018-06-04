//
//  EncodedUserDefaults.swift
//  GEBase
//
//  Created by Grigory Entin on 15.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

extension UserDefaults {
	public func decodeObject<T: Decodable>(forKey key: String) throws -> T? {
		guard let data = self.data(forKey: key) else {
			return nil
		}
		
		let unarchivedObject = try JSONDecoder().decode(T.self, from: data)
		return unarchivedObject
	}
	public func encode<T: Encodable>(_ object: T?, forKey key: String) throws {
		let encodedObjectData: Data? = try {
			guard let object = object else {
				return nil
			}
			return try JSONEncoder().encode(object)
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
	public func decodeInGetter<T: Decodable>(function: String = #function) -> T? {
		return try! decodeObject(forKey: keyForGetter(function))
	}
	public func encodeInSetter<T: Encodable>(_ object: T?, function: String = #function) {
		try! encode(object, forKey: keyForSetter(function))
	}
}
