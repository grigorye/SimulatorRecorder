//
//  FilenamePaletteTokenFieldDelegate.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 02.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class FilenamePaletteTokenFieldDelegate : NSObject, NSTokenFieldDelegate {
	
	func tokenField(_ tokenField: NSTokenField, writeRepresentedObjects objects: [Any], to pboard: NSPasteboard) -> Bool {
		
		pboard.writeObjects(objects as! [NSPasteboardWriting])
		return true
	}
	
	func tokenField(_ tokenField: NSTokenField, readFrom pboard: NSPasteboard) -> [Any]? {
		
		return pboard.readObjects(forClasses: [FilenameTokenObject.self, NSString.self])
	}
	
	func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
		
		switch representedObject {
			
		case let string as String:
			return string
			
		case let filenameTokenObject as FilenameTokenObject:
			return filenameTokenObject.value.sampleString
			
		default:
			assert(false)
			return nil
		}
	}
	
	func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
		
		switch representedObject {
			
		case is String:
			return .none
		case is FilenameTokenObject:
			return .default
		default:
			assert(false)
			return .default
		}
	}
}
