//
//  RecordingController.swift
//  SimulatorRecorder
//
//  Created by Entin, Grigorii on 18/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

@objc class RecordingController : NSObject {
	
    @objc dynamic var process: Process?
    
    enum RecordingError : Error {
        case missingRecorderExecutable
        case badProcessTerminationStatus(Int32)
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
        return !readyToRecord && !interrupting && !terminated
    }
    @objc dynamic class var keyPathsForValuesAffectingRecording: Set<String> {
        return [
            #keyPath(readyToRecord),
			#keyPath(interrupting),
			#keyPath(terminated)
        ]
    }
    
    @objc dynamic var interrupting: Bool = false
	@objc dynamic var terminated: Bool = false
    
    func stopRecording() {
        guard let process = process else {
            assert(false)
            return
        }
        
        assert(!interrupting)
		interrupting = true
        process.interrupt()
		process.waitUntilExit()
		interrupting = false
    }
    
    func completeRecording(completionHandler: (Error?) -> Void) {
        guard let process = process else {
            assert(false)
            return
        }
        
        defer {
            self.process = nil
            interrupting = false
        }
        
        let terminationStatus = process.terminationStatus
        
        guard 0 == terminationStatus else {
			let error = RecordingError.badProcessTerminationStatus(terminationStatus)
            completionHandler(error)
			return
        }
		
		completionHandler(nil)
    }
	
	func recorderExecutableURL() throws -> URL {
		guard let recorderExecutableURL = Bundle(for: type(of: self)).url(forResource: "recordVideo", withExtension: "") else {
			
			throw RecordingError.missingRecorderExecutable
		}
		return recorderExecutableURL
	}
	
	func startRecording(terminationHandler: @escaping ((Error?) -> Void)) {
		do {
			let recorderExecutableURL = try self.recorderExecutableURL()
			
			let process = Process() ≈ {
				$0.executableURL = recorderExecutableURL
				let extraEnvironment = [
					"APP_BUNDLE": Bundle.main.bundlePath
				]
				$0.environment = ProcessInfo().environment.merging(extraEnvironment, uniquingKeysWith: { $1 })
			}
			process.terminationHandler = { (process) in
				DispatchQueue.main.async {
					assert(self.process == process)
					self.completeRecording(completionHandler: terminationHandler)
				}
			}
			
        	self.process = process
			
			try process.run()
		} catch {
			terminationHandler(error)
		}
    }
}
