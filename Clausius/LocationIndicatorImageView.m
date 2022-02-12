 //
//  LocationIndicatorImageView.m
//  Mvuke
//
//  Created by Austin Carrig on 5/18/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "LocationIndicatorImageView.h"
#import "UIColor+Mvuke.h"

static const CGFloat smallOuterRadius = 9.0f;
static const CGFloat innerRadius = 6.5f;
static const CGFloat smallOuterLineWidth = 0.75f;
static const CGFloat largeOuterLineWidth = 5.0f;
static const CGFloat hitmarkerLineWidth = 1.0f;
static const CGFloat largeOuterRadius = 60.0f;
static const CGFloat hitmarkerLength = 25.0f;
static const CGFloat TAU = 2*M_PI;
unsigned char *rawData;

@interface LocationIndicatorImageView ()
@property (nonatomic, strong) CAShapeLayer *locationIndicatorRingLayer;
@property (nonatomic, strong) CAShapeLayer *locationIndicatorCircleLayer;
@property (nonatomic, strong) CAShapeLayer *locationIndicatorHitmarkerLayer;
@end

@implementation LocationIndicatorImageView

#pragma mark - Custom Init Methods

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image sender:(id)sender
{
    self = [super initWithFrame:frame];
    if (self) {
	    self.dataSource = sender;
	    self.delegate = sender;
	    [self setUserInteractionEnabled:YES];
	    [self setBackgroundColor:[UIColor clearColor]];
	    [self setImage:image];
	    if ([_dataSource respondsToSelector:@selector(primaryColorForLocationView:)]) {
    	    _primaryColor = [_dataSource primaryColorForLocationView:self];
	    } else {
    	    _primaryColor = [UIColor primaryColor];
	    }
	    
	    rawData = [self getRGBAsFromImage:image
    	    	    	      inImageView:self];
    }
    return self;
}

#pragma mark - Lazy Init

-(CAShapeLayer *)locationIndicatorRingLayer
{
    if (!_locationIndicatorRingLayer) {
	    _locationIndicatorRingLayer = [CAShapeLayer layer];
	    _locationIndicatorRingLayer.path = [UIBezierPath bezierPath].CGPath;
	    _locationIndicatorRingLayer.fillColor = [[UIColor clearColor] CGColor];
	    _locationIndicatorRingLayer.strokeColor = [[self.primaryColor colorWithAlphaComponent:0.8] CGColor];
	    _locationIndicatorRingLayer.lineWidth = smallOuterLineWidth;
	    _locationIndicatorRingLayer.rasterizationScale = 2.0 * [[UIScreen mainScreen] scale];
	    _locationIndicatorRingLayer.shouldRasterize = YES;
    }
    return _locationIndicatorRingLayer;
}

-(CAShapeLayer *)locationIndicatorCircleLayer
{
    if (!_locationIndicatorCircleLayer) {
	    _locationIndicatorCircleLayer = [CAShapeLayer layer];
	    _locationIndicatorCircleLayer.path = [UIBezierPath bezierPath].CGPath;
	    _locationIndicatorCircleLayer.fillColor = [[self.primaryColor colorWithAlphaComponent:0.8] CGColor];
	    _locationIndicatorCircleLayer.strokeColor = [[UIColor clearColor] CGColor];
	    _locationIndicatorCircleLayer.rasterizationScale = 2.0 * [[UIScreen mainScreen] scale];
	    _locationIndicatorCircleLayer.shouldRasterize = YES;
    }
    return _locationIndicatorCircleLayer;
}

- (CAShapeLayer *)locationIndicatorHitmarkerLayer
{
    if (!_locationIndicatorHitmarkerLayer) {
	    _locationIndicatorHitmarkerLayer = [CAShapeLayer layer];
	    _locationIndicatorHitmarkerLayer.path = [UIBezierPath bezierPath].CGPath;
	    _locationIndicatorHitmarkerLayer.fillColor = [[UIColor clearColor] CGColor];
	    _locationIndicatorHitmarkerLayer.strokeColor = [[self.primaryColor colorWithAlphaComponent:0.8] CGColor];
	    _locationIndicatorHitmarkerLayer.lineWidth = hitmarkerLineWidth;
	    _locationIndicatorHitmarkerLayer.rasterizationScale = 2.0 * [[UIScreen mainScreen] scale];
	    _locationIndicatorHitmarkerLayer.shouldRasterize = YES;
    }
    
    return _locationIndicatorHitmarkerLayer;
}

