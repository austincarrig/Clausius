//
//  RUDataSelector.h
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class is used to data from .csv files for different uses throughout Clausius.
 */

@interface RUDataSelector : NSObject

/**
 *  Used for chart data loading
 *
 *  @return An array with all keys used for storing values pulled from +loadChartDataWithChartType:. Use this function in conjuction with that one.
 */

+ (NSArray *)dataLoadingKeys;

/**
 *  Use this function when charts are changed.
 *
 *  @param chartType The type for the chart as described by the value types (i.e. ts).
 *
 *	@see [RUDataSelector dataLoadingKeys]
 *
 *  @return A dictionary of all the pertinent information regrading the chart of the type specified. The keys for the dictorary can be obtained from [RUDataSelector dataLoadingKeys].
 */

+ (NSDictionary *)loadChartDataWithChartType:(NSString *)chartType;

+ (NSArray *)loadSuperheatedPressuresWithFileName:(NSString *)fileName;
+ (NSArray *)loadSuperheatedEntropiesWithFileName:(NSString *)fileName;

@end
