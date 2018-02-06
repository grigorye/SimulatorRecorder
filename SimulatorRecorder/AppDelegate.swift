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

extension NSStoryboard.Name {

	static let preferences = NSStoryboard.Name(rawValue: "Preferences")
}

class AppDelegate: NSObject, NSApplicationDelegate {
	
	func instantiatePreferensesWindowController() -> NSWindowController {
		
		let windowController = NSStoryboard(name: .preferences, bundle: nil).instantiateInitialController() as! NSWindowController
		
		return windowController
	}
	
	@IBAction func showPreferences(_ sender: Any) {
		
		let preferencesWindowController = currentPreferencesWindowController ?? instantiatePreferensesWindowController()
		
		preferencesWindowController.showWindow(sender)
	}
	
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
		
		x$(viewController).toggleRecording(self)
	}
	
	func verifyTrustedAccessibility() {
		
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : true] as CFDictionary
		_ = x$(AXIsProcessTrustedWithOptions(options))
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		verifyTrustedAccessibility()
		
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
			
			self.keyDown($0)
		}
		
		statusItemController.activate()
	}
}
