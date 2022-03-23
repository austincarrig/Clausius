//
//  RUASpaceController.m
//  Clausius
//
//  Created by Austin Carrig on 10/29/17.
//  Copyright © 2017 RowanApps. All rights reserved.
//

#import "RUASpaceController.h"

@interface RUASpaceController ()

@property (strong, nonatomic) NSMutableArray *points;

@end

@implementation RUASpaceController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.numPoints = 5;
        self.maxDiff = 30.0;
    }

    return self;
}

- (NSMutableArray *)points
{
    if (!_points) {
        _points = [[NSMutableArray alloc] initWithCapacity:_numPoints];
    }

    return _points;
}

- (BOOL)addLatestPoint:(CGPoint)point
{
    if (self.points.count >= _numPoints)
    {
        if (self.points.count > _numPoints)
        {
            return NO;
        }
        
        [self.points removeObjectAtIndex:0];
    }
    NSValue *val = [NSValue valueWithBytes:&point
                                  objCType:@encode(CGPoint)];
    [self.points addObject:val];

    return YES;
}

- (BOOL)withinMarginWithLatestPoint:(CGPoint)point
{
    if (![self addLatestPoint:point])
    {
        if ([self calculateLargestDistance] < self.maxDiff &&
            self.points.count == _numPoints)
        {
            return YES;
        }
    }

    return NO;
}

- (float)calculateLargestDistance
{
    float highestDiff = 0;

    for (int i = 0; i < self.points.count; i++) {
        for (int j = 0; j < self.points.count; j++) {
            if (i < j) {
                CGPoint p1;
                CGPoint p2;

                [self.points[i] getValue:&p1];
                [self.points[j] getValue:&p2];

                float diff = [self distanceFrom:p1 to:p2];
                if (diff > highestDiff) {
                    highestDiff = diff;
                }
            }
        }
    }
    return highestDiff;
}

- (float)distanceFrom:(CGPoint)p1 to:(CGPoint)p2
{
    return sqrtf(powf(p1.x - p2.x, 2.0) + powf(p1.y - p2.y, 2.0));
}

- (void)reset
{
    self.points = [[NSMutableArray alloc] initWithCapacity:self.numPoints];
}

@end
