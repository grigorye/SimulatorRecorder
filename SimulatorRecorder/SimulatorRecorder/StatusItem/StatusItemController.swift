//
//  StatusItemController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 06.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

let statusItemController = StatusItemController()

class StatusItemController : NSObject {
	
	@IBOutlet var statusMenu: NSMenu!

	@objc func statusItemAction() {
		
	}
	
	lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength) … {
		
		$0.menu = statusMenu
		guard let button = $0.button else {
			assert(false)
			return
		}
		button.action = #selector(statusItemAction)
		button.image = #imageLiteral(resourceName: "StartRecording")
	}
	
	func activate() {
		
		let bundle = Bundle(for: type(of: self))
		guard bundle.loadNibNamed(NSNib.Name("StatusItem"), owner: self, topLevelObjects: nil) else {
			
			assert(false)
			return
		}
		_ = statusItem
	}
}
