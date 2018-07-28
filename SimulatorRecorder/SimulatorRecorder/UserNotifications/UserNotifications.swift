//
//  UserNotifications.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 21/07/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

enum UserEvent : String {
	case startedRecording
	case recordingCompleted
}

class UserNotificationCenterDelegate : NSObject, NSUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		return true
	}

	func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
		_ = ()
	}
}

let userNotificationCenterDelegate = UserNotificationCenterDelegate() ≈ {
	_ = $0
}

let userNotificationCenter = NSUserNotificationCenter.default ≈ {
	$0.delegate = userNotificationCenterDelegate
}

func sendUserNotification(for event: UserEvent) {
	let notification = NSUserNotification() ≈ {
		$0.identifier = event.rawValue
		$0.title = event.rawValue
		$0.subtitle = "subtitle"
		$0.informativeText = "informativeText"
		$0.soundName = NSUserNotificationDefaultSoundName
	}
	_ = userNotificationCenterDelegate
	userNotificationCenter.scheduleNotification(notification)
}
