//
//  SaturatedPlotPoint+Create.m
//  Mvuke
//
//  Created by Austin Carrig on 6/19/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "SaturatedPlotPoint+Create.h"

@implementation SaturatedPlotPoint (Create)
+ (SaturatedPlotPoint *)createSatPlotPointWithType:(NSString *)type inContext:(NSManagedObjectContext *)context
{
	SaturatedPlotPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"SaturatedPlotPoint"
															  inManagedObjectContext:context];
	
	[point setType:type];
	
	return point;
}
@end
