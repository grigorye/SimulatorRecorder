//
//  RecordingNamingPreferencesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 02.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class RecordingNamingPreferencesViewController : NSViewController {
	
    @IBOutlet var userDefaultsController: NSUserDefaultsController!
    @IBOutlet var recordingNameField: NSTokenField!
	@IBOutlet var recordingNameTokenGridView: NSGridView!
	
	let recordingNameFieldDelegate = RecordingNameFieldDelegate()

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		recordingNameField … {
			
			$0.delegate = recordingNameFieldDelegate
		}

		recordingNameTokenGridView … {
			$0.rowSpacing = 10
			$0.columnSpacing = 10
		}
		
		for token in knownRecordingNameTokens {
			recordingNameTokenGridView.addRow(with: [
				
				NSTextField(labelWithString: token.title),
				NSTokenField() … {
					$0.isBordered = false
					$0.isSelectable = true
					$0.isEditable = false
					$0.drawsBackground = false
					$0.objectValue = [token].map(RecordingNameTokenObject.init)
					$0.delegate = recordingNameFieldDelegate
				}
			])
		}
	}
}
