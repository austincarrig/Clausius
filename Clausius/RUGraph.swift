//
//  RUGraph.swift
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

import Foundation
import UIKit

@objc class RUGraph : NSObject {
	var xAxis : RUAxis?
	var yAxis : RUAxis?
	
	func setAxis(axis : RUAxis) -> Bool {
		if axis.direction == "x" {
			xAxis = axis
			return true
		} else if axis.direction == "y"{
			yAxis = axis
			return true
		}
		return false
	}
}