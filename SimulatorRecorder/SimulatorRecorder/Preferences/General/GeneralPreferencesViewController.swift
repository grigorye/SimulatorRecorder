//
//  GeneralPreferencesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 28/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

extension TypedUserDefaults {
	@NSManaged var revealInFinder: NSNumber?
	@NSManaged var recordingsDir: String?
	@NSManaged var compressionEnabled: NSNumber?
}

class GeneralPreferencesViewController : PreferencesPaneViewController {
	override func resetDefaults() {
		defaults.revealInFinder = nil
		defaults.toggleRecordingShortcutData = nil
		defaults.recordingsDir = nil
		defaults.compressionEnabled = nil
	}
}
