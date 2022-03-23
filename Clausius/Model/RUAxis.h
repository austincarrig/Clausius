//
//  RUAxis.h
//  Clausius
//
//  Created by Austin Carrig on 10/11/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, RUAxisDirection) {
    RUAxisDirectionX = 0,
    RUAxisDirectionY
};

typedef NS_ENUM(int, RUAxisValueType) {
    RUAxisValueTypeTemperature = 0,
    RUAxisValueTypePressure,
    RUAxisValueTypeSpecVol,
    RUAxisValueTypeIntEnergy,
    RUAxisValueTypeEnthalpy,
    RUAxisValueTypeEntropy
};

typedef NS_ENUM(int, RUAxisScaleType) {
    RUAxisScaleTypeLinear = 0,
    RUAxisScaleTypeLog
};

/**
 * The purpose of RUAxis is to represent the values for a given chart along a single axis
 */

@interface RUAxis : NSObject
@property (strong, nonatomic) NSNumber *min;
@property (strong, nonatomic) NSNumber *max;

@property RUAxisDirection direction;
@property RUAxisScaleType scaleType;
@property RUAxisValueType valueType;

+ (RUAxis *)createAxisForDirection:(RUAxisDirection)direction
                         valueType:(RUAxisValueType)valueType
                         scaleType:(RUAxisScaleType)scaleType
                               min:(NSNumber *)min
                               max:(NSNumber *)max;

+ (NSString *)decodeForValueWithValueType:(RUAxisValueType)valueType;
+ (RUAxisValueType)encodeForValueTypeWithValue:(NSString *)value;

+ (NSString *)decodeForValueWithScaleType:(RUAxisScaleType)scaleType;
+ (RUAxisScaleType)encodeForScaleTypeWithValue:(NSString *)value;

- (NSNumber *)range;
@end
