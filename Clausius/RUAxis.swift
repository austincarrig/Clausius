//
//  RUAxis.swift
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

import Foundation

@objc class RUAxis : NSObject {
	var min : NSNumber! = 0.0;
	var max : NSNumber! = 0.0;
	
	enum RUAxisDirection : NSString {
		case RUAxisDirectionX = "x"
		case RUAxisDirectionY = "y"
	}
	
	var direction : RUAxisDirection?
	
	enum RUAxisValueType : NSString {
		case RUAxisValueTypeTemperature = "t"
		case RUAxisValueTypePressure = "p"
		case RUAxisValueTypeSpecVol = "v"
		case RUAxisValueTypeIntEnergy = "u"
		case RUAxisValueTypeEnthalpy = "h"
		case RUAxisValueTypeEntropy = "s"
	}
	
	var valueType : RUAxisValueType?
	
	enum RUAxisScaleType : NSString {
		case RUAxisScaleTypeLinear = "linear"
		case RUAxisScaleTypeLog = "logarithmic"
	}
	
	var scaleType : RUAxisScaleType?
	
	class func newInstance() -> RUAxis {
		return RUAxis()
	}
	
	func range() -> NSNumber {
		return NSNumber.init(float: (min?.floatValue)! + (max?.floatValue)!);
	}
}