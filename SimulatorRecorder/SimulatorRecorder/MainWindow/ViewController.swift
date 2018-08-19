//
//  ViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	@objc dynamic var recordingState: ObservableRecordingState {
		return recordingInteractor.recordingState
	}
}
