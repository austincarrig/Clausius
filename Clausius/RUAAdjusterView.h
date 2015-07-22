//
//  RUAAdjusterView.h
//  Clausius
//
//  Created by Austin Carrig on 7/22/15.
//  Copyright (c) 2015 RowanApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RUAAdjusterViewDelegate;

@interface RUAAdjusterView : UIView
@property (strong, nonatomic) id <RUAAdjusterViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
@end

@protocol RUAAdjusterViewDelegate <NSObject>

@optional
- (void)adjusterView:(RUAAdjusterView *)adjusterView didBeginTouchAtLocation:(CGPoint)location;
- (void)adjusterView:(RUAAdjusterView *)adjusterView didAdjustFromLocation:(CGPoint)fromLocation toLocation:(CGPoint)toLocation;
- (void)adjusterView:(RUAAdjusterView *)adjusterView didEndTouchAtLocation:(CGPoint)location;

@end