//
//  DefaultsInSettingsPlist.swift
//  GEBase
//
//  Created by Grigory Entin on 28.04.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

public func loadDefaultsFromSettingsPlistAtURL(_ url: URL) throws {
	let data = try Data(contentsOf: url, options: NSData.ReadingOptions(rawValue: 0))
	let settingsPlist = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil) as! [String : AnyObject]
	let preferencesSpecifiers = settingsPlist["PreferenceSpecifiers"] as! [[String : AnyObject]]
	let defaultKeysAndValuesForRegistration: [(key: String, defaultValue: AnyObject)] = preferencesSpecifiers.compactMap {
		guard let key = $0["Key"] as? String else {
			return nil
		}
		let defaultValue = $0["DefaultValue"]
		return (key: key, defaultValue: defaultValue!)
	}
	let defaultsForRegistration: [String : AnyObject] = defaultKeysAndValuesForRegistration.reduce([String : AnyObject]()) {
		var x = $0
		x[$1.key] = $1.defaultValue
		return x
	}
	UserDefaults().register(defaults: (defaultsForRegistration))
}
