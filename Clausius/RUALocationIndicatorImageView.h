//
//  RUALocationIndicatorImageView.h
//  Mvuke
//
//  Created by Austin Carrig on 5/18/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RUALocationIndicatorImageViewDataSource;
@protocol RUALocationIndicatorImageViewDelegate;

@interface RUALocationIndicatorImageView : UIImageView

@property (strong, nonatomic, readonly) UIColor *primaryColor;

@property (strong, nonatomic) id <RUALocationIndicatorImageViewDataSource> dataSource;
@property (strong, nonatomic) id <RUALocationIndicatorImageViewDelegate> delegate;

@property (strong, nonatomic) NSNumber *xMin;
@property (strong, nonatomic) NSNumber *xMax;
@property (strong, nonatomic) NSNumber *yMin;
@property (strong, nonatomic) NSNumber *yMax;

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image sender:(id)sender;

@end

@protocol RUALocationIndicatorImageViewDataSource <NSObject>
@optional
/**
 *  Used to provide the color of the location indicator circle.
 *
 *  @param locationIndicatorImageView The location indicator image view to which you provide the color.
 *
 *  @return The color of the location indicator circle.
 */
- (UIColor *)primaryColorForLocationView:(RUALocationIndicatorImageView *)locationIndicatorImageView;

/**
 *  Provides the raw pixel data for processing to the location indicator image view. This is used to determine the left border of the graph, so that the indicator stops if the user's finger goes outside the bounds of the graph.
 *
 *  @param locationIndicatorImageView The location indicator image view requesting the pixel data.
 *
 *  @return The raw pixel data for the image.
 */
- (unsigned char *)pixelDataForCurrentImageInLocationView:(RUALocationIndicatorImageView *)locationIndicatorImageView;
- (CGFloat)primaryAxisEndingValue;
- (CGFloat)secondaryAxisEndingValue;
- (CGFloat)primaryAxisStartingValue;
- (CGFloat)secondaryAxisStartingValue;
- (CGFloat)minimumSecondaryAxisValue;
@end

@protocol RUALocationIndicatorImageViewDelegate <NSObject>
@optional
/**
 *  Calls when a touch begins in the location indicator view.
 *
 *  @param location					  The touch location returned as a CGPoint (xy coords).
 *  @param locationIndicatorImageView The location indicator image view in which the touch occurred.
 */
- (void)touchDidBeginAtLocation:(CGPoint)location inLocationView:(RUALocationIndicatorImageView *)locationIndicatorImageView;

/**
 *  Calls when a touch moves in the location indicator view.
 *
 *  @param location                   The touch location returned as a CGPoint (xy coords).
 *  @param locationIndicatorImageView The location indicator image view in which the touch occurred.
 */
- (void)touchDidMoveToLocation:(CGPoint)location inLocationView:(RUALocationIndicatorImageView *)locationIndicatorImageView;
@end