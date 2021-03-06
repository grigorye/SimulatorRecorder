//
//  RecordingNameTokenObject.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 02.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

class RecordingNameTokenObject : NSObject {
	
	let value: RecordingNameToken
	
	public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
		
		guard type == .filenameToken else {
			assert(false, "\(type)")
			return nil
		}
		guard let data = propertyList as? Data else {
			assert(false)
			return nil
		}
		guard let string = String(data: data, encoding: .utf8) else {
			assert(false)
			return nil
		}
		guard let value = RecordingNameToken(rawValue: string) else {
			return nil
		}
		self.value = value
	}
	
	init(_ value: RecordingNameToken) {
		self.value = value
		super.init()
	}
}

extension NSPasteboard.PasteboardType {
	
	static var filenameToken: NSPasteboard.PasteboardType {
		return NSPasteboard.PasteboardType("com.grigorye.filenameToken")
	}
}

extension RecordingNameTokenObject : NSPasteboardReading {
	
	static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
		
		return [.filenameToken, .string]
	}
}

extension RecordingNameTokenObject : NSPasteboardWriting {
	
	func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
		
		return [.filenameToken, .string]
	}
	
	func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
		
		switch type {
		case .string:
			return value.rawValue
		case .filenameToken:
			return value.rawValue
		default:
			assert(false)
			return nil
		}
	}
}
