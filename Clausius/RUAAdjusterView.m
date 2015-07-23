//
//  RUAAdjusterView.m
//  Clausius
//
//  Created by Austin Carrig on 7/22/15.
//  Copyright (c) 2015 RowanApps. All rights reserved.
//

#import "RUAAdjusterView.h"

@interface RUAAdjusterView ()
@property CGPoint currentTouchLocation;
@end

@implementation RUAAdjusterView

- (instancetype)initWithFrame:(CGRect)frame tag:(NSUInteger)tag
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setUserInteractionEnabled:YES];
		[self setTag:tag];
	}
	
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (event.allTouches.count == 1) {
		CGPoint touchLocation = [(UITouch *)[touches anyObject] locationInView:self];

		if ([self.delegate respondsToSelector:@selector(adjusterView:didBeginTouchAtLocation:)]) {
			[self.delegate adjusterView:self
				didBeginTouchAtLocation:touchLocation];
		}
		
		self.currentTouchLocation = touchLocation;
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	if (event.allTouches.count == 1) {
		CGPoint touchLocation = [(UITouch *)[touches anyObject] locationInView:self];
		
		if ([self.delegate respondsToSelector:@selector(adjusterView:didAdjustFromLocation:toLocation:)]) {
			[self.delegate adjusterView:self
			 didAdjustFromLocation:self.currentTouchLocation
							 toLocation:touchLocation];
		}
		
		self.currentTouchLocation = touchLocation;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	if (event.allTouches.count == 1) {
		CGPoint touchLocation = [(UITouch *)[touches anyObject] locationInView:self];
		
		if ([self.delegate respondsToSelector:@selector(adjusterView:didEndTouchAtLocation:)]) {
			[self.delegate adjusterView:self
				  didEndTouchAtLocation:touchLocation];
		}
		
		self.currentTouchLocation = touchLocation;
	}
}

@end
