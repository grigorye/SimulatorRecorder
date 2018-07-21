//
//  AppDelegate.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox
import MASShortcut

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

		#if false
        let shortcut = KeyboardShortcut(modifierFlags: [.command, .shift], keyCode: kVK_ANSI_7)
        
		let keyboardShortcutMonitor = GlobalKeyboardShortcutMonitor(shortcut) {
            x$(self.globalKeyboardShortcutReceived())
		}
		keyboardShortcutMonitor.activate()
		#else
		let defaultsKey = "globalShortcut"
		MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: defaultsKey, toAction: {
			x$(self.globalKeyboardShortcutReceived())
		})
		#endif
		
		statusItemController.activate()
	}
}
