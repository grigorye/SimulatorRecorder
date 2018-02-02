//
//  NestedBrackets.swift
//  GEBase
//
//  Created by Grigory Entin on 22.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import Foundation

extension String {
	/// Returns the range of the first occurence of a given closing bracket that is not paired with a given opening bracket.
	public func rangeOfClosingBracket(_ closingBracket: String, openingBracket: String, followedBy: String? = nil, range searchRange: Range<Index>? = nil) -> Range<String.Index>? {
		guard let openingBracketRange = range(of: openingBracket, range: searchRange) else {
			return range(of: closingBracket, range: searchRange)
		}
		guard let closingBracketRange = range(of: closingBracket, range: searchRange) else {
			return nil
		}
		if openingBracketRange.lowerBound > closingBracketRange.lowerBound {
			if let followedBy = followedBy {
				if self[closingBracketRange.upperBound...].hasPrefix(followedBy) {
					return closingBracketRange
				}
			}
			else {
				return closingBracketRange
			}
		}
		let upperBound = searchRange?.upperBound ?? self.endIndex
		let tailIndex = openingBracketRange.upperBound
		let ignoredClosingBracketRange = rangeOfClosingBracket(closingBracket, openingBracket: openingBracket, range: tailIndex..<upperBound)!
		let remainingStringIndex = ignoredClosingBracketRange.upperBound
		return rangeOfClosingBracket(closingBracket, openingBracket: openingBracket, range: remainingStringIndex..<upperBound)
	}
}
