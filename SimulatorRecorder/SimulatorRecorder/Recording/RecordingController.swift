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
		precondition(!self.recording)
		precondition(!self.recordingInitiated)
		self.recordingInitiated = true
		DispatchQueue.global().async {
			defer {
				DispatchQueue.main.async {
					self.recordingInitiated = false
				}
			}
			do {
				let devices = try (SimulatorController().devices())
				DispatchQueue.main.async {
					self.proceedWithRecording(devices: devices, terminationHandler: terminationHandler)
				}
			} catch {
				terminationHandler([error])
			}
		}
	}
	
	func proceedWithRecording(devices: [SimulatorDeviceInfo], terminationHandler: @escaping ([Error?]) -> Void) {
		let bootedDevices = devices.filter { $0.state == .booted }
		
		let completionGroup = DispatchGroup()
		let completionQueue = DispatchQueue(label: "recordingTermination")
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
	
	@objc private dynamic var recordingInitiated: Bool = false
	
	// MARK: -
	
	@objc dynamic var recording: Bool {
		return self.anyDeviceRecording || recordingInitiated
	}
	@objc private dynamic class var keyPathsForValuesAffectingRecording: Set<String> {
		return [
			#keyPath(anyDeviceRecording),
			#keyPath(recordingInitiated)
		]
	}
	
	// MARK: -
	
	@objc dynamic var readyToRecord: Bool {
		return self.everyDeviceReadyToRecord && !recordingInitiated
	}
	@objc private dynamic class var keyPathsForValuesAffectingReadyToRecord: Set<String> {
		return [
			#keyPath(everyDeviceReadyToRecord),
			#keyPath(recordingInitiated)
		]
	}
	
	// MARK: -
	
	@objc dynamic var anyDeviceRecording: Bool {
		_ = self.anyDeviceRecordingBinding
		return anyDeviceRecordingImp
	}
	@objc private dynamic class var keyPathsForValuesAffectingAnyDeviceRecording: Set<String> {
		return [
			#keyPath(anyDeviceRecordingImp)
		]
	}
	private lazy var anyDeviceRecordingBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(anyDeviceRecordingImp)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.recording),
			options: [
				.nullPlaceholder: false
			]
		)
	}()
	@objc private dynamic var anyDeviceRecordingImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}

	// MARK: -
	
	@objc dynamic var everyDeviceReadyToRecord: Bool {
		_ = everyDeviceReadyToRecordBinding
		return everyDeviceReadyToRecordImp
	}
	@objc private dynamic class var keyPathsForValuesAffectingEveryDeviceReadyToRecord: Set<String> {
		return [#keyPath(everyDeviceReadyToRecordImp)]
	}
	private lazy var everyDeviceReadyToRecordBinding: Void = {
		self.bind(
			NSBindingName(rawValue: #keyPath(everyDeviceReadyToRecordImp)),
			to: deviceRecordersController,
			withKeyPath: arrangedObjectsKeyPath(.min, \DeviceRecorder.readyToRecord),
			options: [
				.nullPlaceholder: true
			]
		)
	}()
	@objc private dynamic var everyDeviceReadyToRecordImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}
	
	// MARK: -
	
	@objc dynamic var interrupting: Bool {
		_ = interruptingBinding
		return interruptingImp
	}
	@objc private dynamic class var keyPathsForValuesAffectingInterrupting: Set<String> {
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
	@objc private dynamic var interruptingImp: Bool = false {
		willSet {
			_ = x$(newValue)
		}
	}
}
