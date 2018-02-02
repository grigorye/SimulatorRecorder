//
//  ProgressEnabledURLSessionTaskGenerator.swift
//  GEBase
//
//  Created by Grigory Entin on 04/03/15.
//  Copyright (c) 2015 Grigory Entin. All rights reserved.
//

import Foundation

public let progressEnabledURLSessionTaskGenerator = ProgressEnabledURLSessionTaskGenerator()

public enum URLSessionTaskGeneratorError: Error {
	case UnexpectedHTTPResponseStatus(httpResponse: HTTPURLResponse)
}

public class ProgressEnabledURLSessionTaskGenerator: NSObject {
	let dispatchQueue = DispatchQueue.main
	@objc public dynamic var progresses = [Progress]()
	let session = URLSession(configuration: URLSessionConfiguration.default)
	// MARK: -
	public typealias HTTPDataTaskCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
	public func dataTask(for request: URLRequest, completionHandler: @escaping HTTPDataTaskCompletionHandler) -> URLSessionDataTask {
		let progress = Progress(totalUnitCount: 1)
		progress.becomeCurrent(withPendingUnitCount: 1)
		x$(request)
		x$(request.allHTTPHeaderFields)
		let sessionTask = session.progressEnabledDataTask(with: request) { data, response, error in
			self.dispatchQueue.async {
				self.progresses.remove(at: self.progresses.index(of: progress)!)
			}
			let httpResponse = response as! HTTPURLResponse?
			do {
				guard nil == error else {
					throw error!
				}
				let httpResponse = httpResponse!
				guard httpResponse.statusCode == 200 else {
					if let data = data {
						let httpStatusResponseBody = String(data: data, encoding: .utf8)
						x$(httpStatusResponseBody)
					}
					throw URLSessionTaskGeneratorError.UnexpectedHTTPResponseStatus(httpResponse: httpResponse)
				}
				completionHandler(data, httpResponse, nil)
			} catch {
				completionHandler(nil, httpResponse, error)
			}
		}
		progress.resignCurrent()
		self.dispatchQueue.async {
			self.progresses.append(progress)
		}
		return sessionTask
	}
	public typealias TextTaskCompletionHandler = (String?, Error?) -> Void
	public func textTask(for request: URLRequest, completionHandler: @escaping TextTaskCompletionHandler) -> URLSessionDataTask? {
		enum TextTaskError: Error {
			case DataDoesNotMatchTextEncoding(data: Data, encoding: String.Encoding)
		}
		return dataTask(for: request) { data, httpResponse, error in
			do {
				if let error = error {
					throw error
				}
				let httpResponse = httpResponse!
				let encoding: String.Encoding = {
					if let textEncodingName = httpResponse.textEncodingName {
						return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(textEncodingName as CFString?)))
					}
					else {
						return String.Encoding.utf8
					}
				}()
				let data = data!
				guard let text = String(data: data, encoding: encoding) else {
					throw TextTaskError.DataDoesNotMatchTextEncoding(data: data, encoding: encoding)
				}
				completionHandler(text, nil)
			} catch {
				completionHandler(nil, x$(error))
			}
		}
	}
}
