//
//  MainWindowController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 01/10/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import GEFoundation
import Foundation

class MainWindowController : NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		setupWindowFrameAutosaveName()
		setupWindowLevelBinding()
	}
	
	// MARK: -
	
	private func setupWindowFrameAutosaveName() {
		assert(windowFrameAutosaveName.isEmpty)
		self.windowFrameAutosaveName = window!.frameAutosaveName
	}
	
	private func setupWindowLevelBinding() {
		let observation = recordingInteractor.observe(\RecordingInteractor.recordingState.readyToRecord, options: [.initial]) { [weak window] (r, v) in
			window?.level = r.recordingState.readyToRecord ? .normal : .floating
		}
		scheduledForDeinit.append {
			_ = observation
		}
	}
	
	// MARK: -
	
	var scheduledForDeinit = ScheduledHandlers()
	deinit {
		scheduledForDeinit.perform()
	}
}
