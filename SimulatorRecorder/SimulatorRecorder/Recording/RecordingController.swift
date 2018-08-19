//
//  RecordingController.swift
//  SimulatorRecorder
//
//  Created by Entin, Grigorii on 18/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit
import Foundation

@objc class RecordingController : NSObject {
	
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
	
	private var deviceRecorders: [DeviceRecorder] {
		set {
			recordingStateImp.deviceRecorders = newValue
		}
		get {
			return recordingStateImp.deviceRecorders
		}
	}
	
	private var recordingInitiated: Bool {
		set {
			recordingStateImp.recordingInitiated = newValue
		}
		get {
			return recordingStateImp.recordingInitiated
		}
	}
	
	private var recording: Bool {
		return recordingStateImp.recording
	}

	// MARK: -
	
	private let recordingStateImp = RecordingControllerRecordingState()
	
	// MARK: -
	
	var recordingState: ObservableRecordingState {
		return recordingStateImp
	}
}
