//
//  RUAAdjusterView.h
//  Clausius
//
//  Created by Austin Carrig on 7/22/15.
//  Copyright (c) 2015 RowanApps. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * NOTE 2/19/2021
 * Can probably delete this, but may be worth keeping around...
 *
 * The idea here, I believe, is to allow the user to "adjust"
 * the values without moving the pointer. The user should drag their finger
 * back and forth across the DisplayView row to increase/decrease the value.
 * The primary issues are that it's not an obvious/intuitive feature, and
 * it's very hard to "adjust" the non-linear values (like h on a T-s diagram).
 * The main driver of difficulty is that values have to be "locked". When the user
 * wants to increase h, along which axis should we move? Constant T? Constant s?
 * Direction of highest dh? It's a hard problem to solve, so there's probably a better
 * way. I think an interface which makes clear to the user what's happening is preferable.
 * Maybe a pop-up which allows the user to select a single value to change, and how
 * they will adjust it (gradient descent, constant T, etc).
 *
 */

@protocol RUAAdjusterViewDelegate;

@interface RUAAdjusterView : UIView
@property (strong, nonatomic) id <RUAAdjusterViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame tag:(NSUInteger)tag;
@end

@protocol RUAAdjusterViewDelegate <NSObject>

@optional
- (void)adjusterView:(RUAAdjusterView *)adjusterView didBeginTouchAtLocation:(CGPoint)location;
- (void)adjusterView:(RUAAdjusterView *)adjusterView didAdjustFromLocation:(CGPoint)fromLocation toLocation:(CGPoint)toLocation;
- (void)adjusterView:(RUAAdjusterView *)adjusterView didEndTouchAtLocation:(CGPoint)location;

@end
