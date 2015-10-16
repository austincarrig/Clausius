//
//  RUAxisSwift.swift
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

import Foundation

@objc public enum RUAxisSwiftDirection : NSInteger {
	case X = 0, Y
}

@objc public enum RUAxisSwiftValueType : NSInteger {
	case Temperature = 0
	case Pressure
	case SpecVol
	case IntEnergy
	case Enthalpy
	case Entropy
}

@objc public enum RUAxisSwiftScaleType : NSInteger {
	case Linear = 0
	case Log
}

@objc public class RUAxisSwift : NSObject {
	var min : NSNumber! = 0.0;
	var max : NSNumber! = 0.0;
	
	var direction : RUAxisSwiftDirection! = RUAxisSwiftDirection.X
	
	var valueType : RUAxisSwiftValueType! = RUAxisSwiftValueType.Temperature
	
	var scaleType : RUAxisSwiftScaleType! = RUAxisSwiftScaleType.Linear
	
	class func decodeForValueWithType(type : RUAxisSwiftValueType) -> String {
		let valueTypeDecoder : [RUAxisSwiftValueType:String] = [
			RUAxisSwiftValueType.Temperature : "t",
			RUAxisSwiftValueType.Pressure : "p",
			RUAxisSwiftValueType.SpecVol : "v",
			RUAxisSwiftValueType.IntEnergy : "u",
			RUAxisSwiftValueType.Enthalpy : "h",
			RUAxisSwiftValueType.Entropy : "s"
		]
		return valueTypeDecoder[type]!
	}
	
	class func newInstance() -> RUAxisSwift {
		return RUAxisSwift()
	}
	
	func setDirection(direc : RUAxisSwiftDirection) {
		direction = direc
	}
	
	func setValueType(value : RUAxisSwiftValueType) {
		valueType = value
	}
	
	func setScaleType(scale : RUAxisSwiftScaleType) {
		scaleType = scale
	}
	/*
	func direction() -> RUAxisSwiftDirection {
		return direction
	}
	
	func valueType() -> RUAxisSwiftValueType {
		return valueType
	}
	
	func scaleType() -> RUAxisSwiftScaleType {
		return scaleType
	}
	*/
	func range() -> NSNumber {
		return NSNumber.init(float: (min?.floatValue)! + (max?.floatValue)!);
	}
}