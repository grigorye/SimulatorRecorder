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
