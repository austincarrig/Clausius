//
//  SaturatedPlotPoint+Fetch.m
//  Mvuke
//
//  Created by Austin Carrig on 6/19/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "SaturatedPlotPoint+Fetch.h"

@implementation SaturatedPlotPoint (Fetch)
+ (SaturatedPlotPoint *)fetchSaturatedPointWithTemperature:(float)temperature inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SaturatedPlotPoint"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"t == %f",temperature];
	[fetchRequest setPredicate:predicate];
	NSError *error;
	NSArray *values = [context executeFetchRequest:fetchRequest
											 error:&error];
	if (error) {
		NSLog(@"Error in fetching saturated point plot: %@, %@",error, [error userInfo]);
	}
	
	return (SaturatedPlotPoint *)[values firstObject];
}
@end
