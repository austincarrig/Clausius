//
//  RUAPopupView.h
//  Clausius
//
//  Created by Austin Carrig on 3/17/16.
//  Copyright © 2016 RowanApps. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * NOTE 2/19/2021
 * This class can probably be deleted...
 *
 * Originally, the idea of this view was to have a text box
 * pop up when the chart was changed, which specified the type of
 * chart. This is now rendered obsolete with Aarav's buttons to
 * to change the chart type.
 *
 */

@interface RUAPopupView : UIView
@property (strong, nonatomic) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame
                         text:(NSString *)text;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)changeAnimated:(BOOL)animated;
- (void)showHideAnimated:(BOOL)animated;

@end
