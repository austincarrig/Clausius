//
//  RUDataSelector.m
//  Clausius
//
//  Created by Austin Carrig on 10/10/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUDataSelector.h"
#import "Constants.h"

@implementation RUDataSelector

+ (NSDictionary *)loadChartDataWithChartType:(NSString *)chartType
{
	// Get the directory, find the specified file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Chart_Data.csv" ofType:nil inDirectory:@"Data Files"];
	NSString *string = [NSString stringWithUTF8String:[[NSData dataWithContentsOfFile:path] bytes]];
	
	// Create a scanner which contains the entirety of the .csv file
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	
	// Make character sets to scan through the string scanner
	NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
	NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	NSString *tempString;
	// Look through the scanner for the chart type
	do {
		[scanner scanUpToCharactersFromSet:comma
								intoString:&tempString];
		if (![tempString isEqualToString:chartType]) {
			[scanner scanUpToCharactersFromSet:newline
									intoString:nil];
		}
		[scanner setScanLocation:scanner.scanLocation + 1];
	} while (![tempString isEqualToString:chartType]);
	
	NSArray *array = [RUDataSelector dataLoadingKeys];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tempString, kChartDataType, nil];
	
	[scanner scanUpToCharactersFromSet:newline
							intoString:&string];
	scanner = [[NSScanner alloc] initWithString:string];
	
	NSUInteger count = 1;
	while (![scanner isAtEnd]) {
		[scanner scanUpToCharactersFromSet:comma
								intoString:&tempString];
		[dict setObject:tempString
				 forKey:[array objectAtIndex:count]];
		if ([scanner isAtEnd]) {
			break;
		}
		[scanner setScanLocation:scanner.scanLocation + 1];
		count++;
	}
	
	return (NSDictionary *)dict;
}

+ (NSArray *)dataLoadingKeys
{
	return @[kChartDataType, kChartDataXType, kChartDataXMin, kChartDataXMax, kChartDataXScale, kChartDataYType, kChartDataYMin, kChartDataYMax, kChartDataYScale, kChartDataDisplayPosition];
}

+ (NSArray *)loadSuperheatedPressuresWithFileName:(NSString *)fileName
{
	// Get the directory, find the specified file
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:@"Data Files"];
	NSString *string = [NSString stringWithUTF8String:[[NSData dataWithContentsOfFile:path] bytes]];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	
	NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
	NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	NSString *pressureString;
	[scanner scanUpToCharactersFromSet:newline
							intoString:&pressureString];
	NSScanner *pressureScanner = [NSScanner scannerWithString:pressureString];
	
	NSMutableArray *pressureValues = [[NSMutableArray alloc] init];
	
	// Get all pressure values
	while (![pressureScanner isAtEnd]) {
		NSString *pressureVal;
		// Delimited by commas
		[pressureScanner scanUpToCharactersFromSet:comma
										intoString:&pressureVal];
		
		if (![pressureScanner isAtEnd]) {
			[pressureScanner setScanLocation:[pressureScanner scanLocation]+1];
		}
		[pressureValues addObject:[NSNumber numberWithFloat:[pressureVal floatValue]]];
	}
	
	return pressureValues;
}

+ (NSArray *)loadSuperheatedEntropiesWithFileName:(NSString *)fileName
{
	// Get the directory, find the specified file
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:@"Data Files"];
	NSString *string = [NSString stringWithUTF8String:[[NSData dataWithContentsOfFile:path] bytes]];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	
	NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
	NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	NSString *pressureString;
	[scanner scanUpToCharactersFromSet:newline
							intoString:&pressureString];
	
	NSMutableArray *entropyValues = [NSMutableArray arrayWithObjects:@[], nil]; // empty array at index=0 is so that the array indeces are mapped to 0
	
	while (![scanner isAtEnd]) {
		NSString *lineString;
		[scanner scanUpToCharactersFromSet:newline
								intoString:&lineString];
		if (![scanner isAtEnd]) {
			[scanner setScanLocation:[scanner scanLocation]+1];
		}
		
		NSScanner *lineScanner = [NSScanner scannerWithString:lineString];
		
		// Get temperature, delimited by comma in first index of row (unused in this scheme, but gets rid of first element)
		NSString *temperatureString;
		[lineScanner scanUpToCharactersFromSet:comma
									intoString:&temperatureString];
		if (![lineScanner isAtEnd]) {
			[lineScanner setScanLocation:[lineScanner scanLocation]+1];
		}
		
		// Store one line of entropies
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		
		int count = 0;
		while (![lineScanner isAtEnd]) {
			NSString *valueString;
			[lineScanner scanUpToCharactersFromSet:comma
										intoString:&valueString];
			if (![lineScanner isAtEnd]) {
				[lineScanner setScanLocation:[lineScanner scanLocation]+1];
			}
			
			if (!([valueString isEqualToString:@"#VALUE!"] || [valueString isEqualToString:@"#NAME?"] || [valueString isEqualToString:@""]) && valueString) {
				[tempArray addObject:[NSNumber numberWithFloat:[valueString floatValue]]];
			} else {
				break;
			}
			count++;
		}
		
		// Add the corresponding entropy array to the end of the array of entropy arrays
		[entropyValues addObject:tempArray];
	}
	
	return entropyValues;
}

@end
