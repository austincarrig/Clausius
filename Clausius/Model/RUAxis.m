//
//  RUAxis.m
//  Clausius
//
//  Created by Austin Carrig on 10/11/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUAxis.h"

@implementation RUAxis

#pragma mark - Creation Methods

+ (RUAxis *)createAxisForDirection:(RUAxisDirection)direction
	    	    	     valueType:(RUAxisValueType)valueType
	    	    	     scaleType:(RUAxisScaleType)scaleType
    	    	    	       min:(NSNumber *)min
    	    	    	       max:(NSNumber *)max
{
    RUAxis *axis = [[RUAxis alloc] init];
    
    axis.direction = direction;
    axis.valueType = valueType;
    axis.scaleType = scaleType;
    axis.min = min;
    axis.max = max;
    
    return axis;
}

#pragma mark - Encoding/Decoding

+ (NSString *)decodeForValueWithValueType:(RUAxisValueType)valueType
{
    @try {
	    if (!(valueType > 5 || valueType < 0)) {
    	    NSException *exception = [NSException exceptionWithName:@"Incorrect Axis ValueType Passed"
    	    	    	    	    	    	    	     reason:@"The value type was not between 0 (t) and 5 (s)."
	    	    	    	    	    	    	       userInfo:@{@"value" : [NSNumber numberWithInt:valueType]}];
    	    
    	    @throw exception;
	    }
    }
    @catch (NSException *exception) {
	    NSLog(@"exception: %@", exception);
    }
    NSDictionary *valueTypeDecoder = @{ @"t" : [NSNumber numberWithInt:RUAxisValueTypeTemperature],
	    	    	    	    	    @"p" : [NSNumber numberWithInt:RUAxisValueTypePressure],
	    	    	    	    	    @"v" : [NSNumber numberWithInt:RUAxisValueTypeSpecVol],
	    	    	    	    	    @"u" : [NSNumber numberWithInt:RUAxisValueTypeIntEnergy],
	    	    	    	    	    @"h" : [NSNumber numberWithInt:RUAxisValueTypeEnthalpy],
	    	    	    	    	    @"s" : [NSNumber numberWithInt:RUAxisValueTypeEntropy]};
    
    return [valueTypeDecoder allKeysForObject:[NSNumber numberWithInt:valueType]].firstObject;
}

+ (RUAxisValueType)encodeForValueTypeWithValue:(NSString *)value
{
    if ([value isEqualToString:@"t"]) {
	    return RUAxisValueTypeTemperature;
    } else if ([value isEqualToString:@"p"]) {
	    return RUAxisValueTypePressure;
    } else if ([value isEqualToString:@"v"]) {
	    return RUAxisValueTypeSpecVol;
    } else if ([value isEqualToString:@"u"]) {
	    return RUAxisValueTypeIntEnergy;
    } else if ([value isEqualToString:@"h"]) {
	    return RUAxisValueTypeEnthalpy;
    } else if ([value isEqualToString:@"s"]) {
	    return RUAxisValueTypeEntropy;
    } else {
	    @try {
    	    NSException *exception = [[NSException alloc] initWithName:@"Incorrect Value Passed"
	    	    	    	    	    	    	    	    reason:@"Wrong value passed to +encodeForValueTypeWithValue:." userInfo:nil];
    	    @throw exception;
	    } @catch (NSException *exception) {
    	    NSLog(@"exception: %@",exception);
	    } @finally {
    	    return -1;
	    }
    }
}

+ (NSString *)decodeForValueWithScaleType:(RUAxisScaleType)scaleType
{
    @try {
	    if (!(scaleType > 1 || scaleType < 0)) {
    	    NSException *exception = [NSException exceptionWithName:@"Incorrect Axis ValueType Passed"
    	    	    	    	    	    	    	     reason:@"The value type was not between 0 (linear) and 1 (log)."
	    	    	    	    	    	    	       userInfo:@{@"value" : [NSNumber numberWithInt:scaleType]}];
    	    
    	    @throw exception;
	    }
    }
    @catch (NSException *exception) {
	    NSLog(@"exception: %@", exception);
    }
    
    if (scaleType == RUAxisScaleTypeLinear) {
	    return @"linear";
    } else if (scaleType == RUAxisScaleTypeLog) {
	    return @"log";
    }
    
    return nil;
}

+ (RUAxisScaleType)encodeForScaleTypeWithValue:(NSString *)value
{
    if ([value isEqualToString:@"linear"]) {
	    return RUAxisScaleTypeLinear;
    } else if ([value isEqualToString:@"log"]) {
	    return RUAxisScaleTypeLog;
    } else {
	    @try {
    	    NSException *exception = [[NSException alloc] initWithName:@"Incorrect Value Passed"
	    	    	    	    	    	    	    	    reason:@"Wrong value passed to +encodeForScaleTypeWithValue:." userInfo:nil];
    	    @throw exception;
	    } @catch (NSException *exception) {
    	    NSLog(@"exception: %@",exception);
	    } @finally {
    	    return -1;
	    }
    }
}

#pragma mark - Usefulness Methods

- (NSNumber *)range
{
    return [NSNumber numberWithFloat:self.max.floatValue - self.min.floatValue];
}

@end
