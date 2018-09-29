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

	static let preferences = "Preferences"
}

class AppDelegate: NSResponder, NSApplicationDelegate {
	
	// MARK: -
	
	func instantiatePreferencesWindowController() -> NSWindowController {
		let windowController = NSStoryboard(name: .preferences, bundle: nil).instantiateInitialController() as! NSWindowController
		
		return windowController
	}
	
	func showPreferencesWindow() {
		let preferencesWindowController = currentPreferencesWindowController ?? instantiatePreferencesWindowController()
		
		preferencesWindowController.showWindow(self)
	}
	
	// MARK: -
	
	@IBAction func showPreferences(_ sender: Any) {
		showPreferencesWindow()
		NSApp.activate(ignoringOtherApps: true)
	}
	
	@IBAction func startRecording(_: Any) {
		recordingInteractor.toggleRecording(self)
	}
	
	@IBAction func stopRecording(_: Any) {
		recordingInteractor.toggleRecording(self)
	}
	
	// MARK: -

	func verifyTrustedAccessibility() {
		
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() : true] as CFDictionary
		_ = x$(AXIsProcessTrustedWithOptions(options))
	}
	
	func globalKeyboardShortcutReceived() {
		
		recordingInteractor.toggleRecording(self)
	}
	
	// MARK: - <NSApplicationDelegate>
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		NSApplication.shared.nextResponder = recordingInteractor
		
		verifyTrustedAccessibility()

		shortcutBinding.enabled = true
		
		statusItemController.dataSource = AppStatusItemControllerSource()
		statusItemController.activate()
		
		dockTileController.dataSource = AppDockTileControllerDataSource()
		dockTileController.activate()
	}
}

let shortcutBinding = ShortcutBinding {
	(NSApplication.shared.delegate as! AppDelegate).globalKeyboardShortcutReceived()
}
