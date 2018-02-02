//
//  SwiftBackwardCompatibility.swift
//  GEFoundation
//
//  Created by Grigory Entin on 24.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

#if swift(>=4.1)
#else
extension Array {
	public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
		return try flatMap(transform)
	}
}
#endif

