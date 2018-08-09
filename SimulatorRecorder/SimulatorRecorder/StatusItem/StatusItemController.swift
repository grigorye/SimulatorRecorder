//
//  StatusItemController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 06.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

let statusItemController = StatusItemController()

protocol StatusItemControllerDataSource {
	var stopRecordingEnabled: Bool { get }
	var startRecordingEnabled: Bool { get }
}

class StatusItemController : NSObject, NSMenuDelegate {
	
	var dataSource: StatusItemControllerDataSource!
	
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
		button.image = #imageLiteral(resourceName: "MenuIcon")
	}
	
	func activate() {
		
		let bundle = Bundle(for: type(of: self))
		guard bundle.loadNibNamed(NSNib.Name("StatusItem"), owner: self, topLevelObjects: nil) else {
			
			assert(false)
			return
		}
		_ = statusItem
	}
	
	// MARK: - <NSMenuDelegate>
	
	@IBOutlet var startRecordingMenuItem: NSMenuItem!
	@IBOutlet var stopRecordingMenuItem: NSMenuItem!

    public func menuNeedsUpdate(_ menu: NSMenu) {
		let startRecordingEnabled = dataSource.startRecordingEnabled
		startRecordingMenuItem … {
			$0.isHidden = !startRecordingEnabled
			$0.isEnabled = startRecordingEnabled
		}
		let stopRecordingEnabled = dataSource.stopRecordingEnabled
		stopRecordingMenuItem … {
			$0.isHidden = !stopRecordingEnabled
			$0.isEnabled = stopRecordingEnabled
		}
	}
}
