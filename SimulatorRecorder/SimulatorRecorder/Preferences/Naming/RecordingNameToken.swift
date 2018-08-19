//
//  RecordingNameToken.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 03.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

let knownRecordingNameTokens: [RecordingNameToken] = [
    .date,
    .time,
    .version,
    .device
]

enum RecordingNameToken : String, RawRepresentable {
	case date
	case time
	case version
	case device
}

private let now = Date()

extension RecordingNameToken {
    var shellComponent: String {
        
        switch self {
            
        case .date:
            return "${date:?}"
        case .time:
            return "${time:?}"
        case .device:
            return "${device:?}"
        case .version:
            return "${version:?}"
        }
    }
    
	var title: String {
		switch self {
		case .date:
			return NSLocalizedString("Date", comment: "")
		case .time:
			return NSLocalizedString("Time", comment: "")
		case .device:
			return NSLocalizedString("Device", comment: "")
		case .version:
			return NSLocalizedString("System Version", comment: "")
		}
	}

	var sampleString: String {
		switch self {
		case .date:
			return DateFormatter.localizedString(from: now, dateStyle: .short, timeStyle: .none)
        case .time:
            return DateFormatter.localizedString(from: now, dateStyle: .none, timeStyle: .medium)
		case .device:
			return "iPhone SE"
		case .version:
			return "11.2"
		}
	}
}
