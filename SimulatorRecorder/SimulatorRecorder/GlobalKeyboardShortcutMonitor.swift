//
//  GlobalKeyboardShortcutMonitor.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 08.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

extension NSEvent {
    
    func matches(_ shortcut: KeyboardShortcut) -> Bool {
        guard dump(modifierFlags).intersection([.command, .shift, .option, .control]) == shortcut.modifierFlags else {
            return false
        }
        guard keyCode == shortcut.keyCode else {
            return false
        }
        return true
    }
}

struct KeyboardShortcut {
    
    let modifierFlags: NSEvent.ModifierFlags
    let keyCode: Int
}

class GlobalKeyboardShortcutMonitor {
    
    let shortcut: KeyboardShortcut
    typealias ShortcutHandler = () -> Void
	let shortcutHandler: ShortcutHandler
    
    init(_ shortcut: KeyboardShortcut, handler: @escaping ShortcutHandler) {
        self.shortcut = shortcut
        self.shortcutHandler = handler
    }

	func activate() {
        dump(shortcut)
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
			self.keyDown($0)
		}
	}
	
	private func keyDown(_ event: NSEvent) {
        dump(event.keyCode)
        dump(event.modifierFlags)
        guard event.matches(shortcut) else {
            return
        }
		shortcutHandler()
	}
}