#pragma mark - Responder Methods

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // edit to remove control from view
    if ((int)event.allTouches.count == 1) {
	    CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
	    CGFloat alphaOfPixel = 1.0;
	    
	    if ([self pointInside:touchLocation withEvent:event]) {
    	    UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
    	    alphaOfPixel = CGColorGetAlpha(color.CGColor);
	    } else {
    	    alphaOfPixel = 0.0;
	    }
	    
	    if ([self.delegate respondsToSelector:@selector(touchDidBeginAtLocation:inLocationView:)] && alphaOfPixel != 0.0) {
    	    [self.delegate touchDidBeginAtLocation:touchLocation inLocationView:self];
	    }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    // edit to remove control from view
    if ((int)event.allTouches.count == 1) {
	    CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
	    CGFloat alphaOfPixel = 1.0;
	    
	    if ([self pointInside:touchLocation withEvent:event]) {
    	    UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
    	    alphaOfPixel = CGColorGetAlpha(color.CGColor);
	    } else {
    	    alphaOfPixel = 0.0;
	    }
	    
	    if ([self.delegate respondsToSelector:@selector(touchDidMoveToLocation:inLocationView:)] && alphaOfPixel != 0.0) {
    	    [self.delegate touchDidMoveToLocation:touchLocation inLocationView:self];
	    }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    // new version to remove control from view
    if ((int)event.allTouches.count == 1) {
	    CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
	    CGFloat alphaOfPixel = 1.0;
	    
	    if ([self pointInside:touchLocation withEvent:event]) {
    	    UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
    	    alphaOfPixel = CGColorGetAlpha(color.CGColor);
	    } else {
    	    alphaOfPixel = 0.0;
	    }
	    
	    if ([self.delegate respondsToSelector:@selector(touchDidEndAtLocation:inLocationView:)] && alphaOfPixel != 0.0) {
    	    [self.delegate touchDidEndAtLocation:touchLocation inLocationView:self];
	    }
    }
}

#pragma mark - Marker Adjustment Methods

- (void)addLargeMarkerAtLocation:(CGPoint)location
{
    _lastLocation = location;
    
    UIGraphicsBeginImageContext(CGSizeMake(largeOuterRadius*2.0f, largeOuterRadius*2.0f));
    
    UIBezierPath *hitMarkerTop = [UIBezierPath bezierPath];
    UIBezierPath *hitMarkerBottom = [UIBezierPath bezierPath];
    UIBezierPath *hitMarkerLeft = [UIBezierPath bezierPath];
    UIBezierPath *hitMarkerRight = [UIBezierPath bezierPath];
    
    [hitMarkerTop moveToPoint:CGPointMake(location.x, location.y - largeOuterRadius)];
    [hitMarkerTop addLineToPoint:CGPointMake(location.x, location.y - largeOuterRadius + hitmarkerLength)];
    [hitMarkerTop stroke];
    
    [hitMarkerBottom moveToPoint:CGPointMake(location.x, location.y + largeOuterRadius)];
    [hitMarkerBottom addLineToPoint:CGPointMake(location.x, location.y + largeOuterRadius - hitmarkerLength)];
    [hitMarkerBottom stroke];
    
    [hitMarkerLeft moveToPoint:CGPointMake(location.x - largeOuterRadius, location.y)];
    [hitMarkerLeft addLineToPoint:CGPointMake(location.x  - largeOuterRadius + hitmarkerLength, location.y)];
    [hitMarkerLeft stroke];
    
    [hitMarkerRight moveToPoint:CGPointMake(location.x + largeOuterRadius, location.y)];
    [hitMarkerRight addLineToPoint:CGPointMake(location.x + largeOuterRadius - hitmarkerLength, location.y)];
    [hitMarkerRight stroke];
    
    CGMutablePathRef markers = CGPathCreateMutableCopy(hitMarkerTop.CGPath);
    CGPathAddPath(markers, NULL, hitMarkerBottom.CGPath);
    CGPathAddPath(markers, NULL, hitMarkerLeft.CGPath);
    CGPathAddPath(markers, NULL, hitMarkerRight.CGPath);
    
    CGPathMoveToPoint(markers, NULL, location.x, location.y);
    
    [self.locationIndicatorHitmarkerLayer setPath:markers];
    [self.layer addSublayer:self.locationIndicatorHitmarkerLayer];
    
    UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:location
	    	    	    	    	    	    	    	    	     radius:largeOuterRadius
    	    	    	    	    	    	    	    	     startAngle:0.0f
    	    	    	    	    	    	    	    	       endAngle:TAU
    	    	    	    	    	    	    	    	      clockwise:YES];
    
    self.locationIndicatorRingLayer.lineWidth = largeOuterLineWidth;
    
    [self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
    [self.layer addSublayer:self.locationIndicatorRingLayer];
    
    CGPathRelease(markers);
    UIGraphicsEndImageContext();
    
    UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:location
	    	    	    	    	    	    	    	    	       radius:innerRadius
    	    	    	    	    	    	    	    	       startAngle:0.0f
	    	    	    	    	    	    	    	    	     endAngle:TAU
	    	    	    	    	    	    	    	    	    clockwise:YES];
    [self.locationIndicatorCircleLayer setPath:[locationIndicatorCircle CGPath]];
    [self.layer addSublayer:self.locationIndicatorCircleLayer];
}

