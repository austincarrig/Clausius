//
//  RUChart.h
//  Clausius
//
//  Created by Austin Carrig on 10/12/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUGraph.h"

typedef NS_ENUM(int, RUChartDisplayPosition) {
	RUChartDisplayPositionLeft = 0,
	RUChartDisplayPositionRight
};

@interface RUChart : RUGraph

@property (strong, nonatomic) NSString *substanceType;
@property (strong, nonatomic) NSString *valueType;

@property RUChartDisplayPosition displayPosition;

/**
 *  Base factory method for creating an RUChart
 *
 *  @param chartType The type for the chart as described by the value types (i.e. ts).
 *
 *  @return An initialized and set RUChart.
 */

+ (RUChart *)chartWithChartType:(NSString *)chartType;

+ (NSString *)decodeForValueWithDisplayPosition:(RUChartDisplayPosition)dispalyPosition;
+ (RUChartDisplayPosition)encodeForDisplayPositionWithValue:(NSString *)value;

@end
