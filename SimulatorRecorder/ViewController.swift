//
//  ViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class ViewController : NSViewController, GlobalActionResponder {
	
	@objc dynamic var recordingController: RecordingController! = RecordingController()
	
	@IBAction func stopRecording(_ sender: Any) {
		recordingController.stopRecording()
	}
	
	@IBAction func toggleRecording(_ sender: Any) {
		if recordingController.recording {
			stopRecording(sender)
		} else {
			newScreenRecording(sender)
		}
	}
	
	func completeRecording(_ error: Error?) {
		guard let window = view.window else {
			assert(false)
			return
		}
		
		guard let error = error else {
			return
		}
		
		presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
	}
	
	@IBAction func newScreenRecording(_ sender: Any) {
		recordingController.startRecording { (error) in
			self.completeRecording(error)
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
