//
//  PreferencesWindowController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 06.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

var currentPreferencesWindowController: NSWindowController?

class PreferencesWindowController : NSWindowController {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		assert(nil == currentPreferencesWindowController)
		currentPreferencesWindowController = self
	}
	
	override func windowDidLoad() {
		
		super.windowDidLoad()
		
		let notificationCenter = NotificationCenter.default
		var observer: NSObjectProtocol?
		observer = notificationCenter.addObserver(forName: NSWindow.willCloseNotification, object: window!, queue: nil, using: { _ in
			
			notificationCenter.removeObserver(observer!)
			currentPreferencesWindowController = nil
		})
	}
	
	deinit {
		assert(nil == currentPreferencesWindowController)
	}
}
