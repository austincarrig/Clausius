//
//  RUGraph.m
//  Clausius
//
//  Created by Austin Carrig on 10/13/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUGraph.h"

@implementation RUGraph

- (void)setAxis:(RUAxis *)axis
{
    // Check if the axis direction value is set
    @try {
        if (![NSNumber numberWithInt:axis.direction] || axis.direction > 1 || axis.direction < 0) {
            NSException *exception = [[NSException alloc] initWithName:@"Invalid Axis" reason:@"" userInfo:nil];
            @throw exception;
        }
    } @catch (NSException *exception) {
        // TODO: Catch the exception
    } @finally {
        if (axis.direction == RUAxisDirectionX) {
            self.xAxis = axis;
        } else if (axis.direction == RUAxisDirectionY) {
            self.yAxis = axis;
        }
    }
}

@end
