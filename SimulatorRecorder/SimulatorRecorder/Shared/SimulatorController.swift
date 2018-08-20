//
//  SimulatorController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 17/08/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

struct SimulatorDevicesResponse : Decodable {
	let devices: [OSVersion:[DeviceInfo]]
	
	typealias OSVersion = String
	struct DeviceInfo : Decodable {
		let state: State
		let availability: Availability
		let name: String
		let udid: String
		
		enum State: String, Decodable {
			case shutdown = "Shutdown"
			case booted = "Booted"
			case shuttingDown = "Shutting Down"
		}
		enum Availability: String, Decodable {
			case available = "(available)"
			case unavailableRunTimeProfileNotFound = " (unavailable, runtime profile not found)"
			case unavailableDeviceTypeNotSupportedByRuntime = " (unavailable, device type not supported by runtime)"
		}
	}
}

struct SimulatorDeviceInfo {
	let state: State
	let availability: Availability
	let name: String
	let udid: String
	let osVersion: String

	typealias State = SimulatorDevicesResponse.DeviceInfo.State
	typealias Availability = SimulatorDevicesResponse.DeviceInfo.Availability
}

class SimulatorController {
	let developerDirURL: URL
	
	static func runningSimulatorsBundleURLs() -> [URL] {
		let runningSimulators = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iphonesimulator")
		return runningSimulators.map { $0.bundleURL! }
	}
	
	static func developerDirURL(fromSimulatorBundleURL bundleURL: URL) -> URL {
		let sampleSimulatorPath
			= "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
		let sampleDeveloperDir
			= "/Applications/Xcode.app/Contents/Developer"
		assert(sampleSimulatorPath.hasPrefix(sampleDeveloperDir))
		let suffixLength = sampleSimulatorPath.count - sampleDeveloperDir.count
		let bundlePath = bundleURL.path
		let developerDirEndIndex = bundlePath.index(bundlePath.endIndex, offsetBy: -suffixLength)
		let developerDir = String(bundlePath[..<developerDirEndIndex])
		return .init(fileURLWithPath: developerDir)
	}
	
	static func defaultDeveloperDirURL() -> URL {
		let runningSimulatorsBundleURLs = SimulatorController.runningSimulatorsBundleURLs()
		guard let runningSimulatorBundleURL = runningSimulatorsBundleURLs.last else {
			return .init(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer")
		}
		assert(runningSimulatorsBundleURLs.count <= 1)
		return developerDirURL(fromSimulatorBundleURL: runningSimulatorBundleURL)
	}
	
	init(developerDirURL: URL = defaultDeveloperDirURL()) {
		self.developerDirURL = developerDirURL
	}
	
	func devicesResponse() throws -> SimulatorDevicesResponse {
		let pipe = Pipe()
		let process = Process() ≈ {
			$0.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
			let extraEnvironment = [
				"DEVELOPER_DIR": developerDirURL.path
			]
			$0.environment = ProcessInfo().environment.merging(extraEnvironment, uniquingKeysWith: { $1 })
			$0.arguments = [
				"simctl",
				"list",
				"-j",
				"devices"
			]
			$0.standardOutput = pipe
		}
		process.launch()
		process.waitUntilExit()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let devicesResponse = try JSONDecoder().decode(SimulatorDevicesResponse.self, from: data)
		return devicesResponse
	}
	
	func devices() throws -> [SimulatorDeviceInfo] {
		let devicesResponse = try self.devicesResponse()
		
		let devices = devicesResponse.devices.flatMap { (osVersion, responses) -> [SimulatorDeviceInfo] in
			responses.map {
				SimulatorDeviceInfo(state: $0.state, availability: $0.availability, name: $0.name, udid: $0.udid, osVersion: osVersion)
			}
		}
		return devices
	}
}
