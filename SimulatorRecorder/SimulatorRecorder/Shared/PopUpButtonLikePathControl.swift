//
//  GeneralPreferensesViewController.swift
//  SimulatorRecorder
//
//  Created by Grigory Entin on 07.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import GEFoundation
import Carbon.HIToolbox
import AppKit

class PopUpButtonLikePathControl : NSPathControl {
	
	override var alignmentRectInsets: NSEdgeInsets {
		
		return super.alignmentRectInsets ≈ {
			$0.left -= 3
			$0.right -= 3
		}
	}
	
	override var intrinsicContentSize: NSSize {
		
		return super.intrinsicContentSize ≈ {
			$0.height += 1
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
		drawBackground(bounds)
		
		/**/
		let interiorFrame = bounds ≈ {
			$0.origin.y -= 2
			$0.size.width += 20 // Force arrows outside the control bounds.
		}
		cell?.drawInterior(withFrame: interiorFrame, in: self)
		/**/
	}
	
	func drawBackground(_ rect: NSRect) {
		
		let cgContext = NSGraphicsContext.current?.cgContext
		var drawInfo = HIThemeButtonDrawInfo() ≈ {
			$0.state = ThemeDrawState(kThemeStateActive + (isHighlighted ? kThemeStatePressed : 0))
			$0.kind = ThemeButtonKind(kThemePopupButtonNormal)
		}
		var boundsCGRect = CGRect(x: bounds.minX, y: bounds.minY + 2, width: bounds.width, height: bounds.height)
		var labelCGRect = boundsCGRect
		HIThemeDrawButton(&boundsCGRect, &drawInfo, cgContext, HIThemeOrientation(kHIThemeOrientationNormal), &labelCGRect)
	}
}
