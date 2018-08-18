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
	
	func stopRecording(completionHandler: @escaping ([Error?]) -> Void) {
		var errors: [Error?] = []
		let completionGroup = DispatchGroup()
		let completionQueue = DispatchQueue(label: "stopRecording")
		deviceRecorders.filter { $0.recording }.forEach {
			completionGroup.enter()
			$0.stopRecording { error in
				completionQueue.async {
					errors.append(error)
					completionGroup.leave()
				}
			}
		}
		completionGroup.notify(queue: completionQueue) {
			completionHandler(errors)
		}
	}
	
	func startRecording(terminationHandler: @escaping (([Error?]) -> Void)) {
		let devices = try! (SimulatorController().devices())
		let bootedDevices = devices.filter { $0.state == .booted }
		
		let completionGroup = DispatchGroup()
		let completionQueue = DispatchQueue(label: "recording")
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
	
	@objc dynamic var deviceRecordersController = NSArrayController()
	@objc dynamic var deviceRecorders: [DeviceRecorder] = [] {
		didSet {
			deviceRecordersController.content = deviceRecorders
		}
	}

	// MARK: -
	
	@objc dynamic class var keyPathsForValuesAffectingRecording: Set<String> {
		return [#keyPath(recordingImp)]
	}
	private lazy var recordingBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(recordingImp)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.recording),
			options: [
				.nullPlaceholder: false
			]
		)
	}()
	@objc dynamic var recording: Bool {
		_ = self.recordingBinding
		return recordingImp
	}
	@objc private dynamic var recordingImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}

	// MARK: -
	
	@objc dynamic class var keyPathsForValuesAffectingReadyToRecord: Set<String> {
		return [#keyPath(readyToRecordImp)]
	}
	private lazy var readyToRecordBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(readyToRecordImp)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.min, \DeviceRecorder.readyToRecord),
			options: [
				.nullPlaceholder: true
			]
		)
	}()
	@objc dynamic var readyToRecord: Bool {
		_ = readyToRecordBinding
		return readyToRecordImp
	}
	@objc private dynamic var readyToRecordImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}
	
	// MARK: -
	
	@objc dynamic class var keyPathsForValuesAffectingInterrupting: Set<String> {
		return [#keyPath(interruptingImp)]
	}
	private lazy var interruptingBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(interruptingImp)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.interrupting),
			options: [
				.nullPlaceholder: false
			]
		)
	}()
	@objc dynamic var interrupting: Bool {
		_ = interruptingBinding
		return interruptingImp
	}
	@objc private dynamic var interruptingImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}
}
