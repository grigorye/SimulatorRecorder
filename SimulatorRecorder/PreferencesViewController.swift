//
//  PreferencesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 02.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

private let tokensInPalette: [FilenameToken] = [
	.date,
	.time,
	.version,
	.device
]

class PreferencesViewController : NSViewController {
	
	@IBOutlet var filenameTokenField: NSTokenField!
	@IBOutlet var filenameTokenGridView: NSGridView!
	
	let filenameTokenFieldDelegate = FilenameTokenFieldDelegate()

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		filenameTokenField … {
			
			$0.objectValue = [
				"Recording",
				FilenameTokenObject(.date),
				"at",
				FilenameTokenObject(.time),
				"for",
				FilenameTokenObject(.device),
				"-",
				FilenameTokenObject(.version)
			]
			$0.delegate = filenameTokenFieldDelegate
		}

		filenameTokenGridView … {
			$0.rowSpacing = 10
			$0.columnSpacing = 10
		}
		
		for token in tokensInPalette {
			filenameTokenGridView.addRow(with: [
				NSTextField(labelWithString: token.title),
				NSTokenField() … {
					$0.isBordered = false
					$0.isSelectable = true
					$0.isEditable = false
					$0.drawsBackground = false
					$0.objectValue = [token].map(FilenameTokenObject.init)
					$0.delegate = filenameTokenFieldDelegate
				}
			])
		}
	}
}
