//
//  AppVersion.swift
//  GEBase
//
//  Created by Grigory Entin on 11.09.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public let buildAge: TimeInterval = {
	let buildDate = try! FileManager.default.attributesOfItem(atPath: Bundle.main.bundlePath)[FileAttributeKey.modificationDate] as! Date
	return Date().timeIntervalSince(buildDate)
}()

public let versionIsClean: Bool = {
	let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
	x$(version)
	return nil == version.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted)
}()
