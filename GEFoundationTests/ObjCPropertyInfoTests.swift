//
//  ObjCPropertyInfoTests.swift
//  GEFoundationTests
//
//  Created by Grigorii Entin on 19/08/2017.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import GEFoundation
import XCTest

class ObjCPropertyInfoTests: XCTestCase {
        
    func testObjCDefaultSetterName() {
        XCTAssertEqual("setTestInt:", objCDefaultSetterName(forPropertyName: "testInt"))
    }
    
}
