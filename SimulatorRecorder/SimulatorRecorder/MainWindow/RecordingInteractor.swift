//
//  RecordingInteractor.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 08/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

var recordingInteractor = RecordingInteractor()

class RecordingInteractor: NSResponder, GlobalActionResponder {
	
	@objc dynamic var recordingController: RecordingController! = RecordingController()
	
	@IBAction func stopRecording(_ sender: Any) {
		recordingController.stopRecording { errors in
			let errors = errors.compactMap {$0}
			if let error = errors.last {
				_ = x$(error)
			}
		}
	}
	
	@IBAction func toggleRecording(_ sender: Any) {
		if recordingController.recording {
			stopRecording(sender)
		} else {
			newScreenRecording(sender)
		}
	}
	
	var window: NSWindow {
		return NSApplication.shared.mainWindow!
	}
	
	func completeRecording(_ error: Error?) {
		guard let error = error else {
			return
		}
		
		presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
	}
	
	@IBAction func newScreenRecording(_ sender: Any) {
		sendUserNotification(for: .startedRecording)
		recordingController.startRecording { (errors) in
			DispatchQueue.main.async {
				sendUserNotification(for: .recordingCompleted)
				self.completeRecording(errors.compactMap {$0}.last)
			}
		}
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.action {
			
		case #selector(stopRecording(_:))?:
			return recordingController.recording
			
		case #selector(newScreenRecording(_:))?:
			return recordingController.readyToRecord
			
		default:
			return true
		}
	}
}
