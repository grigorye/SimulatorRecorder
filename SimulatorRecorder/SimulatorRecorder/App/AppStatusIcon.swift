//
//  AppStatusIcon.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 14/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

class AppStatusIcon : ObservableIcon {
	
	@objc dynamic var recordingState: ObservableRecordingState!
	
	@objc override dynamic var value: NSImage? {
		return recordingState.recording ? #imageLiteral(resourceName: "MenuIconRecording") : #imageLiteral(resourceName: "MenuIcon")
	}
	@objc dynamic class var keyPathsForValuesAffectingValue: Set<String> {
		return [#keyPath(recordingState.recording)]
	}
}
