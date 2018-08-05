//
//  main.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 03.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import GEFoundation
import GETracing
import AppKit

GETracing.logRecord = GEFoundation.defaultLogger

x$(CommandLine.arguments)

ValueTransformer.setValueTransformer(
    PathFromFilePathOrURLTransformer(),
    forName: .pathFromFilePathOrURLTransformerName
)

ValueTransformer.setValueTransformer(
    RecordingNameFormatTransformer(),
    forName: .recordingNameFormatTransformerName
)

if let defaultsRegistrationDictionary = defaultsRegistrationDictionary {
	
	UserDefaults.standard.register(defaults: defaultsRegistrationDictionary)
}

_ = NSApplicationMain(
	CommandLine.argc,
	CommandLine.unsafeArgv
)
