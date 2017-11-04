//
//  RUASpaceController.h
//  Clausius
//
//  Created by Austin Carrig on 10/29/17.
//  Copyright © 2017 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface RUASpaceController : NSObject

@property (nonatomic) NSUInteger numPoints;
@property (nonatomic) CGFloat maxDiff;

- (instancetype)init;

- (BOOL)addLatestPoint:(CGPoint)point;
- (BOOL)withinMarginWithLatestPoint:(CGPoint)point;
- (void)reset;

@end
