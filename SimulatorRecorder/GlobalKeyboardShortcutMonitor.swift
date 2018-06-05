//
//  GlobalKeyboardShortcutMonitor.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 08.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

class GlobalKeyboardShortcutMonitor {
	var modifierFlags: NSEvent.ModifierFlags = []
	var keyCode: UInt16? /* device-independent key number */
	var shortcutHandler: (() -> Void)?

	func activate() {
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
			self.keyDown($0)
		}
	}
	
	private func keyDown(_ event: NSEvent) {
		guard event.modifierFlags.intersection([.command, .shift, .option, .control]) == modifierFlags else {
			return
		}
		guard event.keyCode == keyCode else {
			return
		}
		shortcutHandler?()
	}
}
