//
//  PreferencesPaneViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 19/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

class PreferencesPaneViewController : NSViewController {
	@IBOutlet var userDefaultsController: NSUserDefaultsController!
	
	func resetDefaults() {
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		DispatchQueue.main.async {
			x$(self.view.window?.makeFirstResponder(self))
		}
	}
	
	@IBAction func resetToDefaults(_ sender: Any) {
		self.view.window?.makeFirstResponder(nil)
		self.resetDefaults()
		self.view.window?.makeFirstResponder(self)
	}
}
