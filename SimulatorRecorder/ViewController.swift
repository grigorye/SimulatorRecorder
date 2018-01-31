//
//  ViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 31.01.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@objc dynamic var process: Process?
	
	@IBAction func stopRecording(_ sender: Any) {
		
		guard let process = process else {
			
			assert(false)
			return
		}
		
		process.interrupt()
	}
	
	@IBAction func newScreenRecording(_ sender: Any) {
		
		guard let recorderExecutableURL = Bundle(for: type(of: self)).url(forResource: "recordVideo", withExtension: "") else {
			
			assert(false)
			return
		}
		
		do {
			let process = try Process.run(recorderExecutableURL, arguments: []) {
				
				print("\($0.terminationStatus)")
				DispatchQueue.main.async {
					self.process = nil
				}
			}
			self.process = process
			
		} catch {
			
			NSApplication.shared.presentError(error)
		}
	}
}

