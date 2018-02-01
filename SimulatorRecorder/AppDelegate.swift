//
//  AppDelegate.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

@objc protocol GlobalActionResponder {
	
	func toggleRecording(_ sender: Any)
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func keyDown(_ event: NSEvent) {
		
		guard event.modifierFlags.intersection([.command, .shift, .option, .control]) == [.command, .shift] else {
			
			return
		}
		guard event.keyCode == kVK_ANSI_6 else {
			
			return
		}
		
		let application = NSApplication.shared
		
		guard let viewController = application.windows.first?.contentViewController as? ViewController else {
			
			assert(false)
			return
		}
		
		viewController.toggleRecording(self)
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() : true] as CFDictionary)
		
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
			
			self.keyDown($0)
		}
	}
}
