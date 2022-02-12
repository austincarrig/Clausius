//
//  SaturatedPlotPoint+Create.h
//  Mvuke
//
//  Created by Austin Carrig on 6/19/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "SaturatedPlotPoint.h"

@interface SaturatedPlotPoint (Create)
+ (SaturatedPlotPoint *)createSatPlotPointWithType:(NSString *)type
	    	    	    	    	     inContext:(NSManagedObjectContext *)context;
@end