- (void)moveLargeMarkerToLocation:(CGPoint)location
{
    if ([self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer]) {
	    CGAffineTransform transform = CGAffineTransformMakeTranslation(location.x - self.lastLocation.x,
    	    	    	    	    	    	    	    	       location.y - self.lastLocation.y);
	    
	    CGPathRef markers = CGPathCreateCopyByTransformingPath(self.locationIndicatorHitmarkerLayer.path,
    	    	    	    	    	    	    	       &transform);
	    [self.locationIndicatorHitmarkerLayer setPath:markers];
	    
	    CGPathRef locationIndicatorRing = CGPathCreateCopyByTransformingPath(self.locationIndicatorRingLayer.path,
    	    	    	    	    	    	    	    	    	     &transform);
	    [self.locationIndicatorRingLayer setPath:locationIndicatorRing];
	    
	    CGPathRef locationIndicatorCircle = CGPathCreateCopyByTransformingPath(self.locationIndicatorCircleLayer.path,
    	    	    	    	    	    	    	    	    	       &transform);
	    [self.locationIndicatorCircleLayer setPath:locationIndicatorCircle];
	    
	    CGPathRelease(markers);
	    CGPathRelease(locationIndicatorRing);
	    CGPathRelease(locationIndicatorCircle);
    } else {
	    CGAffineTransform transform = CGAffineTransformMakeTranslation(location.x - self.lastLocation.x,
    	    	    	    	    	    	    	    	       location.y - self.lastLocation.y);
	    
	    CGPathRef markers = CGPathCreateCopyByTransformingPath(self.locationIndicatorHitmarkerLayer.path,
    	    	    	    	    	    	    	       &transform);
	    [self.locationIndicatorHitmarkerLayer setPath:markers];
	    [self.layer addSublayer:self.locationIndicatorHitmarkerLayer];
	    
	    CGPathRef locationIndicatorRing = CGPathCreateCopyByTransformingPath(self.locationIndicatorRingLayer.path,
	    	    	    	    	    	    	    	    	      &transform);
	    [self.locationIndicatorRingLayer setPath:locationIndicatorRing];
	    [self.layer addSublayer:self.locationIndicatorRingLayer];
	    
	    CGPathRef locationIndicatorCircle = CGPathCreateCopyByTransformingPath(self.locationIndicatorCircleLayer.path,
    	    	    	    	    	    	    	    	    	       &transform);
	    [self.locationIndicatorCircleLayer setPath:locationIndicatorCircle];
	    [self.layer addSublayer:self.locationIndicatorCircleLayer];
	    
	    CGPathRelease(markers);
	    CGPathRelease(locationIndicatorRing);
	    CGPathRelease(locationIndicatorCircle);
    }
    
    _lastLocation = location;
}

