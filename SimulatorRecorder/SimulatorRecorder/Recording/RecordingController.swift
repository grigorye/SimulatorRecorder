//
//  RecordingController.swift
//  SimulatorRecorder
//
//  Created by Entin, Grigorii on 18/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit
import Foundation

@objc public protocol ObjCRecordingController : class {
	@objc var interrupting: Bool { get }
	@objc var recording: Bool { get }
	@objc var readyToRecord: Bool { get }
}

@objc class RecordingController : NSObject, ObjCRecordingController {
	
	func stopRecording() {
		deviceRecorders.filter { $0.recording }.forEach {
			$0.stopRecording()
		}
	}
	
	func startRecording(terminationHandler: @escaping (([Error?]) -> Void)) {
		let devices = try! (SimulatorController().devices())
		let bootedDevices = devices.filter { $0.state == .booted }
		
		let completionGroup = DispatchGroup()
		let completionQueue = DispatchQueue(label: "recordingCompletion")
		var errors: [Error?] = []
		bootedDevices.forEach { device in
			completionGroup.enter()
			let deviceRecorder = DeviceRecorder()
			deviceRecorders.append(deviceRecorder)
			deviceRecorder.startRecording(device) { error in
				completionQueue.async {
					errors.append(error)
					completionGroup.leave()
				}
			}
		}
		completionGroup.notify(queue: completionQueue) { [weak self] in
			terminationHandler(errors)
			DispatchQueue.main.async {
				self?.deviceRecorders = []
			}
		}
	}
	
	// MARK: -
	
	override init() {
		super.init()
		
		self.bind(
			NSBindingName(rawValue: #keyPath(recording)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.recording),
			options: [
				.nullPlaceholder: false
			]
		)
		self.bind(
			NSBindingName(rawValue: #keyPath(readyToRecord)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.min, \DeviceRecorder.readyToRecord),
			options: [
				.nullPlaceholder: true
			]
		)
		self.bind(
			NSBindingName(rawValue: #keyPath(interrupting)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.interrupting),
			options: [
				.nullPlaceholder: false
			]
		)
	}
	
	@objc dynamic var deviceRecordersController = NSArrayController()
	@objc dynamic var deviceRecorders: [DeviceRecorder] = [] {
		didSet {
			deviceRecordersController.content = deviceRecorders
		}
	}
	@objc dynamic var recording: Bool = false
	@objc dynamic var readyToRecord: Bool = false
	@objc dynamic var interrupting: Bool = false
}

class DeviceRecorder : NSObject {
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
		let recorderExecutableURL = try throwify(Bundle(for: type(of: self)).url(forResource: "recordVideo", withExtension: ""))
		return recorderExecutableURL
	}
	
	func startRecording(_ device: SimulatorDeviceInfo, terminationHandler: @escaping (Error?) -> Void) {
		do {
			let recorderExecutableURL = try self.recorderExecutableURL()
			
			let process = Process() ≈ {
				$0.executableURL = recorderExecutableURL
				let extraEnvironment = [
					"APP_BUNDLE": Bundle.main.bundlePath
				]
				$0.environment = ProcessInfo().environment.merging(extraEnvironment, uniquingKeysWith: { $1 })
				$0.arguments = [
					device.udid,
					device.name,
					device.osVersion
				]
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
