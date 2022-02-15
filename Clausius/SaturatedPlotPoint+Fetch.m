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

    if (values.count != 0) {
        return (SaturatedPlotPoint *)[values firstObject];
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SaturatedPlotPoint"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"t == %d",(int)temperature];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSArray *values = [context executeFetchRequest:fetchRequest
                                                 error:&error];
        if (error) {
            NSLog(@"Error in fetching saturated point plot: %@, %@",error, [error userInfo]);
        }

        return (SaturatedPlotPoint *)[values firstObject];
    }
}

+ (float)fetchTemperatureWithPressure:(float)pressure inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SaturatedPlotPoint"];
    NSPredicate *predicate;
    if (pressure <= 100) {
        predicate = [NSPredicate predicateWithFormat:@"p BETWEEN {%f,%f}", pressure - 1.0f, pressure + 1.0f];
    } else if (pressure <= 150 && pressure > 100) {
        predicate = [NSPredicate predicateWithFormat:@"p BETWEEN {%f,%f}", 99.1f, pressure + 50.0f];
    } else if (pressure <= 1000) {
        predicate = [NSPredicate predicateWithFormat:@"p BETWEEN {%f,%f}", pressure - 50.0f, pressure + 50.0f];
    } else if (pressure <= 1100 && pressure > 1000) {
        predicate = [NSPredicate predicateWithFormat:@"p BETWEEN {%f,%f}", pressure - 50.0f, pressure + 100.0f];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"p BETWEEN {%f,%f}", pressure - 100.0f, pressure + 100.0f];
    }

    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *values = [context executeFetchRequest:fetchRequest
                                             error:&error];

    for (SaturatedPlotPoint* val in values) {
        NSLog(@"%@",val.p);
    }

    NSMutableArray *array = [NSMutableArray array];
    for (SaturatedPlotPoint *point in values) {
        if (floorf(point.p.floatValue) == point.p.floatValue) {
            for (SaturatedPlotPoint *point2 in array) {
                if ([point.p isEqualToNumber:point2.p]) {
                    continue;
                }
            }
            [array addObject:point];
        }
    }

    SaturatedPlotPoint *firstPlotPoint = [array firstObject];
    SaturatedPlotPoint *lastPlotPoint = [array lastObject];

    float highPressure;
    float lowPressure;
    float highTemp;
    float lowTemp;

    if (firstPlotPoint.p.floatValue > lastPlotPoint.p.floatValue) {
        highPressure = firstPlotPoint.p.floatValue;
        lowPressure = lastPlotPoint.p.floatValue;
        highTemp = firstPlotPoint.t.floatValue;
        lowTemp = lastPlotPoint.t.floatValue;
    } else {
        highPressure = lastPlotPoint.p.floatValue;
        lowPressure = firstPlotPoint.p.floatValue;
        highTemp = lastPlotPoint.t.floatValue;
        lowTemp = firstPlotPoint.t.floatValue;
    }

    float weight = (pressure - lowPressure)/(highPressure - lowPressure);

    if (error) {
        NSLog(@"Error in fetching saturated point plot: %@, %@",error, [error userInfo]);
    }

    return lowTemp + weight*(highTemp - lowTemp);
}

@end
