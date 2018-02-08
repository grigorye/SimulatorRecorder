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
		var boundsCGRect = CGRect(x: bounds.minX, y: bounds.minY + 1, width: bounds.width - 1, height: bounds.height)
		var labelCGRect = boundsCGRect
		HIThemeDrawButton(&boundsCGRect, &drawInfo, cgContext, HIThemeOrientation(kHIThemeOrientationNormal), &labelCGRect)
	}
}
