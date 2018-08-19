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
	
	func showPreferencesWindow() {
		let preferencesWindowController = currentPreferencesWindowController ?? instantiatePreferensesWindowController()
		
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
		
		statusItemController.dataSource = AppStatusItemControllerSource()
		statusItemController.activate()
	}
}

extension TypedUserDefaults {
	@NSManaged var toggleRecordingShortcutData: Data?
}

let defaultsKey = #keyPath(TypedUserDefaults.toggleRecordingShortcutData)

class AppStatusItemControllerSource : StatusItemControllerDataSource {
	
	var shortcut: MASShortcut? {
		guard let shortcutData = defaults.toggleRecordingShortcutData else {
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
		return recordingInteractor.recordingState.recording
	}
	
	var startRecordingEnabled: Bool {
		return recordingInteractor.recordingState.readyToRecord
	}
	
	var observableIcon: ObservableIcon = AppStatusIcon() … {
		$0.recordingState = recordingInteractor.recordingState
	}
}

class AppStatusIcon : ObservableIcon {
	@objc dynamic var recordingState: ObservableRecordingState!

	@objc dynamic class var keyPathsForValuesAffectingValue: Set<String> {
		return [#keyPath(recordingState.recording)]
	}
	
	@objc override dynamic var value: NSImage? {
		return recordingState.recording ? #imageLiteral(resourceName: "MenuIconRecording") : #imageLiteral(resourceName: "MenuIcon")
	}
}
