//
//  RUAPopupView.m
//  Clausius
//
//  Created by Austin Carrig on 3/17/16.
//  Copyright © 2016 RowanApps. All rights reserved.
//

#import "RUAPopupView.h"
#import "Masonry.h"

@interface RUAPopupView()

@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation RUAPopupView

- (instancetype)initWithFrame:(CGRect)frame
	    	    	     text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
	    self.text = text;
	    
	    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	    self.nameLabel.text = text;
	    self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:96.0f];
	    self.nameLabel.textColor = [UIColor whiteColor];
	    
	    CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
	    
	    self.nameLabel.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
	    
	    self.nameLabel.center = self.center;
	    
	    [self addSubview:self.nameLabel];
	    
	    self.layer.cornerRadius = 15.0f;
	    
	    self.alpha = 0.0;
	    self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
	    
	    self.hidden = YES;
    }
    
    return self;
}

- (void)remakeFrames
{
    CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    self.frame = CGRectMake(0.0f, 0.0f, size.width + 40.0f, size.height + 40.0f);
    self.nameLabel.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
	    make.height.equalTo(@(self.frame.size.height));
	    make.width.equalTo(@(self.frame.size.width));
    }];
    
    self.nameLabel.center = self.center;
}

- (void)showAnimated:(BOOL)animated
{
    
    
    self.nameLabel.text = self.text;
    [self remakeFrames];
    
    self.hidden = NO;
    if (animated) {
	    [UIView animateWithDuration:(NSTimeInterval)0.5
    	    	    	      delay:0.0
    	    	    	    options:UIViewAnimationOptionBeginFromCurrentState
	    	    	     animations:^{
    	    	    	     self.alpha = 1.0;
	    	    	     } completion:nil];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
	    [UIView animateWithDuration:(NSTimeInterval)0.5
    	    	    	      delay:0.0
    	    	    	    options:UIViewAnimationOptionBeginFromCurrentState
	    	    	     animations:^{
    	    	    	     self.alpha = 0.0;
	    	    	     } completion:^(BOOL finished) {
    	    	    	     self.hidden = YES;
	    	    	     }];
    } else {
	    self.hidden = YES;
	    self.alpha = 0.0;
    }
}

- (void)changeAnimated:(BOOL)animated
{
    if (self.isHidden) {
	    [self showAnimated:YES];
    } else {
	    [self hideAnimated:YES];
    }
}

- (void)showHideAnimated:(BOOL)animated
{
    [self showAnimated:animated];
    [NSTimer scheduledTimerWithTimeInterval:1.5
    	    	    	    	     target:self
	    	    	    	       selector:@selector(hideTimer:)
	    	    	    	       userInfo:@{@"animated" : @(animated)}
    	    	    	    	    repeats:NO];
}

- (void)hideTimer:(NSTimer *)timer
{
    [self hideAnimated:((NSNumber *)timer.userInfo[@"animated"]).boolValue];
}

@end
