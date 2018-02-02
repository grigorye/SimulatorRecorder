//
//  FlattenableTests.swift
//  GEFoundation
//
//  Created by Grigory Entin on 10.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import XCTest
@testable import GEFoundation

class FlattenableTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	enum Foo {
		case bar
	}
	
	func testExample() {
		let d = ["baz" : Foo.bar]
		let flattenableD = d as Flattenable
		let flattenedD = flattenableD.flattenWithPrefix(nil)
		XCTAssertEqual("\(d)", "\(flattenedD)", "")
	}
	
}
