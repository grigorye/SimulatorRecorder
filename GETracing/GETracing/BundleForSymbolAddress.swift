//
//  BundleForSymbolAddress.swift
//  GEBase
//
//  Created by Grigory Entin on 16/11/15.
//  Copyright © 2015 Grigory Entin. All rights reserved.
//

import Foundation

func bundleURLFromSharedObjectName(_ objectName: String) -> URL? {
	
	let objectURL = URL(fileURLWithPath: objectName)
	let objectParentURL = objectURL.deletingLastPathComponent()
	
	guard !["app", "xctest", "framework"].contains(objectParentURL.pathExtension) else {
		
		// .{app|xctest|framework}/SharedObject
		return objectParentURL
	}
	
	let objectGrandparentURL = objectParentURL.deletingLastPathComponent()
	let objectGrandgrandparentURL = objectGrandparentURL.deletingLastPathComponent()
	
	guard objectParentURL.lastPathComponent != "MacOS" else {
		guard objectGrandparentURL.lastPathComponent == "Contents" else {
			
			return nil
		}
		
		// .{app|xctest}/Contents/MacOS/SharedObject
		assert(["app", "xctest"].contains(objectGrandgrandparentURL.pathExtension))
		return objectGrandgrandparentURL
	}
	
	guard "Versions" != objectGrandparentURL.lastPathComponent else {
		
		// .framework/Versions/X/SharedObject
		assert("framework" == objectGrandgrandparentURL.pathExtension)
		return objectGrandgrandparentURL
	}
	
	return nil
}

extension Bundle {
	
	public convenience init?(for symbolAddr: UnsafeRawPointer) {
		
		var info = Dl_info()
		guard 0 != dladdr(symbolAddr, &info) else {
			return nil
		}
		
		let sharedObjectName = String(validatingUTF8: info.dli_fname)!
		guard let bundleURL = bundleURLFromSharedObjectName(sharedObjectName) else {
			
			assert(false, "Couldn't get bundle for \(sharedObjectName).")
			return nil
		}
		
		self.init(url: bundleURL)
	}
}
