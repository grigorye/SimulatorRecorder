//
//  NestedBracketsTests.swift
//  GEBase
//
//  Created by Grigory Entin on 22.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

import XCTest

class NestedBracketsTests : XCTestCase {
	let a = "a.b(c))"
	let b = "a.b(c)"
	let c = "a.b(c"
	let d = "a.b)c("
	let i = "0123456"
	func testClosingBracketRangeWithSecondBracket() {
		XCTAssertEqual(
			a.rangeOfClosingBracket(")", openingBracket: "(")!.lowerBound,
			a.index(a.startIndex, offsetBy: 6)
		)
	}
	func testClosingBracketRangeWithNoBracket() {
		XCTAssertEqual(
			b.rangeOfClosingBracket(")", openingBracket: "("),
			nil
		)
	}
	func testClosingBracketRangeWithNoBracketAndOpeningBracket() {
		XCTAssertEqual(
			c.rangeOfClosingBracket(")", openingBracket: "("),
			nil
		)
	}
	func testClosingBracketRangeWithFirstBracketAndOpeningBracket() {
		XCTAssertEqual(
			d.rangeOfClosingBracket(")", openingBracket: "(")!.lowerBound,
			d.index(a.startIndex, offsetBy: 3)
		)
	}
}
