//
//  RecordingControllerRecordingState.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 19/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

class RecordingControllerRecordingState : ObservableRecordingState {
	
	var deviceRecorders: [DeviceRecorder] = [] {
		didSet {
			deviceRecordersArrayController.content = deviceRecorders
		}
	}
	
	private let deviceRecordersArrayController = NSArrayController()
	
	// MARK: -
	
	@objc dynamic var recordingInitiated: Bool = false
	
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
		self.observableInterrupting = ObservableArrayPredicateValue(
			self.deviceRecordersArrayController,
			keyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.interrupting),
			nullPlaceholder: false
		)
		self.observableEveryDeviceReadyToRecord = ObservableArrayPredicateValue(
			self.deviceRecordersArrayController,
			keyPath: arrangedObjectsKeyPath(.min, \DeviceRecorder.readyToRecord),
			nullPlaceholder: true
		)
		self.observableAnyDeviceRecording = ObservableArrayPredicateValue(
			self.deviceRecordersArrayController,
			keyPath: arrangedObjectsKeyPath(.max, \DeviceRecorder.recording),
			nullPlaceholder: false
		)
	}
}
