//
//  AppDockTileIcon.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 25/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

class AppDockTileIcon : ObservableIcon {
	
	@objc dynamic var recordingState: ObservableRecordingState!
	
	@objc override dynamic var value: NSImage? {
		return recordingState.recording ? #imageLiteral(resourceName: "AppIconRecording") : nil
	}
	@objc dynamic class var keyPathsForValuesAffectingValue: Set<String> {
		return [#keyPath(recordingState.recording)]
	}
}
