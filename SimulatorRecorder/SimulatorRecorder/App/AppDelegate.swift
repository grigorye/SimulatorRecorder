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

		let defaultShortcut = MASShortcut(
			keyCode: .init(defaultShortcutKeyCode),
			modifierFlags: defaultShortcutModifierFlags.rawValue
		)!
		
		MASShortcutBinder.shared()! … {
			let defaultShortcuts = [defaultsKey: defaultShortcut]
			$0.registerDefaultShortcuts(defaultShortcuts)
			$0.bindShortcut(withDefaultsKey: defaultsKey) {
				self.globalKeyboardShortcutReceived()
			}
		}
		
		statusItemController.activate()
		statusItemController.dataSource = AppStatusItemControllerSource()
	}
}

let defaultsKey = "toggleRecordingShortcut"
let defaults = UserDefaults.standard

class AppStatusItemControllerSource : StatusItemControllerDataSource {
	
	var shortcut: MASShortcut? {
		guard let shortcutData = defaults.data(forKey: defaultsKey) else {
			return nil
		}
		let shortcut = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MASShortcut.self, from: shortcutData)
		return shortcut
	}
	
	var keyEquivalent: String {
		return shortcut?.keyCodeString ?? ""
	}
	
	var keyEquivalentModifierMask: NSEvent.ModifierFlags {
		guard let modifierFlags = shortcut?.modifierFlags else {
			return .init()
		}
		return .init(rawValue: modifierFlags)
	}
	
	var stopRecordingEnabled: Bool {
		return recordingInteractor.recordingController.recording
	}
	
	var startRecordingEnabled: Bool {
		return recordingInteractor.recordingController.readyToRecord
	}
}
