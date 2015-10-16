v//
//  RUGraph.swift
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

import Foundation
import UIKit

 /// Abstract class defining what a graph is. In practical usage, use RUChart instead.

@objc public class RUGraph : NSObject {
	var xAxis : RUAxis?
	var yAxis : RUAxis?
	
	func setAxis(axis : RUAxis) {
		if axis.direction == RUAxisDirection.X {
			xAxis = axis
		} else if axis.direction == RUAxisDirection.Y {
			yAxis = axis
		}
	}
}