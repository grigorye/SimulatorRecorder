//
//  ErrorTracking.swift
//  GEFoundation
//
//  Created by Grigorii Entin on 06/12/2017.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import GETracing
import Foundation

private func defaultErrorTracker(error: Error) {
    
    _ = x$(error)
}

public var errorTrackers: [(Error) -> ()] = [defaultErrorTracker]

public func trackError(_ error: Error) {
    
    for errorTracker in errorTrackers {
        
        errorTracker(error)
    }
}
