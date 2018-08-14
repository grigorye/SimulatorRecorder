//
//  StatusItemController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 06.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

extension NSNib.Name {
	static let statusItem = NSNib.Name(rawValue: "StatusItem")
}

let statusItemController = StatusItemController()

protocol StatusItemControllerDataSource {
	var stopRecordingEnabled: Bool { get }
	var startRecordingEnabled: Bool { get }
	var keyEquivalent: String { get }
	var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }
}

class StatusItemController : NSObject, NSMenuDelegate {
	var dataSource: StatusItemControllerDataSource!
	
	@IBOutlet var statusMenu: NSMenu!

	lazy var statusItem: NSStatusItem = {
		NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength) … {
			$0.menu = statusMenu
			guard let button = $0.button else {
				assert(false)
				return
			}
			button.image = #imageLiteral(resourceName: "MenuIcon")
		}
	}()

	func activate() {
		let bundle = Bundle(for: type(of: self))
		try! throwify(bundle.loadNibNamed(.statusItem, owner: self, topLevelObjects: nil))
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
			$0.keyEquivalent = dataSource.keyEquivalent
			$0.keyEquivalentModifierMask = dataSource.keyEquivalentModifierMask
		}
		let stopRecordingEnabled = dataSource.stopRecordingEnabled
		stopRecordingMenuItem … {
			$0.isHidden = !stopRecordingEnabled
			$0.isEnabled = stopRecordingEnabled
			$0.keyEquivalent = dataSource.keyEquivalent
			$0.keyEquivalentModifierMask = dataSource.keyEquivalentModifierMask
		}
	}
}
