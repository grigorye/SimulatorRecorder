//
//  AppStatusItemControllerSource.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 14/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import MASShortcut

extension TypedUserDefaults {
	@NSManaged var toggleRecordingShortcutData: Data?
}

class AppStatusItemControllerSource : StatusItemControllerDataSource {
	
	var shortcut: MASShortcut? {
		guard let shortcutData = defaults.toggleRecordingShortcutData else {
			return nil
		}
		let shortcut = NSKeyedUnarchiver.unarchiveObject(with: shortcutData) as! MASShortcut?
		return shortcut
	}
	
	var keyEquivalent: String {
		return shortcut?.keyCodeString ?? ""
	}
	
	var keyEquivalentModifierMask: NSEvent.ModifierFlags {
		guard let modifierFlags = shortcut?.modifierFlags else {
			return .init()
		}
		return modifierFlags
	}
	
	var stopRecordingEnabled: Bool {
		return recordingInteractor.recordingState.recording
	}
	
	var startRecordingEnabled: Bool {
		return recordingInteractor.recordingState.readyToRecord
	}
	
	var observableIcon: ObservableIcon = AppStatusIcon() … {
		$0.recordingState = recordingInteractor.recordingState
	}
}
