//
//  DefaultsRegistration.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 05.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

let defaultsRegistrationDictionary: [String : Any]? = {
	
	guard let defaultsURL = Bundle.main.url(forResource: "Defaults", withExtension: "plist") else {
		
		return nil
	}
	guard let defaultsData = try? Data(contentsOf: defaultsURL) else {
		
		return nil
	}
	guard let defaultsPlist = try? PropertyListSerialization.propertyList(from: defaultsData, options: [], format: nil) else {
		
		return nil
	}
	guard let defaultsDictionary = defaultsPlist as? [String : Any] else {
		
		return nil
	}
	
	return defaultsDictionary
}()
