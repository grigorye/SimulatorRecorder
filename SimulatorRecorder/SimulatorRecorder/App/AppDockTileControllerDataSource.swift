//
//  AppDockTileControllerDataSource.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 25/09/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

class AppDockTileControllerDataSource : DockTileControllerDataSource {
	
	var observableIcon: ObservableIcon = AppDockTileIcon() … {
		$0.recordingState = recordingInteractor.recordingState
	}
}
