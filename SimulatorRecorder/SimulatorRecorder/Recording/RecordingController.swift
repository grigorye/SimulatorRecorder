//
//  RecordingController.swift
//  SimulatorRecorder
//
//  Created by Entin, Grigorii on 18/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit
import Foundation

@objc public class ObservableRecordingState : NSObject {
	@objc dynamic var interrupting: Bool { return false }
	@objc dynamic var recording: Bool { return false }
	@objc dynamic var readyToRecord: Bool { return false }
}

@objc class RecordingController : ObservableRecordingState {
	
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
	
	@objc dynamic var deviceRecordersController: NSArrayController
	@objc dynamic var deviceRecorders: [DeviceRecorder] = [] {
		didSet {
			deviceRecordersController.content = deviceRecorders
		}
	}

	// MARK: -
	
	@objc private dynamic var recordingInitiated: Bool = false
	
	// MARK: -
	
	@objc override dynamic var recording: Bool {
		return self.anyDeviceRecording || recordingInitiated
	}
	@objc private dynamic class var keyPathsForValuesAffectingRecording: Set<String> {
		return [
			#keyPath(anyDeviceRecording),
			#keyPath(recordingInitiated)
		]
	}
	
	// MARK: -
	
	@objc override dynamic var readyToRecord: Bool {
		return self.everyDeviceReadyToRecord && !recordingInitiated
	}
	@objc private dynamic class var keyPathsForValuesAffectingReadyToRecord: Set<String> {
		return [
			#keyPath(everyDeviceReadyToRecord),
			#keyPath(recordingInitiated)
		]
	}
	
	// MARK: -
	
	@objc private dynamic var anyDeviceRecording: Bool {
		return observableAnyDeviceRecording.value
	}
	@objc private dynamic class var keyPathsForValuesAffectingAnyDeviceRecording: Set<String> {
		return [#keyPath(observableAnyDeviceRecording.value)]
	}
	@objc private dynamic var observableAnyDeviceRecording: ObservableBool
	
	// MARK: -
	
	@objc private dynamic var everyDeviceReadyToRecord: Bool {
		return observableEveryDeviceReadyToRecord.value
	}
	@objc private dynamic class var keyPathsForValuesAffectingEveryDeviceReadyToRecord: Set<String> {
		return [#keyPath(observableEveryDeviceReadyToRecord.value)]
	}
	@objc private dynamic var observableEveryDeviceReadyToRecord: ObservableBool
	
	// MARK: -
	
	@objc override dynamic var interrupting: Bool {
		return observableInterrupting.value
	}
	@objc private dynamic class var keyPathsForValuesAffectingInterrupting: Set<String> {
		return [#keyPath(observableInterrupting.value)]
	}
	@objc private dynamic var observableInterrupting: ObservableBool
	
	// MARK: -
	
	override init() {
		self.deviceRecordersController = .init()
		self.observableInterrupting = ObservableArrayPredicateValue(
			self.deviceRecordersController,
			keyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.interrupting),
			nullPlaceholder: false
		)
		self.observableEveryDeviceReadyToRecord = ObservableArrayPredicateValue(
			self.deviceRecordersController,
			keyPath: arrangedObjectsKeyPath(.min, \DeviceRecorder.readyToRecord),
			nullPlaceholder: true
		)
		self.observableAnyDeviceRecording = ObservableArrayPredicateValue(
			self.deviceRecordersController,
			keyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.recording),
			nullPlaceholder: false
		)
	}
}
