//
//  URLSessionTaskGeneratorErrorObjCBridgingTests.swift
//  GEBase
//
//  Created by Grigory Entin on 16.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

@testable import GEFoundation
import XCTest

class URLSessionTaskGeneratorErrorObjCBridgingTests: XCTestCase {
	
	func testArchiving() {
		let httpResponse = HTTPURLResponse(url: URL(fileURLWithPath: "/"), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
		let error = URLSessionTaskGeneratorError.UnexpectedHTTPResponseStatus(httpResponse: httpResponse)
		let nsobject = error as NSObject
		let archivedData = NSKeyedArchiver.archivedData(withRootObject: nsobject)
		XCTAssertNotNil(archivedData)
		let unarchivedNSObject = NSKeyedUnarchiver.unarchiveObject(with: archivedData)
		let unarchivedError = unarchivedNSObject as! URLSessionTaskGeneratorError
		_ = unarchivedError
	}
	
}
