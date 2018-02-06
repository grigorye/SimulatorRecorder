//
//  RecordingNameFormatTransformer.swift
//  SimulatorRecorder
//
//  Created by Grigorii Entin on 06/02/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

extension NSValueTransformerName {
    
    static let recordingNameFormatTransformerName = NSValueTransformerName(rawValue: "RecordingNameFormat")
}

class RecordingNameFormatTransformer : ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let shellScriptFormat = value as? String else {
            
            return value
        }
        
        let stringComponents = shellScriptFormat.components(separatedBy: " ")
        
        let components: [Any] = stringComponents.map {
            for i in knownRecordingNameTokens {
                if $0 == i.shellComponent {
                    return RecordingNameTokenObject(i)
                }
            }
            return $0
        }
        return components
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        switch value {
        case nil:
            return nil
        case let components as [Any]:
            return components.map {
                switch $0 {
                case let tokenObject as RecordingNameTokenObject:
                    return tokenObject.value.shellComponent
                case let string as String:
                    return string
                default:
                    assert(false)
                    return ""
                }
            }.joined(separator: " ")
        case let path as String:
            return path
        default:
            assert(false)
            return value
        }
    }
}
