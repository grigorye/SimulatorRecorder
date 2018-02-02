//
//  PreferencesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 02.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class PreferencesViewController : NSViewController {
	
	@IBOutlet var filenamePaletteTokenField: NSTokenField!
	@IBOutlet var filenameTokenField: NSTokenField!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		filenameTokenField.objectValue = ["Recording", FilenameTokenObject(value: .date), "at", FilenameTokenObject(value: .time), "for", FilenameTokenObject(value: .device), "-", FilenameTokenObject(value: .version)]
		filenamePaletteTokenField.objectValue = ([.date, .time, .device, .version] as [FilenameToken]).map(FilenameTokenObject.init(value:))
	}
}
