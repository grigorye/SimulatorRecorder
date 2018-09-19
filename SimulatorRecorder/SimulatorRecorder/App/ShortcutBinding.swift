//
//  ShortcutBinding.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 19/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import MASShortcut
import Foundation

private let defaultShortcut: MASShortcut = MASShortcut(
	keyCode: .init(defaultShortcutKeyCode),
	modifierFlags: defaultShortcutModifierFlags.rawValue
)

private let defaultsKey = #keyPath(TypedUserDefaults.toggleRecordingShortcutData)

private let shortcutBinder = MASShortcutBinder.shared()! … {
	let defaultShortcuts = [defaultsKey: defaultShortcut]
	$0.registerDefaultShortcuts(defaultShortcuts)
}

class ShortcutBinding : NSObject {
	
	let globalKeyboardShortcutReceived: () -> Void
	
	var enabled: Bool = false {
		didSet {
			if x$(enabled) {
				shortcutBinder.bindShortcut(withDefaultsKey: defaultsKey) {
					self.globalKeyboardShortcutReceived()
				}
			} else {
				shortcutBinder.breakBinding(withDefaultsKey: defaultsKey)
			}
		}
	}
	
	init(globalKeyboardShortcutReceived: @escaping () -> Void) {
		self.globalKeyboardShortcutReceived = globalKeyboardShortcutReceived
	}
}
