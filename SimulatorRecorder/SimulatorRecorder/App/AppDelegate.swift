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

class AppDelegate: NSResponder, NSApplicationDelegate {
	
	// MARK: -
	
	func instantiatePreferensesWindowController() -> NSWindowController {
		
		let windowController = NSStoryboard(name: .preferences, bundle: nil).instantiateInitialController() as! NSWindowController
		
		return windowController
	}
	
	// MARK: -
	
	@IBAction func showPreferences(_ sender: Any) {
		
		let preferencesWindowController = currentPreferencesWindowController ?? instantiatePreferensesWindowController()
		
		preferencesWindowController.showWindow(sender)
	}
	
	@IBAction func startRecording(_: Any) {
		recordingInteractor.toggleRecording(self)
	}
	
	@IBAction func stopRecording(_: Any) {
		recordingInteractor.toggleRecording(self)
	}

	func verifyTrustedAccessibility() {
		
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : true] as CFDictionary
		_ = x$(AXIsProcessTrustedWithOptions(options))
	}
	
	func globalKeyboardShortcutReceived() {
		
		recordingInteractor.toggleRecording(self)
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		NSApplication.shared.nextResponder = recordingInteractor
		
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
			self.globalKeyboardShortcutReceived()
		})
		#endif
		
		statusItemController.activate()
		statusItemController.dataSource = AppStatusItemControllerSource()
	}
}

class AppStatusItemControllerSource : StatusItemControllerDataSource {
	var stopRecordingEnabled: Bool {
		return recordingInteractor.recordingController.recording
	}
	
	var startRecordingEnabled: Bool {
		return recordingInteractor.recordingController.readyToRecord
	}
}
