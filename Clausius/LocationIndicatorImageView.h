//
//  LocationIndicatorImageView.h
//  Mvuke
//
//  Created by Austin Carrig on 5/18/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUChart.h"

@protocol LocationIndicatorImageViewDataSource;
@protocol LocationIndicatorImageViewDelegate;

@interface LocationIndicatorImageView : UIImageView

@property (strong, nonatomic) RUChart *chart;

@property (strong, nonatomic, readonly) UIColor *primaryColor;

@property (strong, nonatomic) id <LocationIndicatorImageViewDataSource> dataSource;
@property (strong, nonatomic) id <LocationIndicatorImageViewDelegate> delegate;

@property (nonatomic, readonly) CGPoint lastLocation;
@property (strong, nonatomic) NSNumber *xMin;
@property (strong, nonatomic) NSNumber *xMax;
@property (strong, nonatomic) NSNumber *yMin;
@property (strong, nonatomic) NSNumber *yMax;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image sender:(id)sender;
//- (void)moveMarkerToPrimaryAxisValue:(CGFloat)primValue secondaryAxisValue:(CGFloat)secValue;

- (BOOL)pointIsWithinBoundsForPrimaryAxisValue:(CGFloat)primValue secondaryAxisValue:(CGFloat)secValue;

/**
 *  Used to reset the image, as this function also resets the rawdata for the imageView.
 *
 *  @param image The image that you would like to set the view's image to.
 */
- (void)resetImage:(UIImage *)image;

#pragma mark - Marker Adjustment Methods

- (void)addLargeMarkerAtLocation:(CGPoint)location;
- (void)moveLargeMarkerToLocation:(CGPoint)location;
- (void)addSmallMarkerAtLocation:(CGPoint)location;
- (void)moveMarkerToPrimaryAxisValue:(CGFloat)primValue secondaryAxisValue:(CGFloat)secValue;

/**
 *  Used to remove the marker from the view.
 */
- (void)removeMarker;

@end

@protocol LocationIndicatorImageViewDataSource <NSObject>
@optional
/**
 *  Used to provide the color of the location indicator circle.
 *
 *  @param locationIndicatorImageView The location indicator image view to which you provide the color.
 *
 *  @return The color of the location indicator circle.
 */
- (UIColor *)primaryColorForLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;

/**
 *  Provides the raw pixel data for processing to the location indicator image view. This is used to determine the left border of the graph, so that the indicator stops if the user's finger goes outside the bounds of the graph.
 *
 *  @param locationIndicatorImageView The location indicator image view requesting the pixel data.
 *
 *  @return The raw pixel data for the image.
 */
- (unsigned char *)pixelDataForCurrentImageInLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;

- (CGFloat)primaryAxisEndingValue;
- (CGFloat)secondaryAxisEndingValue;
- (CGFloat)primaryAxisStartingValue;
- (CGFloat)secondaryAxisStartingValue;
- (CGFloat)minimumSecondaryAxisValue;
@end

@protocol LocationIndicatorImageViewDelegate <NSObject>
@optional
/**
 *  Calls when a touch begins in the location indicator view.
 *
 *  @param location    	    	      The touch location returned as a CGPoint (xy coords).
 *  @param locationIndicatorImageView The location indicator image view in which the touch occurred.
 */
- (void)touchDidBeginAtLocation:(CGPoint)location inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;

/**
 *  Calls when a touch moves in the location indicator view.
 *
 *  @param location                   The touch location returned as a CGPoint (xy coords).
 *  @param locationIndicatorImageView The location indicator image view in which the touch occurred.
 */
- (void)touchDidMoveToLocation:(CGPoint)location inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;

/**
 *  Calls when a touch ends in the location indicator view.
 *
 *  @param location                   The touch location returned as a CGPoint (xy coords).
 *  @param locationIndicatorImageView The location indicator image view in which the touch occurred.
 */
- (void)touchDidEndAtLocation:(CGPoint)location inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;
@end
