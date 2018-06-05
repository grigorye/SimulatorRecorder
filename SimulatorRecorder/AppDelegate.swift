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
	
	func verifyTrustedAccessibility() {
		
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : true] as CFDictionary
		_ = x$(AXIsProcessTrustedWithOptions(options))
	}
	
	func globalKeyboardShortcutReceived() {
		
		let application = NSApplication.shared
		
		guard let viewController = application.windows.first?.contentViewController as? ViewController else {
			
			assert(false)
			return
		}
		
		x$(viewController).toggleRecording(self)
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		verifyTrustedAccessibility()
		
		let keyboardShortcutMonitor = GlobalKeyboardShortcutMonitor() … {
			$0.modifierFlags = [.command, .shift]
			$0.keyCode = UInt16(kVK_ANSI_6)
			$0.shortcutHandler = {
				x$(self.globalKeyboardShortcutReceived())
			}
		}
		keyboardShortcutMonitor.activate()
		
		statusItemController.activate()
	}
}
