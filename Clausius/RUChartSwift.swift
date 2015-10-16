//
//  RUChartSwift.swift
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

import Foundation
import UIKit

@objc public enum RUChartDisplayPosition : Int {
	case RUChartDisplayTopRight = 0
	case RUChartDisplayTopLeft
}

@objc public class RUChartSwift : RUGraph {
	public var substanceType : String?
	public var chartImage : UIImage?
	public var displayPosition : RUChartDisplayPosition?
	
	public func valueType() -> String {
		let y : RUAxisValueType? = self.yAxis?.valueType
		let x : RUAxisValueType? = self.xAxis?.valueType
		
		let type : String = RUAxis.decodeForValueWithType(y!) + RUAxis.decodeForValueWithType(x!)
		
		return type
	}
}