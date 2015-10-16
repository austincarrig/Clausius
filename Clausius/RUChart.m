//
//  RUChart.m
//  Clausius
//
//  Created by Austin Carrig on 10/12/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUChart.h"

#import "RUDataSelector.h"

#import "Constants.h"

@implementation RUChart

#pragma mark - Creation

+ (RUChart *)chartWithChartType:(NSString *)chartType
{
	RUChart *chart = [[RUChart alloc] init];
	
	NSDictionary *chartValues = [RUDataSelector loadChartDataWithChartType:chartType];
	
	[chart setAxis:[RUAxis createAxisForDirection:RUAxisDirectionX
										valueType:[RUAxis encodeForValueTypeWithValue:[chartValues objectForKey:kChartDataXType]]
										scaleType:[RUAxis encodeForScaleTypeWithValue:[chartValues objectForKey:kChartDataXScale]]
											  min:[chartValues objectForKey:kChartDataXMin]
											  max:[chartValues objectForKey:kChartDataXMax]]];
	
	[chart setAxis:[RUAxis createAxisForDirection:RUAxisDirectionY
										valueType:[RUAxis encodeForValueTypeWithValue:[chartValues objectForKey:kChartDataYType]]
										scaleType:[RUAxis encodeForScaleTypeWithValue:[chartValues objectForKey:kChartDataYScale]]
											  min:[chartValues objectForKey:kChartDataYMin]
											  max:[chartValues objectForKey:kChartDataYMax]]];
	
	[chart setValueType:chartType];
	[chart setSubstanceType:@"Water"];
	
	[chart setDisplayPosition:[RUChart encodeForDisplayPositionWithValue:[chartValues objectForKey:kChartDataDisplayPosition]]];
	
	return chart;
}

#pragma mark - Encoding/Decoding

+ (NSString *)decodeForValueWithDisplayPosition:(RUChartDisplayPosition)displayPosition
{
	@try {
		if (!(displayPosition > 1 || displayPosition < 0)) {
			NSException *exception = [NSException exceptionWithName:@"Incorrect Axis ValueType Passed"
															 reason:@"The value type was not between 0 (left) and 1 (right)."
														   userInfo:@{@"value" : [NSNumber numberWithInt:displayPosition]}];
			
			@throw exception;
		}
	}
	@catch (NSException *exception) {
		NSLog(@"exception: %@", exception);
	}
	
	if (displayPosition == RUChartDisplayPositionLeft) {
		return @"left";
	} else if (displayPosition == RUChartDisplayPositionRight) {
		return @"right";
	}
	
	return nil;
}

+ (RUChartDisplayPosition)encodeForDisplayPositionWithValue:(NSString *)value
{
	if ([value isEqualToString:@"left"]) {
		return RUChartDisplayPositionLeft;
	} else if ([value isEqualToString:@"right"]) {
		return RUChartDisplayPositionRight;
	} else {
		@try {
			NSException *exception = [[NSException alloc] initWithName:@"Incorrect Value Passed"
																reason:@"Wrong value passed to +encodeForDisplayPositionWithValue:." userInfo:nil];
			@throw exception;
		} @catch (NSException *exception) {
			NSLog(@"exception: %@",exception);
		} @finally {
			return -1;
		}
	}
}

@end
