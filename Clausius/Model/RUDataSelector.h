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

/**
 *  This returns an array of the key values (i.e. temperature or pressure) listed in the first row of the passed file.
 *
 *  @param fileName The filename of the CSV file containing the values to be loaded. Found in the form #Substance#_Super_#ValueType#.csv
 *
 *  @return An array of the key values.
 */

+ (NSArray *)loadSuperheatedKeyValuesWithFileName:(NSString *)fileName;

/**
 *  This returns an array of the key values (i.e. temperature or pressure) listed in the first row of the passed file.
 *
 *  @param fileName The filename of the CSV file containing the values to be loaded. Found in the form #Substance#_Super_#ValueType#.csv
 *
 *  @return A nested array of the values. Each inner array corresponds to a row in the csv.
 */

+ (NSArray *)loadSuperheatedValuesWithFileName:(NSString *)fileName;

+ (NSArray *)loadSuperheatedRowMappingValuesWithFileName:(NSString *)fileName;

@end
