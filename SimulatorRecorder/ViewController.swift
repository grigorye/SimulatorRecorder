//
//  ViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, GlobalActionResponder {
	
	@objc dynamic var process: Process?
	
	enum RecordingError : Error {
		case missingRecorderExecutable
		case badProcessTerminationStatus(Int32)
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		
		switch menuItem.action {
			
		case #selector(stopRecording(_:))?:
			
			return recording
			
		case #selector(newScreenRecording(_:))?:
			
			return readyToRecord
			
		default:
			return true
		}
	}
	
    @objc dynamic var readyToRecord: Bool {
        
        return process == nil
    }
    @objc dynamic class var keyPathsForValuesAffectingReadyToRecord: Set<String> {
        
        return [
            #keyPath(process)
        ]
    }

	@objc dynamic var recording: Bool {
		
		return !readyToRecord && !interrupting
	}
    @objc dynamic class var keyPathsForValuesAffectingRecording: Set<String> {
        
        return [
            #keyPath(readyToRecord),
            #keyPath(interrupting)
        ]
    }

    @objc dynamic var interrupting: Bool = false
    
	@IBAction func toggleRecording(_ sender: Any) {
		
		if recording {
			stopRecording(sender)
		} else {
			newScreenRecording(sender)
		}
	}
	
	@IBAction func stopRecording(_ sender: Any) {
		
		guard let process = process else {
			
			assert(false)
			return
		}
		
        assert(!interrupting)
        interrupting = true
		process.interrupt()
	}
	
	func completeRecording() {
		
		guard let process = process else {
			assert(false)
			return
		}
		
		defer {
			self.process = nil
            interrupting = false
		}
		
		let terminationStatus = process.terminationStatus
		
		if 0 != terminationStatus {
			
			guard let window = view.window else {
				
				assert(false)
				return
			}
			
			presentError(RecordingError.badProcessTerminationStatus(terminationStatus), modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	func startRecording() throws {
		
		guard let recorderExecutableURL = Bundle(for: type(of: self)).url(forResource: "recordVideo", withExtension: "") else {
			
			throw RecordingError.missingRecorderExecutable
		}
		
		let process = try Process.run(recorderExecutableURL, arguments: []) {
			
			assert(self.process == $0)
			
			DispatchQueue.main.async {
				
				self.completeRecording()
			}
		}
		
		self.process = process
	}
	
	@IBAction func newScreenRecording(_ sender: Any) {
		
		do {
			
			try startRecording()
			
		} catch {
			
			guard let window = view.window else {
				
				assert(false)
				return
			}
			
			presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
}
