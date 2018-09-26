//
//  DockTileController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 25/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import AppKit

let dockTileController = DockTileController()

protocol DockTileControllerDataSource : AnyObject {
	
	var observableIcon: ObservableIcon { get }
}

class DockTileController : NSObject {
	
	var dataSource: DockTileControllerDataSource!
	
	func activate() {
		_ = dockTileContentViewBinding
	}
	
	var dockTile: NSDockTile {
		return NSApplication.shared.dockTile
	}
	
	private lazy var dockTileContentViewBinding: Any = {
		dataSource.observableIcon.observe(\.value, options: .initial, changeHandler: { [weak self] (observableIcon, _) in
			guard let self = self else {
				return
			}
			let dockTile = self.dockTile
			dockTile.contentView = observableIcon.value.flatMap {
				NSImageView(image: $0)
			}
			dockTile.display()
		})
	}()
}
