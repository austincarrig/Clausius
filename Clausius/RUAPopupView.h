//
//  RUAPopupView.h
//  Clausius
//
//  Created by Austin Carrig on 3/17/16.
//  Copyright © 2016 RowanApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RUAPopupView : UIView
@property (strong, nonatomic) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame
						 text:(NSString *)text;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)changeAnimated:(BOOL)animated;
- (void)showHideAnimated:(BOOL)animated;

@end
