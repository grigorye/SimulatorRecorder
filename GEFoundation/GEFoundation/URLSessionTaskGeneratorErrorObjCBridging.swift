//
//  URLSessionTaskGeneratorErrorObjCBridging.swift
//  GEBase
//
//  Created by Grigory Entin on 16.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

extension URLSessionTaskGeneratorError : CustomNSError {

	public static var errorDomain = "GEBase.URLSessionTaskGeneratorError"

	public var errorCode: Int {
		switch self {
		case .UnexpectedHTTPResponseStatus: return 0
		}
	}
	
	public var errorUserInfo: [String : Any] {
		switch self {
		case .UnexpectedHTTPResponseStatus(let httpResponse):
			return [
				"httpResponse" : httpResponse
			]
		}
	}
}

extension URLSessionTaskGeneratorError : _ObjectiveCBridgeableError {
	public init?(_bridgedNSError error: NSError) {
		guard error.domain == URLSessionTaskGeneratorError.errorDomain else {
			return nil
		}
		switch error.code {
		case 0:
			let httpResponse = error.userInfo["httpResponse"] as! HTTPURLResponse
			self = .UnexpectedHTTPResponseStatus(httpResponse: httpResponse)
		default:
			fatalError()
		}
	}
}
