//
//  StatusItemController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 06.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

extension NSNib.Name {
	
	static let statusItem = "StatusItem"
}

let statusItemController = StatusItemController()

class ObservableIcon : NSObject {
	
	@objc dynamic var value: NSImage? { return nil }
}

protocol StatusItemControllerDataSource {
	
	var stopRecordingEnabled: Bool { get }
	var startRecordingEnabled: Bool { get }
	var keyEquivalent: String { get }
	var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }
	var observableIcon: ObservableIcon { get }
}

class StatusItemController : NSObject, NSMenuDelegate {
	
	var dataSource: StatusItemControllerDataSource!
	
	@IBOutlet var statusMenu: NSMenu!

	lazy var statusItem: NSStatusItem = {
		NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength) … {
			$0.menu = statusMenu
		}
	}()

	func activate() {
		let bundle = Bundle(for: type(of: self))
		try! throwify(bundle.loadNibNamed(.statusItem, owner: self, topLevelObjects: nil))
		_ = statusItem
		_ = statusItemIconBinding
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
	
	// MARK: -
	
	private lazy var statusItemIconBinding: Any = {
		dataSource.observableIcon.observe(\.value, options: .initial, changeHandler: { [weak self] (observableIcon, _)  in
			self?.statusItem.button!.image = observableIcon.value
		})
	}()
}