- (void)addSmallMarkerAtLocation:(CGPoint)location
{
    self.locationIndicatorRingLayer.lineWidth = smallOuterLineWidth;
    
    if ([self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer]) {
	    UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:location
    	    	    	    	    	    	    	    	    	     radius:smallOuterRadius
	    	    	    	    	    	    	    	    	     startAngle:0.0f
	    	    	    	    	    	    	    	    	       endAngle:TAU
	    	    	    	    	    	    	    	    	      clockwise:YES];
	    [self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
	    
	    UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:location
    	    	    	    	    	    	    	    	    	       radius:innerRadius
	    	    	    	    	    	    	    	    	       startAngle:0.0f
    	    	    	    	    	    	    	    	    	     endAngle:TAU
    	    	    	    	    	    	    	    	    	    clockwise:YES];
	    [self.locationIndicatorCircleLayer setPath:locationIndicatorCircle.CGPath];
    } else {
	    UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:location
    	    	    	    	    	    	    	    	    	     radius:smallOuterRadius
	    	    	    	    	    	    	    	    	     startAngle:0.0f
	    	    	    	    	    	    	    	    	       endAngle:TAU
	    	    	    	    	    	    	    	    	      clockwise:YES];
	    [self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
	    [self.layer addSublayer:self.locationIndicatorRingLayer];
	    
	    UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:location
    	    	    	    	    	    	    	    	    	       radius:innerRadius
	    	    	    	    	    	    	    	    	       startAngle:0.0f
    	    	    	    	    	    	    	    	    	     endAngle:TAU
    	    	    	    	    	    	    	    	    	    clockwise:YES];
	    [self.locationIndicatorCircleLayer setPath:locationIndicatorCircle.CGPath];
	    [self.layer addSublayer:self.locationIndicatorCircleLayer];
    }
    [self.locationIndicatorHitmarkerLayer removeFromSuperlayer];
    
    _lastLocation = location;
}

- (void)removeMarker
{
    [self.locationIndicatorCircleLayer removeFromSuperlayer];
    [self.locationIndicatorRingLayer removeFromSuperlayer];
}

#pragma mark - Image Scanning Methods

- (CGFloat)valueOfIntersection:(NSArray *)colorsForLine forImage:(UIImage *)image inImageView:(UIImageView *)imageView
{
    return [self checkMiddleAlphaWithSetOfColors:colorsForLine withFirstIndex:0 withLastIndex:colorsForLine.count-1] * imageView.frame.size.width/image.size.width;
}

- (CGFloat)checkMiddleAlphaWithSetOfColors:(NSArray *)alphas withFirstIndex:(NSUInteger)first withLastIndex:(NSUInteger)last
{
    NSUInteger middleIndex = (first + last)/2;
    CGFloat middleAlpha = CGColorGetAlpha([(UIColor *)[alphas objectAtIndex:middleIndex] CGColor]);
    if(first == last || first + 1 == last) {
	    return (CGFloat)first;
    } else if (middleAlpha == 0.0) {
	    return (CGFloat)[self checkMiddleAlphaWithSetOfColors:alphas withFirstIndex:middleIndex withLastIndex:last];
    } else if (middleAlpha > 0.0) {
	    return (CGFloat)[self checkMiddleAlphaWithSetOfColors:alphas withFirstIndex:first withLastIndex:middleIndex];
    } else {
	    NSLog(@"Alg. ERROR: No alpha value found");
	    return 0.0;
    }
}

- (NSArray*)getRGBAsFromImage:(UIImage*)image inImageView:(UIImageView *)imageView atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    count = (int)((CGFloat)count * image.size.width/imageView.frame.size.width) + 1;
    int imagex = (int)((float)x * image.size.width/imageView.frame.size.width);
    int imagey = (int)((float)y * image.size.height/imageView.frame.size.height);
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * imagey) + imagex * bytesPerPixel;
    
    if (rawData) {
	    for (int i = 0 ; i < count ; ++i) {
    	    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    	    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    	    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    	    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    	    byteIndex += bytesPerPixel;
    	    
    	    UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    	    [result addObject:acolor];
	    }
    }
    
    return result;
}

- (unsigned char *)getRGBAsFromImage:(UIImage*)image inImageView:(UIImageView *)imageView
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
	    	    	    	    	    	     bitsPerComponent, bytesPerRow, colorSpace,
	    	    	    	    	    	     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return rawData;
}

#pragma mark - User Movement Methods

