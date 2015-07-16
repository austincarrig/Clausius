//
//  LocationIndicatorImageView.h
//  Mvuke
//
//  Created by Austin Carrig on 5/18/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationIndicatorImageViewDataSource;
@protocol LocationIndicatorImageViewDelegate;

@interface LocationIndicatorImageView : UIImageView

@property (strong, nonatomic) UIBezierPath *horizontalIndicator;
@property (strong, nonatomic) UIBezierPath *verticalIndicator;
@property (strong, nonatomic) UIColor *primaryColor;

@property (strong, nonatomic) id <LocationIndicatorImageViewDataSource> dataSource;
@property (strong, nonatomic) id <LocationIndicatorImageViewDelegate> delegate;

@property (strong, nonatomic) NSNumber *xMin;
@property (strong, nonatomic) NSNumber *xMax;
@property (strong, nonatomic) NSNumber *yMin;
@property (strong, nonatomic) NSNumber *yMax;

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image sender:(id)sender;

@end

@protocol LocationIndicatorImageViewDataSource <NSObject>
@optional
- (UIColor *)primaryColorForLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;
- (unsigned char *)pixelDataForCurrentImageInLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;
- (CGFloat)primaryAxisEndingValue;
- (CGFloat)secondaryAxisEndingValue;
- (CGFloat)primaryAxisStartingValue;
- (CGFloat)secondaryAxisStartingValue;
- (CGFloat)minimumSecondaryAxisValue;
@end

@protocol LocationIndicatorImageViewDelegate <NSObject>
@optional
- (void)touchDidBeginAtLocation:(CGPoint)location inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;
- (void)touchDidMoveToLocation:(CGPoint)location inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView;
@end