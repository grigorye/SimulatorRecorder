//
//  ObservableRecordingState.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 19/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSObject

@objc public class ObservableRecordingState : NSObject {
	@objc dynamic var interrupting: Bool { return false }
	@objc dynamic var recording: Bool { return false }
	@objc dynamic var readyToRecord: Bool { return false }
}