- (BOOL)pointIsWithinBoundsForPrimaryAxisValue:(CGFloat)primValue
    	    	    	    secondaryAxisValue:(CGFloat)secValue
{
    CGFloat primaryAxisRange = [self.dataSource primaryAxisEndingValue] - [self.dataSource primaryAxisStartingValue];;
    CGFloat secondaryAxisRange = [self.dataSource secondaryAxisEndingValue] - [self.dataSource secondaryAxisStartingValue];;
    
    CGFloat xValue;
    CGFloat yValue;
    
    if (self.chart.xAxis.scaleType == RUAxisScaleTypeLinear) {
	    xValue = ((primValue - [self.dataSource primaryAxisStartingValue])*self.frame.size.width/primaryAxisRange);
    } else {
	    xValue = (log10f(primValue) - log10f([self.dataSource primaryAxisStartingValue]))/((log10f([self.dataSource primaryAxisEndingValue]) - log10f([self.dataSource primaryAxisStartingValue]))/self.frame.size.width);
    }
    
    if (self.chart.yAxis.scaleType == RUAxisScaleTypeLinear) {
	    yValue = self.frame.size.height - ((secValue - [self.dataSource secondaryAxisStartingValue])*self.frame.size.height/secondaryAxisRange);
    } else {
	    yValue = self.frame.size.height - (log10f(secValue) - log10f([self.dataSource secondaryAxisStartingValue]))/((log10f([self.dataSource secondaryAxisEndingValue]) - log10f([self.dataSource secondaryAxisStartingValue]))/self.frame.size.height);
    }
    
    UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:xValue andY:yValue count:1] lastObject];
    
    if (CGColorGetAlpha(color.CGColor) != 0.0 && primValue < [self.dataSource primaryAxisEndingValue] && primValue > [self.dataSource primaryAxisStartingValue] && secValue < [self.dataSource secondaryAxisEndingValue] && secValue > [self.dataSource secondaryAxisStartingValue]) {
	    return YES;
    } else {
	    return NO;
    }
}

- (void)moveMarkerToPrimaryAxisValue:(CGFloat)primValue secondaryAxisValue:(CGFloat)secValue
{
    if ([self respondsToAllProperSelectors]) {
	    CGFloat xValue;
	    CGFloat yValue;
	    
	    CGFloat primaryAxisRange = [self.dataSource primaryAxisEndingValue] - [self.dataSource primaryAxisStartingValue];
	    CGFloat secondaryAxisRange = [self.dataSource secondaryAxisEndingValue] - [self.dataSource secondaryAxisStartingValue];
	    
	    if (self.chart.xAxis.scaleType == RUAxisScaleTypeLinear) {
    	    xValue = ((primValue - [self.dataSource primaryAxisStartingValue])*self.frame.size.width/primaryAxisRange);
	    } else {
    	    xValue = (log10f(primValue) - log10f([self.dataSource primaryAxisStartingValue]))/((log10f([self.dataSource primaryAxisEndingValue]) - log10f([self.dataSource primaryAxisStartingValue]))/self.frame.size.width);
	    }
	    
	    if (self.chart.yAxis.scaleType == RUAxisScaleTypeLinear) {
    	    yValue = self.frame.size.height - ((secValue - [self.dataSource secondaryAxisStartingValue])*self.frame.size.height/secondaryAxisRange);
	    } else {
    	    yValue = self.frame.size.height - (log10f(secValue) - log10f([self.dataSource secondaryAxisStartingValue]))/((log10f([self.dataSource secondaryAxisEndingValue]) - log10f([self.dataSource secondaryAxisStartingValue]))/self.frame.size.height);
	    }
	    
	    CGPoint pointerLocation = CGPointMake(xValue, yValue);
	    
	    UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:pointerLocation
    	    	    	    	    	    	    	    	    	     radius:smallOuterRadius
	    	    	    	    	    	    	    	    	     startAngle:0.0f
	    	    	    	    	    	    	    	    	       endAngle:360.0f
	    	    	    	    	    	    	    	    	      clockwise:YES];
	    [self.locationIndicatorRingLayer setPath:[locationIndicatorRing CGPath]];
	    [self.layer addSublayer:self.locationIndicatorRingLayer];
	    
	    UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:pointerLocation
    	    	    	    	    	    	    	    	    	       radius:innerRadius
	    	    	    	    	    	    	    	    	       startAngle:0.0f
    	    	    	    	    	    	    	    	    	     endAngle:360.0f
	    	    	    	    	    	    	    	       clockwise:YES];
	    [self.locationIndicatorCircleLayer setPath:[locationIndicatorCircle CGPath]];
	    [self.layer addSublayer:self.locationIndicatorCircleLayer];
    }
}

#pragma mark - Instance Methods

- (void)resetImage:(UIImage *)image
{
    self.image = image;
    
    free(rawData);
    rawData = [self getRGBAsFromImage:image
	    	    	      inImageView:self];
}

#pragma mark - Private Methods

- (BOOL)respondsToAllProperSelectors
{
    return [self.dataSource respondsToSelector:@selector(primaryAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(primaryAxisEndingValue)] && [self.dataSource respondsToSelector:@selector(secondaryAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(secondaryAxisEndingValue)];
}

@end
