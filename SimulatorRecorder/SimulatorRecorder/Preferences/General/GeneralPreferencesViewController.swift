//
//  GeneralPreferencesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 28/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import MASShortcut
import AppKit

extension TypedUserDefaults {
	
	@NSManaged var revealInFinder: NSNumber?
	@NSManaged var recordingsDir: String?
	@NSManaged var compressionEnabled: NSNumber?
}

protocol GeneralPreferencesViewControllerDelegate {
	
	var isRecording: Bool { get set }
}

class ShortcutRecordingInteractor : GeneralPreferencesViewControllerDelegate {
	
	var isRecording: Bool = false {
		didSet {
			shortcutBinding.enabled = !isRecording
		}
	}
}

class GeneralPreferencesViewController : PreferencesPaneViewController {
	
	var delegate: GeneralPreferencesViewControllerDelegate!
	
	override func resetDefaults() {
		defaults.revealInFinder = nil
		defaults.toggleRecordingShortcutData = nil
		defaults.recordingsDir = nil
		defaults.compressionEnabled = nil
	}
	
	@IBOutlet var shortcutView: MASShortcutView! {
		didSet {
			_ = observationForIsRecording
			shortcutView.shortcutValueChange = { (sender) in
				_ = x$(sender?.shortcutValue)
			}
		}
	}
	lazy private var observationForIsRecording = shortcutView.observe(\.isRecording) { [weak self] (_, _) in
		guard let self = self else {
			return
		}
		self.delegate.isRecording = x$(self.shortcutView.isRecording)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = shortcutRecordingInteractor
	}
}

private let shortcutRecordingInteractor = ShortcutRecordingInteractor()
