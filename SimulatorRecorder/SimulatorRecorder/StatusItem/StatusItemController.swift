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
	var keyEquivalent: String { get }
	var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }
}

extension Bundle {
	open func loadNibNamed(_ nibName: NSNib.Name, owner: Any?, topLevelObjects: AutoreleasingUnsafeMutablePointer<NSArray?>? = nil, orThrow error: Error) throws {
		if !loadNibNamed(nibName, owner: owner, topLevelObjects: topLevelObjects) {
			throw error
		}
	}
}

enum AppError : Error {
	case nibLoadingError
}

let nibLoadingError = AppError.nibLoadingError

class StatusItemController : NSObject, NSMenuDelegate {
	var dataSource: StatusItemControllerDataSource!
	
	@IBOutlet var statusMenu: NSMenu!

	lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength) … {
		$0.menu = statusMenu
		guard let button = $0.button else {
			assert(false)
			return
		}
		button.image = #imageLiteral(resourceName: "MenuIcon")
	}
	
	func activate() {
		let bundle = Bundle(for: type(of: self))
		try! bundle.loadNibNamed(NSNib.Name("StatusItem"), owner: self, topLevelObjects: nil, orThrow: nibLoadingError)
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
