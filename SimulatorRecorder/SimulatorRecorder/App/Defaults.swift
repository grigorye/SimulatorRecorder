//
//  Defaults.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 10/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit.NSEvent
import Carbon.HIToolbox.Events

let defaultShortcutKeyCode: UInt16 = .init(kVK_ANSI_5)
let defaultShortcutModifierFlags: NSEvent.ModifierFlags = [.command, .shift]
