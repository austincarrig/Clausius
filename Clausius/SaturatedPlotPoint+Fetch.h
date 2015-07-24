//
//  SaturatedPlotPoint+Fetch.h
//  Mvuke
//
//  Created by Austin Carrig on 6/19/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "SaturatedPlotPoint.h"

@interface SaturatedPlotPoint (Fetch)
+ (SaturatedPlotPoint *)fetchSaturatedPointWithTemperature:(int)temperature inContext:(NSManagedObjectContext *)context;
@end
