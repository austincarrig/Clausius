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
		if ([self.dataSource respondsToSelector:@selector(primaryColorForLocationView:)]) {
			_primaryColor = [self.dataSource primaryColorForLocationView:self];
		} else {
			_primaryColor = [UIColor primaryColor];
		}
		
		rawData = [self getRGBAsFromImage:self.image
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

#pragma mark - Public Methods

- (void)resetImage:(UIImage *)image
{
	self.image = image;
	
	free(rawData);
	rawData = [self getRGBAsFromImage:image
						  inImageView:self];
}

#pragma mark - Responder Methods

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
		
	if ((int)event.allTouches.count == 1) {
		CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
		CGPoint pointerLocation = touchLocation;
		CGFloat alphaOfPixel = 1.0;
		
		lastLocation = pointerLocation;
		
		if ([self pointInside:touchLocation withEvent:event]) {
			UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
			alphaOfPixel = CGColorGetAlpha(color.CGColor);
		} else {
			alphaOfPixel = 0.0;
		}
		
		if ([self.dataSource respondsToSelector:@selector(xAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(xAxisEndingValue)] && [self.dataSource respondsToSelector:@selector(yAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(yAxisEndingValue)]) {
			float secondaryAxisValue = [self.dataSource yAxisStartingValue] + ([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue])*(self.frame.size.height - touchLocation.y)/self.frame.size.height;
			
			if ([self.dataSource respondsToSelector:@selector(minimumYAxisValue)]) {
				if (secondaryAxisValue < [self.dataSource minimumYAxisValue]) {
					CGFloat newY = ((fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]) - fabs([self.dataSource minimumYAxisValue] - [self.dataSource yAxisStartingValue]))/fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]))*self.frame.size.height;
					pointerLocation = CGPointMake(pointerLocation.x, newY);
				}
			}
		}
		
		if (alphaOfPixel != 0.0) {
			UIGraphicsBeginImageContext(CGSizeMake(largeOuterRadius*2.0f, largeOuterRadius*2.0f));
			
			UIBezierPath *hitMarkerTop = [UIBezierPath bezierPath];
			UIBezierPath *hitMarkerBottom = [UIBezierPath bezierPath];
			UIBezierPath *hitMarkerLeft = [UIBezierPath bezierPath];
			UIBezierPath *hitMarkerRight = [UIBezierPath bezierPath];
			
			[hitMarkerTop moveToPoint:CGPointMake(pointerLocation.x, pointerLocation.y - largeOuterRadius)];
			[hitMarkerTop addLineToPoint:CGPointMake(pointerLocation.x, pointerLocation.y - largeOuterRadius + hitmarkerLength)];
			[hitMarkerTop stroke];
			
			[hitMarkerBottom moveToPoint:CGPointMake(pointerLocation.x, pointerLocation.y + largeOuterRadius)];
			[hitMarkerBottom addLineToPoint:CGPointMake(pointerLocation.x, pointerLocation.y + largeOuterRadius - hitmarkerLength)];
			[hitMarkerBottom stroke];
			
			[hitMarkerLeft moveToPoint:CGPointMake(pointerLocation.x - largeOuterRadius, pointerLocation.y)];
			[hitMarkerLeft addLineToPoint:CGPointMake(pointerLocation.x  - largeOuterRadius + hitmarkerLength, pointerLocation.y)];
			[hitMarkerLeft stroke];
			
			[hitMarkerRight moveToPoint:CGPointMake(pointerLocation.x + largeOuterRadius, pointerLocation.y)];
			[hitMarkerRight addLineToPoint:CGPointMake(pointerLocation.x + largeOuterRadius - hitmarkerLength, pointerLocation.y)];
			[hitMarkerRight stroke];
			
			CGMutablePathRef markers = CGPathCreateMutableCopy(hitMarkerTop.CGPath);
			CGPathAddPath(markers, NULL, hitMarkerBottom.CGPath);
			CGPathAddPath(markers, NULL, hitMarkerLeft.CGPath);
			CGPathAddPath(markers, NULL, hitMarkerRight.CGPath);
			
			CGPathMoveToPoint(markers, NULL, pointerLocation.x, pointerLocation.y);
			
			[self.locationIndicatorHitmarkerLayer setPath:markers];
			[self.layer addSublayer:self.locationIndicatorHitmarkerLayer];
			
			UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				 radius:largeOuterRadius
																			 startAngle:0.0f
																			   endAngle:TAU
																			  clockwise:YES];
			
			self.locationIndicatorRingLayer.lineWidth = largeOuterLineWidth;
			
			[self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
			[self.layer addSublayer:self.locationIndicatorRingLayer];
			
			CGPathRelease(markers);
			UIGraphicsEndImageContext();
			
			UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				   radius:innerRadius
																			   startAngle:0.0f
																				 endAngle:TAU
																				clockwise:YES];
			[self.locationIndicatorCircleLayer setPath:[locationIndicatorCircle CGPath]];
			[self.layer addSublayer:self.locationIndicatorCircleLayer];
		}
		
		if ([self.delegate respondsToSelector:@selector(touchDidBeginAtLocation:inLocationView:)] && alphaOfPixel != 0.0) {
			[self.delegate touchDidBeginAtLocation:touchLocation inLocationView:self];
		}
	}
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	if ((int)event.allTouches.count == 1) {
		CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
		CGPoint pointerLocation = touchLocation;
		CGFloat alphaOfPixel = 1.0;
		
		if ([self pointInside:touchLocation withEvent:event]) {
			UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
			alphaOfPixel = CGColorGetAlpha(color.CGColor);
		} else {
			alphaOfPixel = 0.0;
		}
		
		float secondaryAxisValue;
		
		if ([self.dataSource respondsToSelector:@selector(xAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(xAxisEndingValue)] && [self.dataSource respondsToSelector:@selector(yAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(yAxisEndingValue)]) {
			secondaryAxisValue = [self.dataSource yAxisStartingValue] + ([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue])*(self.frame.size.height - touchLocation.y)/self.frame.size.height;
			
			if ([self.dataSource respondsToSelector:@selector(minimumYAxisValue)]) {
				if (secondaryAxisValue < [self.dataSource minimumYAxisValue]) {
					CGFloat newY = ((fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]) - fabs([self.dataSource minimumYAxisValue] - [self.dataSource yAxisStartingValue]))/fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]))*self.frame.size.height;
					
					pointerLocation = CGPointMake(pointerLocation.x, newY);
				}
			}
		}
		
		if (alphaOfPixel != 0.0 && [self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer]) {
			CGAffineTransform transform = CGAffineTransformMakeTranslation(touchLocation.x - lastLocation.x,
																		   touchLocation.y - lastLocation.y);
			lastLocation = pointerLocation;
			
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
		} else if (alphaOfPixel != 0 && !([self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer])) {
			CGAffineTransform transform = CGAffineTransformMakeTranslation(touchLocation.x - lastLocation.x,
																		   touchLocation.y - lastLocation.y);
			lastLocation = pointerLocation;
			
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
		
		if ([self.delegate respondsToSelector:@selector(touchDidMoveToLocation:inLocationView:)] && alphaOfPixel != 0.0) {
			[self.delegate touchDidMoveToLocation:touchLocation inLocationView:self];
		}
	}
}
/*
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	if ((int)event.allTouches.count == 1) {
		CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self];
		CGPoint pointerLocation = touchLocation;
		CGFloat alphaOfPixel = 1.0;
		
		self.locationIndicatorRingLayer.lineWidth = smallOuterLineWidth;
		
		if ([self pointInside:touchLocation withEvent:event]) {
			UIColor *color = (UIColor *)[[self getRGBAsFromImage:self.image inImageView:self atX:touchLocation.x andY:touchLocation.y count:1] lastObject];
			alphaOfPixel = CGColorGetAlpha(color.CGColor);
		} else {
			alphaOfPixel = 0.0;
		}
		
		float secondaryAxisValue;
		
		if ([self.dataSource respondsToSelector:@selector(xAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(xAxisEndingValue)] && [self.dataSource respondsToSelector:@selector(yAxisStartingValue)] && [self.dataSource respondsToSelector:@selector(yAxisEndingValue)]) {
			secondaryAxisValue = [self.dataSource yAxisStartingValue] + ([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue])*(self.frame.size.height - touchLocation.y)/self.frame.size.height;
			
			if ([self.dataSource respondsToSelector:@selector(minimumYAxisValue)]) {
				if (secondaryAxisValue < [self.dataSource minimumYAxisValue]) {
					CGFloat newY = ((fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]) - fabs([self.dataSource minimumYAxisValue] - [self.dataSource yAxisStartingValue]))/fabs([self.dataSource yAxisEndingValue] - [self.dataSource yAxisStartingValue]))*self.frame.size.height;
					
					pointerLocation = CGPointMake(pointerLocation.x, newY);
				}
			}
		}
		
		if (alphaOfPixel != 0.0 && [self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer]) {
			UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				 radius:smallOuterRadius
																			 startAngle:0.0f
																			   endAngle:TAU
																			  clockwise:YES];
			[self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
			
			UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				   radius:innerRadius
																			   startAngle:0.0f
																				 endAngle:TAU
																				clockwise:YES];
			[self.locationIndicatorCircleLayer setPath:locationIndicatorCircle.CGPath];
		} else if (alphaOfPixel != 0.0 && !([self.locationIndicatorCircleLayer.superlayer isEqual:self.layer] && [self.locationIndicatorRingLayer.superlayer isEqual:self.layer])) {
			UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				 radius:smallOuterRadius
																			 startAngle:0.0f
																			   endAngle:TAU
																			  clockwise:YES];
			[self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
			[self.layer addSublayer:self.locationIndicatorRingLayer];
			
			UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:pointerLocation
																				   radius:innerRadius
																			   startAngle:0.0f
																				 endAngle:TAU
																				clockwise:YES];
			[self.locationIndicatorCircleLayer setPath:locationIndicatorCircle.CGPath];
			[self.layer addSublayer:self.locationIndicatorCircleLayer];
		} else {
			UIBezierPath *locationIndicatorRing = [UIBezierPath bezierPathWithArcCenter:lastLocation
																				 radius:smallOuterRadius
																			 startAngle:0.0f
																			   endAngle:TAU
																			  clockwise:YES];
			[self.locationIndicatorRingLayer setPath:locationIndicatorRing.CGPath];
			[self.layer addSublayer:self.locationIndicatorRingLayer];
			
			UIBezierPath *locationIndicatorCircle = [UIBezierPath bezierPathWithArcCenter:lastLocation
																				   radius:innerRadius
																			   startAngle:0.0f
																				 endAngle:TAU
																				clockwise:YES];
			[self.locationIndicatorCircleLayer setPath:locationIndicatorCircle.CGPath];
			[self.layer addSublayer:self.locationIndicatorCircleLayer];
		}
		[self.locationIndicatorHitmarkerLayer removeFromSuperlayer];
	}
}
*/
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

#pragma mark - Instance Methods

- (void)removeMarker
{
	[self.locationIndicatorCircleLayer removeFromSuperlayer];
	[self.locationIndicatorRingLayer removeFromSuperlayer];
}

@end
