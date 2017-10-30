//
//  RUASpaceController.m
//  Clausius
//
//  Created by Austin Carrig on 10/29/17.
//  Copyright © 2017 RowanApps. All rights reserved.
//

#import "RUASpaceController.h"

static const int size = 7;
static const int maxDiff = 20.0;

@interface RUASpaceController ()

@property (strong, nonatomic) NSMutableArray *points;

@end

@implementation RUASpaceController

- (instancetype)initWithAllowableDistance
{
	self = [super init];
	if (self) {
		self.points = [[NSMutableArray alloc] initWithCapacity:size];
	}
	
	return self;
}

- (NSMutableArray *)points
{
	if (!_points) {
		_points = [[NSMutableArray alloc] initWithCapacity:size];
	}
	
	return _points;
}

- (BOOL)succeedsWithLatestPoint:(CGPoint)point
{
	if (self.points.count >= size) {
		if (self.points.count > size) {
			return YES;
		}
		[self.points removeObjectAtIndex:0];
	}
	NSValue *val = [NSValue valueWithBytes:&point
								  objCType:@encode(CGPoint)];
	[self.points addObject:val];
	
	if (!self.points) {
		NSLog(@"SHIT");
	}
	
	NSLog(@"%f, %f, %d", point.x, point.y, self.points.count);
	
	if ([self calculateRunningAverage] < maxDiff && self.points.count == 5) {
		return NO;
	}
	return YES;
}

- (float)calculateRunningAverage
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

@end
