//
//  ViewController.m
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "RUAPopupView.h"

#import "Constants.h"

#import "Masonry.h"
#import "UIColor+Mvuke.h"
#import "CoreData.h"
#import "H2O_Wagner_Pruss.h"

#import "RUDataSelector.h"
#import "RUASpaceController.h"

#import "RUAxis.h"

const static float T_CRITICAL = 373.9;  // Critical temperature of water in C
const static float P_CRITICAL = 22100.; // Critical pressure of water in kPA
const static float T_SAT_MIN = 1.0; // Minimum temperature to display on the ts diagram in C
const static float T_TOTAL_CHANGE = 10.0;
const static float S_TOTAL_CHANGE = 0.1;
const static float X_TOTAL_CHANGE = 0.01;

@interface ViewController () {
	CGPoint lastTouchLocation;
	int shouldFineTune;
	BOOL hasFineTuned;
}
@property (strong, nonatomic) UIImageView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) LocationIndicatorImageView *chartView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIView *secondContainerView;
@property (strong, nonatomic) DisplayView *displayView;
@property (strong, nonatomic) RUASpaceController *spaceController;

@property (strong, nonatomic) H2O_Wagner_Pruss *wagPruss;

@property (strong, nonatomic) NSArray *superheatedKeys;
@property (strong, nonatomic) NSArray *superheatedValues;
@property (strong, nonatomic) NSArray *superheatedMappingKeys;

@property (strong, nonatomic) NSArray *chartValueTypes;

@property (strong, nonatomic) RUAPopupView *popupView;

@end

@implementation ViewController

#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	/*
	// Show/hide nav bar
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:@selector(doubleTap)];
	
	[tap setNumberOfTapsRequired:2];
	[self.view addGestureRecognizer:tap];
	*/
	
	touchHasRegistered = NO;
	allowQualityScrubbing = NO;
	shouldFineTune = 0;
	hasFineTuned = NO;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[self.navigationController setNavigationBarHidden:YES];
	
	[self.containerView addSubview:self.chartView];
	
	[self.view insertSubview:self.secondContainerView
				aboveSubview:self.containerView];
	
	[self.view insertSubview:self.infoView
				aboveSubview:self.secondContainerView];
	
	[self.containerView bringSubviewToFront:self.infoButton];
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	[self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.containerView);
	}];
	
	[self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.containerView);
	}];
	
	if (self.secondContainerView.superview != nil && self.chartView.image != nil) {
		[self.secondContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.containerView).with.offset(20.0);
			make.top.equalTo(self.containerView).with.offset(20.0);
			make.height.equalTo([NSNumber numberWithFloat:self.secondContainerView.frame.size.height]);
			make.width.equalTo([NSNumber numberWithFloat:self.secondContainerView.frame.size.width]);
		}];
	}
	
	[self.secondContainerView addSubview:self.displayView];
	
	[self chooseNewFileWithChartType:self.chartView.chart.substanceType valueType:@"ts"];
	
	UIScreenEdgePanGestureRecognizer *rightRecog = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
																									 action:@selector(resetChart:)];
	[rightRecog setEdges:UIRectEdgeRight];
	[rightRecog setCancelsTouchesInView:YES];
	
	[self.chartView addGestureRecognizer:rightRecog];
	
	UIScreenEdgePanGestureRecognizer *leftRecog = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
																									action:@selector(resetChart:)];
	
	[leftRecog setEdges:UIRectEdgeLeft];
	[leftRecog setCancelsTouchesInView:YES];
	
	[self.chartView addGestureRecognizer:leftRecog];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.view addSubview:self.popupView];
	[self.popupView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@(self.popupView.frame.size.height));
		make.width.equalTo(@(self.popupView.frame.size.width));
		make.center.equalTo(self.view);
	}];
	/*
	// Add Adjuster Views
	NSSet *tags = [self tagsForAdjusterViews];
	
	CGFloat height = self.displayView.containerViewHeight/self.displayView.numberOfRows;
	
	for (id tag in tags) {
		RUAAdjusterView *adjusterView = [[RUAAdjusterView alloc] initWithFrame:CGRectZero
																		   tag:[(NSNumber *)tag integerValue]];
		adjusterView.delegate = self;
		[adjusterView setBackgroundColor:[UIColor clearColor]];
		[self.secondContainerView addSubview:adjusterView];
		[self.secondContainerView bringSubviewToFront:adjusterView];
		
		[adjusterView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.secondContainerView);
			make.right.equalTo(self.secondContainerView);
			make.top.equalTo([NSNumber numberWithFloat:(height*([(NSNumber *)tag floatValue] - 1) + self.displayView.containerViewOriginY + 2.0f)]);
			make.height.equalTo([NSNumber numberWithFloat:height - 4.0f]);
		}];
	}
	 */
}

- (NSSet *)tagsForAdjusterViews
{
	return [NSSet setWithObjects:@1, @2, @6, @7, nil];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

#pragma mark - Lazy Init

- (LocationIndicatorImageView *)chartView
{
	if (!_chartView) {
		_chartView = (LocationIndicatorImageView *)[[LocationIndicatorImageView alloc] initWithFrame:self.containerView.frame
																							   image:[UIImage imageNamed:@"Water_ts_chart.png"]
																							  sender:self];
		
		[_chartView setChart:[RUChart chartWithChartType:@"ts"]];
	}
	return _chartView;
}

-(UIView *)displayView
{
	if (!_displayView) {
		_displayView = [[DisplayView alloc] initWithFrame:self.secondContainerView.frame];
		[_displayView setDataSource:self];
	}
	return _displayView;
}

-(UIView *)secondContainerView
{
	if (!_secondContainerView) {
		CGFloat height = 343.0f;
		CGFloat width = 225.0f;
		_secondContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	}
	return _secondContainerView;
}

-(UIImageView *)infoView
{
	if (!_infoView) {
		_infoView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[_infoView setImage:[UIImage imageNamed:@"Legend.png"]];
		[_infoView setHidden:YES];
		[_infoView setUserInteractionEnabled:NO];
		[_infoView setBackgroundColor:[UIColor whiteColor]];
		
		UIView *container = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 310, 310)];
		UITapGestureRecognizer *ytTap = [[UITapGestureRecognizer alloc] initWithTarget:self
																				action:@selector(showYoutubeVideo)];
		[ytTap setNumberOfTapsRequired:1];
		[container setUserInteractionEnabled:YES];
		[container addGestureRecognizer:ytTap];
		
		[_infoView addSubview:container];
		
		UIImageView *youtube = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
		[youtube setImage:[UIImage imageNamed:@"youtube.png"]];
		
		UITextView *textView1 = [[UITextView alloc] initWithFrame:CGRectMake(youtube.frame.origin.x + youtube.frame.size.width,
																			 youtube.frame.origin.y,
																			 250,
																			 youtube.frame.size.height/2.0)];
		UITextView *textView2 = [[UITextView alloc] initWithFrame:CGRectMake(youtube.frame.origin.x + youtube.frame.size.width,
																			 youtube.frame.origin.y + youtube.frame.size.height/2.0,
																			 250,
																			 youtube.frame.size.height/2.0)];
		UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
		
		[textView1 setText:@"Learn about Thermodynamic"];
		[textView1 setFont:font];
		[textView1 setTextContainerInset:UIEdgeInsetsMake(11.0, 4.0, 4.0, 0.0)];
		[textView1 setUserInteractionEnabled:NO];
		
		[textView2 setText:@"Properties of Water"];
		[textView2 setFont:font];
		[textView2 setTextContainerInset:UIEdgeInsetsMake(0.0, 4.0, 0.0, 0.0)];
		[textView2 setUserInteractionEnabled:NO];
		
		[container addSubview:youtube];
		[container addSubview:textView1];
		[container addSubview:textView2];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																			  action:@selector(dismissInfo)];
		[tap setNumberOfTapsRequired:1];
		
		[_infoView addGestureRecognizer:tap];
	}
	return _infoView;
}

- (void)showYoutubeVideo
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=rJR-6OEw09k"]
									   options:@{}
							 completionHandler:nil];
}

- (H2O_Wagner_Pruss *)wagPruss
{
	if (!_wagPruss) {
		_wagPruss = [[H2O_Wagner_Pruss alloc] initEOS];
	}
	return _wagPruss;
}

- (NSArray *)superheatedValues
{
	if (!_superheatedValues) {
		_superheatedValues = [[NSArray alloc] init];
	}
	return _superheatedValues;
}

- (NSArray *)superheatedKeys
{
	if (!_superheatedKeys) {
		_superheatedKeys = [[NSArray alloc] init];
	}
	return _superheatedKeys;
}

- (NSArray *)chartValueTypes
{
	if (!_chartValueTypes) {
		_chartValueTypes = [NSArray arrayWithObjects:@"ts",@"ph",@"pv", nil];
	}
	return _chartValueTypes;
}

- (RUAPopupView *)popupView
{
	if (!_popupView) {
		_popupView = [[RUAPopupView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 160.0f) text:@"t-s"];
	}
	return _popupView;
}

- (RUASpaceController *)spaceController
{
	if (!_spaceController) {
		_spaceController = [[RUASpaceController alloc] init];
		// NOTE: Seems like (10/8.0 and 10/9.0) and 20/30.0 felt best of ones I tried. Could use some refining.
		_spaceController.numPoints = 14;
		_spaceController.maxDiff = 9.0;
	}
	
	return _spaceController;
}

#pragma mark - Gesture Selectors

- (IBAction)displayInfo:(id)sender {
	[self.infoView setHidden:NO];
	[self.infoView setUserInteractionEnabled:YES];
}

-(void)dismissInfo
{
	[self.infoView setHidden:YES];
	[self.infoView setUserInteractionEnabled:NO];
}

-(void)doubleTap
{
	[self.popupView showHideAnimated:YES];
	/*
	if (self.navigationController.isNavigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	} else {	
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
	 */
}

- (void)resetChart:(UIScreenEdgePanGestureRecognizer *)recog
{
	[self.popupView.layer removeAllAnimations];
	if (recog.state == UIGestureRecognizerStateEnded) {
		NSInteger index = [self.chartValueTypes indexOfObject:self.chartView.chart.valueType];
		NSLog(@"%@, %@", self.chartValueTypes[((index+1)+3)%3], self.chartValueTypes[((index-1)+3)%3]);
		
		NSString *type;
		
		if (recog.edges == UIRectEdgeRight) {
			type = self.chartValueTypes[((index+1)+3)%3];
		} else if (recog.edges == UIRectEdgeLeft) {
			type = self.chartValueTypes[((index-1)+3)%3];
		}
		
		NSString *letter1 = [type substringToIndex:1];
		NSString *letter2 = [type substringFromIndex:1];
		
		NSString *displayName = [NSString stringWithFormat:@"%@-%@",letter1.uppercaseString,letter2];
		self.popupView.text = displayName;
		
		[self.chartView resetImage:[UIImage imageNamed:[NSString stringWithFormat:@"Water_%@_chart.png",type]]];
		self.chartView.chart = [RUChart chartWithChartType:type];
		[self inspectInfoButtonWithChartValueType:type];
		[self chooseNewFileWithChartType:self.chartView.chart.substanceType valueType:type];
		
		[self.secondContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.containerView).with.offset(20.0);
			make.height.equalTo([NSNumber numberWithFloat:self.secondContainerView.frame.size.height]);
			make.width.equalTo([NSNumber numberWithFloat:self.secondContainerView.frame.size.width]);
		}];
		
		if (self.chartView.chart.displayPosition == RUChartDisplayPositionLeft) {
			[self.secondContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.containerView).with.offset(20.0);
			}];
		} else if (self.chartView.chart.displayPosition == RUChartDisplayPositionRight) {
			[self.secondContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(self.containerView).with.offset(-20.0);
			}];
		}
		
		[self.popupView showHideAnimated:YES];
		
		if (touchHasRegistered) {
			if ([self.chartView.chart.valueType isEqualToString:@"ph"]) {
				if ([self.chartView pointIsWithinBoundsForPrimaryAxisValue:currentEnthalpy secondaryAxisValue:currentPressure]) {
					[self.chartView moveMarkerToPrimaryAxisValue:currentEnthalpy
											  secondaryAxisValue:currentPressure];
				} else {
					[self.chartView removeMarker];
				}
			} else if ([self.chartView.chart.valueType isEqualToString:@"pv"]) {
				if ([self.chartView pointIsWithinBoundsForPrimaryAxisValue:currentSpecVolume secondaryAxisValue:currentPressure]) {
					[self.chartView moveMarkerToPrimaryAxisValue:currentSpecVolume
											  secondaryAxisValue:currentPressure];
				} else {
					[self.chartView removeMarker];
				}
			} else if ([self.chartView.chart.valueType isEqualToString:@"ts"]) {
				if ([self.chartView pointIsWithinBoundsForPrimaryAxisValue:currentEntropy secondaryAxisValue:currentTemp]) {
					[self.chartView moveMarkerToPrimaryAxisValue:currentEntropy
											  secondaryAxisValue:currentTemp];
				} else {
					[self.chartView removeMarker];
				}
			} else {
				touchHasRegistered = NO;
				[self.chartView removeMarker];
			}
		}
	}
}

- (void)inspectInfoButtonWithChartValueType:(NSString *)type
{
	if ([type isEqualToString:@"ts"] && self.infoButton.isHidden) {
		[self.infoButton setHidden:NO];
	} else if (![type isEqualToString:@"ts"] && !self.infoButton.isHidden) {
		[self.infoButton setHidden:YES];
	}
}

#pragma mark - Location Indication Image View Datasource

- (UIColor *)primaryColorForLocationView:(LocationIndicatorImageView *)locationView
{
	return [UIColor primaryColor];
}

- (CGFloat)primaryAxisEndingValue
{
	return self.chartView.chart.xAxis.max.floatValue;
}

- (CGFloat)secondaryAxisEndingValue
{
	return self.chartView.chart.yAxis.max.floatValue;
}

- (CGFloat)primaryAxisStartingValue
{
	return self.chartView.chart.xAxis.min.floatValue;
}

- (CGFloat)secondaryAxisStartingValue
{
	return self.chartView.chart.yAxis.min.floatValue;
}

- (CGFloat)minimumSecondaryAxisValue
{
	return T_SAT_MIN;
}

#pragma mark - Display View Datasource

-(NSString *)nameForLabel:(UILabel *)label inDisplayView:(DisplayView *)displayView
{
	if (label.tag == 1) {
		return @"T";
	} else if (label.tag == 2) {
		return @"P";
	} else if (label.tag == 3) {
		return @"v";
	} else if (label.tag == 4) {
		return @"u";
	} else if (label.tag == 5) {
		return @"h";
	} else if (label.tag == 6) {
		return @"s";
	} else if (label.tag == 7) {
		return @"x";
	} else {
		return @"";
	}
}

-(NSString *)unitsForLabel:(UILabel *)label inDisplayView:(DisplayView *)displayView
{
	if (label.tag == 1) {
		return @"℃";
	} else if (label.tag == 2) {
		return @"kPa";
	} else if (label.tag == 3) {
		return @"m3/kg";
	} else if (label.tag == 4) {
		return @"kJ/kg";
	} else if (label.tag == 5) {
		return @"kJ/kg";
	} else if (label.tag == 6) {
		return @"kJ/kg.K";
	} else if (label.tag == 7) {
		return @"%";
	} else {
		return @"";
	}
}

#pragma mark - Location Indicator Image View Delegate

- (void)touchDidBeginAtLocation:(CGPoint)location
				 inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	if (!touchHasRegistered) {
		touchHasRegistered = YES;
	}
	
	[locationIndicatorImageView addLargeMarkerAtLocation:location];
	
	[self.spaceController addLatestPoint:location];
	hasFineTuned = NO;
	lastTouchLocation = location;
	
	if ([self.chartView.chart.valueType isEqualToString:@"ts"]) {
		[self tsTouchDidRegisterAtLocation:location
							 withEventType:@"Began"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"ph"]) {
		[self phTouchDidRegisterAtLocation:location
							 withEventType:@"Began"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"pv"]) {
		[self pvTouchDidRegisterAtLocation:location
							 withEventType:@"Began"
							inLocationView:locationIndicatorImageView];
	}
}

- (void)touchDidMoveToLocation:(CGPoint)location
				inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	CGPoint newLocation = location;
	
	if ([self.spaceController withinMarginWithLatestPoint:location] || hasFineTuned) {
		CGFloat lastLocationX = locationIndicatorImageView.lastLocation.x;
		CGFloat lastLocationY = locationIndicatorImageView.lastLocation.y;
		
		CGFloat actualDeltaX = location.x - lastTouchLocation.x;
		CGFloat actualDeltaY = location.y - lastTouchLocation.y;
		
		CGFloat deltaX = 0.2*(actualDeltaX);
		CGFloat deltaY = 0.2*(actualDeltaY);
		
		CGFloat newLocationX = lastLocationX + deltaX;
		CGFloat newLocationY = lastLocationY + deltaY;
		
		newLocation.x = newLocationX;
		newLocation.y = newLocationY;
		hasFineTuned = YES;
	}
	
	lastTouchLocation = location;
	
	[locationIndicatorImageView moveLargeMarkerToLocation:newLocation];
	
	if ([self.chartView.chart.valueType isEqualToString:@"ts"]) {
		[self tsTouchDidRegisterAtLocation:newLocation
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"ph"]) {
		[self phTouchDidRegisterAtLocation:newLocation
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"pv"]) {
		[self pvTouchDidRegisterAtLocation:newLocation
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	}
}

- (void)touchDidEndAtLocation:(CGPoint)location
			   inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	[locationIndicatorImageView addSmallMarkerAtLocation:locationIndicatorImageView.lastLocation];
	[self.spaceController reset];
}

- (void)touchDidRegisterAtLocation:(CGPoint)location
					 withEventType:(NSString *)eventType
					inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	RUChart *chart = ((LocationIndicatorImageView *)locationIndicatorImageView).chart;
	RUAxisValueType secondaryAxisType = chart.yAxis.valueType;
	
	CGFloat primaryScale, secondaryScale;
	
	// Find axis scales based on scale type
	primaryScale = [self scaleWithScaleType:chart.xAxis.scaleType
								inImageView:locationIndicatorImageView];
	secondaryScale = [self scaleWithScaleType:chart.yAxis.scaleType
								  inImageView:locationIndicatorImageView];
	
	float temperature = -1, pressure = -1, specVol = -1, intEnergy = -1, enthalpy = -1, entropy = -1, quality = -1;
	
	// Which secondary axis am I dealing with?
	if (secondaryAxisType == RUAxisValueTypeTemperature) {
		temperature = [self secondaryAxisStartingValue] + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y);
	} else if (secondaryAxisType == RUAxisValueTypePressure) {
		pressure = powf(10.0,log10f([self secondaryAxisStartingValue]) + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y));
	}
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temperature - 273.15]
											 pressure:[NSNumber numberWithFloat:pressure]
									   specificVolume:[NSNumber numberWithFloat:specVol]
									   internalEnergy:[NSNumber numberWithFloat:intEnergy]
											 enthalpy:[NSNumber numberWithFloat:enthalpy]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:(quality == -1 ? nil : [NSNumber numberWithFloat:quality*100])];
}

- (CGFloat)scaleWithScaleType:(RUAxisScaleType)type inImageView:(LocationIndicatorImageView *)view
{
	CGFloat primaryScale;
	
	switch (type) {
		case RUAxisScaleTypeLinear:
			// Linear
			primaryScale = ([self primaryAxisEndingValue] - [self primaryAxisStartingValue])/view.frame.size.width;
			break;
			
		case RUAxisScaleTypeLog:
			// Log
			primaryScale = (log10f([self primaryAxisEndingValue]) - log10f([self primaryAxisStartingValue]))/view.frame.size.width;
		default:
			primaryScale = 0;
			break;
	}
	
	return primaryScale;
}

- (void)pvTouchDidRegisterAtLocation:(CGPoint)location
					   withEventType:(NSString *)eventType
					  inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Get scales for both axes in units of [baseUnit/pixel]
	// If using log10f() the axis is log, converts value to exponent (i.e. b in value = 10^b, therefore b = log10(value))
	CGFloat primaryScale = (log10f([self primaryAxisEndingValue]) - log10f([self primaryAxisStartingValue]))/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = (log10f([self secondaryAxisEndingValue]) - log10f([self secondaryAxisStartingValue]))/locationIndicatorImageView.frame.size.height;
	
	// Calculate v & p given location on chart
	float specVol = powf(10.0,log10f([self primaryAxisStartingValue]) + primaryScale*location.x);
	float pressure = powf(10.0,log10f([self secondaryAxisStartingValue]) + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y));
	
	float temp, density = 1./specVol, intEnergy, enthalpy, entropy, quality = -1;
	
	if (pressure < P_CRITICAL) {
		temp = ((NSNumber *)[self.wagPruss accurateTemperatureVapourLiquidWithPressure:pressure/1000.0].firstObject).floatValue;
		SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)(temp - 273.15)
																					inContext:appDel.managedObjectContext];
		
		if (specVol < saturatedPoint.v_f.floatValue) {
			// Compressed Liquid Region
			intEnergy = saturatedPoint.u_f.floatValue;
			enthalpy = saturatedPoint.h_f.floatValue;
			entropy = saturatedPoint.s_f.floatValue;
		} else if (specVol >= saturatedPoint.v_f.floatValue && specVol <= saturatedPoint.v_g.floatValue) {
			// Saturated Vapor (Mixture) Region
			quality = (specVol - [saturatedPoint.v_f floatValue])/([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
			intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
			enthalpy = [saturatedPoint.h_f floatValue] + quality*([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
			entropy = [saturatedPoint.s_f floatValue] + quality*([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
		} else {
			// Superheated Region below P_CRITICAL
			
			NSArray *pressureKeys = [self.superheatedMappingKeys copy];
			
			NSLog(@"array: %@",pressureKeys);
			
			int loc = 0;
			BOOL locationReached = NO;
			
			for (int i = 0; i < pressureKeys.count; i++) {
				if (((NSNumber *)pressureKeys[i]).floatValue >= pressure) {
					continue;
				} else {
					locationReached = YES;
					loc = i;
				}
			}
			
			// Find list of temperatures for specific temperature
			NSArray *lowArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc];
			//NSArray *highArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc+1];
			
			int lowArrayLoc = 0;
			//int highArrayLoc = 0;
			locationReached = NO;
			
			// Find index of first specific volume value in array which is less than chosen v value
			for (int i = 0; i < lowArray.count; i++) {
				if ([(NSNumber *)lowArray[i] floatValue] >= specVol) {
					continue;
				} else {
					locationReached = YES;
					lowArrayLoc = i;
				}
			}
			
			if (lowArrayLoc != lowArray.count - 1 && locationReached) {
				NSLog(@"1");
				float lowSpecVol = [(NSNumber *)lowArray[lowArrayLoc] floatValue];
				float highSpecVol = [(NSNumber *)lowArray[lowArrayLoc + 1] floatValue];
				
				float weight = (specVol - lowSpecVol)/(highSpecVol - lowSpecVol);
				
				float lowTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
				float highTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:(lowArrayLoc + 1)]).floatValue;
				
				temp = lowTemp + weight*(highTemp - lowTemp);
			} else {
				NSLog(@"2");
				temp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
			}
			
			double kTemperature = temp + 273.15;
			
			NSLog(@"%f",temp);
			
			intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:kTemperature
																   andDensity:density]/1000.0;
			enthalpy = [self.wagPruss calculateEnthalpyWithTemperature:kTemperature
															andDensity:density]/1000.0;
			entropy = [self.wagPruss calculateEntropyWithTemperature:kTemperature
														  andDensity:density]/1000.0;
			
			temp = kTemperature;
		}
		
		currentTemp = temp - 273.15;
		currentPressure = pressure;
		currentSpecVolume = specVol;
		currentIntEnergy = intEnergy;
		currentEnthalpy = enthalpy;
		currentEntropy = entropy;
		currentQuality = quality;
		
		[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temp - 273.15]
												 pressure:[NSNumber numberWithFloat:pressure]
										   specificVolume:[NSNumber numberWithFloat:specVol]
										   internalEnergy:[NSNumber numberWithFloat:intEnergy]
												 enthalpy:[NSNumber numberWithFloat:enthalpy]
												  entropy:[NSNumber numberWithFloat:entropy]
												  quality:(quality == -1 ? nil : [NSNumber numberWithFloat:quality*100])];
		
		return;
	}
	
	NSArray *pressureKeys = [self.superheatedMappingKeys copy];
	
	int loc = 0;
	BOOL locationReached = NO;
	
	for (int i = 0; i < pressureKeys.count; i++) {
		if (((NSNumber *)pressureKeys[i]).floatValue >= pressure) {
			continue;
		} else {
			locationReached = YES;
			loc = i;
		}
	}
	
	// Find list of temperatures for specific temperature
	NSArray *lowArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc];
	//NSArray *highArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc+1];
	
	int lowArrayLoc = 0;
	//int highArrayLoc = 0;
	locationReached = NO;
	
	// Find index of first specific volume value in array which is less than chosen v value
	for (int i = 0; i < lowArray.count; i++) {
		if ([(NSNumber *)lowArray[i] floatValue] >= specVol) {
			continue;
		} else {
			locationReached = YES;
			lowArrayLoc = i;
		}
	}
	
	if (lowArrayLoc != lowArray.count - 1 && locationReached) {
		float lowSpecVol = [(NSNumber *)lowArray[lowArrayLoc] floatValue];
		float highSpecVol = [(NSNumber *)lowArray[lowArrayLoc + 1] floatValue];
		
		float weight = (specVol - lowSpecVol)/(highSpecVol - lowSpecVol);
		
		float lowTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
		float highTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:(lowArrayLoc + 1)]).floatValue;
		
		temp = lowTemp + weight*(highTemp - lowTemp);
	} else {
		temp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
	}
	
	double kTemperature = temp + 273.15;

	intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:kTemperature
														   andDensity:density]/1000.0;
	enthalpy = [self.wagPruss calculateEnthalpyWithTemperature:kTemperature
													andDensity:density]/1000.0;
	entropy = [self.wagPruss calculateEntropyWithTemperature:kTemperature
												  andDensity:density]/1000.0;
	
	currentTemp = temp;
	currentPressure = pressure;
	currentSpecVolume = specVol;
	currentIntEnergy = intEnergy;
	currentEnthalpy = enthalpy;
	currentEntropy = entropy;
	currentQuality = quality;
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temp]
											 pressure:[NSNumber numberWithFloat:pressure]
									   specificVolume:[NSNumber numberWithFloat:specVol]
									   internalEnergy:[NSNumber numberWithFloat:intEnergy]
											 enthalpy:[NSNumber numberWithFloat:enthalpy]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:nil];
}

- (void)phTouchDidRegisterAtLocation:(CGPoint)location
					   withEventType:(NSString *)eventType
					  inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	CGFloat primaryScale = ([self primaryAxisEndingValue] - [self primaryAxisStartingValue])/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = (log10f([self secondaryAxisEndingValue]) - log10f([self secondaryAxisStartingValue]))/locationIndicatorImageView.frame.size.height;
	
	float enthalpy = [self primaryAxisStartingValue] + primaryScale*location.x;
	float pressure = powf(10.0, log10f([self secondaryAxisStartingValue]) + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y));
	
	float temp, specVol = -1, intEnergy = -1, entropy = -1, quality = -1;
	
	if (pressure < P_CRITICAL) {
		temp = [self.wagPruss temperatureVapourLiquidWithPressure:pressure];
		SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)(temp - 273.15)
																						  inContext:appDelegate.managedObjectContext];
		
		if (enthalpy < saturatedPoint.h_f.floatValue) {
			// Compressed Liquid Region
			specVol = saturatedPoint.v_f.floatValue;
			intEnergy = enthalpy - pressure*specVol;
			entropy = saturatedPoint.s_f.floatValue;
		} else if (enthalpy >= saturatedPoint.h_f.floatValue && enthalpy <= saturatedPoint.h_g.floatValue) {
			// Saturated Vapor (Mixture) Region
			quality = (enthalpy - [saturatedPoint.h_f floatValue])/([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
			specVol = [saturatedPoint.v_f floatValue] + quality*([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
			intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
			entropy = [saturatedPoint.s_f floatValue] + quality*([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
		} else if (enthalpy > saturatedPoint.h_g.floatValue) {
			// Superheated Vapor Region
			
			NSArray *pressureKeys = [self.superheatedMappingKeys copy];
			
			int loc = 0;
			BOOL locationReached = NO;
			
			for (int i = 0; i < pressureKeys.count; i++) {
				if (((NSNumber *)pressureKeys[i]).floatValue >= pressure) {
					continue;
				} else {
					locationReached = YES;
					loc = i;
				}
			}
			
			// Find list of temperatures for specific temperature
			NSArray *lowArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc];
			//NSArray *highArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc+1];
			
			int lowArrayLoc = 0;
			//int highArrayLoc = 0;
			locationReached = NO;
			
			// Find index of first specific volume value in array which is less than chosen v value
			for (int i = 0; i < lowArray.count; i++) {
				if ([(NSNumber *)lowArray[i] floatValue] >= enthalpy) {
					continue;
				} else {
					locationReached = YES;
					lowArrayLoc = i;
				}
			}
			
			if (lowArrayLoc != lowArray.count - 1 && locationReached) {
				float lowEnthalpy = [(NSNumber *)lowArray[lowArrayLoc] floatValue];
				float highEnthalpy = [(NSNumber *)lowArray[lowArrayLoc + 1] floatValue];
				
				float weight = (enthalpy - lowEnthalpy)/(highEnthalpy - lowEnthalpy);
				
				float lowTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
				float highTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:(lowArrayLoc + 1)]).floatValue;
				
				temp = lowTemp + weight*(highTemp - lowTemp);
			} else {
				temp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
			}
			
			double kTemperature = temp + 273.15;
			double mPressure = pressure/1000;
			
			double density = [self.wagPruss rhoWithTemperature:kTemperature
												   andPressure:mPressure];
			specVol = 1/density;
			
			intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:kTemperature
																   andDensity:density]/1000.0;
			entropy = [self.wagPruss calculateEntropyWithTemperature:kTemperature
														  andDensity:density]/1000.0;
			
			temp = kTemperature;
		}
	} else {
		// Superheated Vapor Region
		NSArray *pressureKeys = [self.superheatedMappingKeys copy];
		
		int loc = 0;
		BOOL locationReached = NO;
		
		for (int i = 0; i < pressureKeys.count; i++) {
			if (((NSNumber *)pressureKeys[i]).floatValue >= pressure) {
				continue;
			} else {
				locationReached = YES;
				loc = i;
			}
		}
		
		// Find list of temperatures for specific temperature
		NSArray *lowArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc];
		//NSArray *highArray = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)loc+1];
		
		int lowArrayLoc = 0;
		//int highArrayLoc = 0;
		locationReached = NO;
		
		// Find index of first specific volume value in array which is less than chosen v value
		for (int i = 0; i < lowArray.count; i++) {
			if ([(NSNumber *)lowArray[i] floatValue] >= enthalpy) {
				continue;
			} else {
				locationReached = YES;
				lowArrayLoc = i;
			}
		}
		
		if (lowArrayLoc != lowArray.count - 1 && locationReached) {
			float lowEnthalpy = [(NSNumber *)lowArray[lowArrayLoc] floatValue];
			float highEnthalpy = [(NSNumber *)lowArray[lowArrayLoc + 1] floatValue];
			
			float weight = (enthalpy - lowEnthalpy)/(highEnthalpy - lowEnthalpy);
			
			float lowTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
			float highTemp = ((NSNumber *)[self.superheatedKeys objectAtIndex:(lowArrayLoc + 1)]).floatValue;
			
			temp = lowTemp + weight*(highTemp - lowTemp);
		} else {
			temp = ((NSNumber *)[self.superheatedKeys objectAtIndex:lowArrayLoc]).floatValue;
		}
		
		double kTemperature = temp + 273.15;
		double mPressure = pressure/1000;
		
		double density = [self.wagPruss rhoWithTemperature:kTemperature
											   andPressure:mPressure];
		specVol = 1/density;
		
		intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:kTemperature
															   andDensity:density]/1000.0;
		entropy = [self.wagPruss calculateEntropyWithTemperature:kTemperature
													  andDensity:density]/1000.0;
		
		temp = kTemperature;
	}
	
	currentTemp = temp - 273.15;
	currentPressure = pressure;
	currentSpecVolume = specVol;
	currentIntEnergy = intEnergy;
	currentEnthalpy = enthalpy;
	currentEntropy = entropy;
	currentQuality = quality;
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temp - 273.15]
											 pressure:[NSNumber numberWithFloat:pressure]
									   specificVolume:[NSNumber numberWithFloat:specVol]
									   internalEnergy:[NSNumber numberWithFloat:intEnergy]
											 enthalpy:[NSNumber numberWithFloat:enthalpy]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:(quality == -1 ? nil : [NSNumber numberWithFloat:quality*100])];
}

- (void)tsTouchDidRegisterAtLocation:(CGPoint)location
					   withEventType:(NSString *)eventType
					  inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	
	// Get the scales (units/pixel)for both axes based on graph
	CGFloat primaryScale = ([self primaryAxisEndingValue] - [self primaryAxisStartingValue])/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = ([self secondaryAxisEndingValue] - [self secondaryAxisStartingValue])/locationIndicatorImageView.frame.size.height;
	
	currentTemp = [self secondaryAxisStartingValue] + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y);
	// If temperature is below the minimum temp, reset the minimum temp
	if (currentTemp < T_SAT_MIN) {
		currentTemp = T_SAT_MIN;
	}
	
	currentEntropy = location.x*primaryScale;
	
	[self calculateNewValuesWithTemperature:currentTemp
									entropy:currentEntropy];
	
	return;
}

- (void)chooseNewFileWithChartType:(NSString *)chartType valueType:(NSString *)valueType
{
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSString *path = [bundleRoot stringByAppendingString:@"/Data Files"];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
	NSPredicate *fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.csv' AND self BEGINSWITH '%@_Super_%@'",chartType,valueType]];
	NSArray *allCSVs = [dirContents filteredArrayUsingPredicate:fltr];
	
	if (allCSVs.count) {
		self.superheatedKeys = [RUDataSelector loadSuperheatedKeyValuesWithFileName:[allCSVs firstObject]];
		self.superheatedKeys = [RUDataSelector loadSuperheatedKeyValuesWithFileName:[allCSVs firstObject]]; // called a 2nd time because Xcode 8
		self.superheatedValues = [RUDataSelector loadSuperheatedValuesWithFileName:[allCSVs firstObject]];
		self.superheatedMappingKeys = [RUDataSelector loadSuperheatedRowMappingValuesWithFileName:[allCSVs firstObject]];
	}
}

#pragma mark - Calculation Methods

- (void)calculateNewValuesWithTemperature:(float)temperature
								  entropy:(float)entropy
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Check if finger is above or below critical temperature (379.3 C)
	if (temperature > T_CRITICAL) {
		// Superheated above 379.3 C
		[self calculateSuperheatedWithTemperature:temperature
										  entropy:entropy];
	} else if (temperature <= T_CRITICAL) {
		if ([[NSString stringWithFormat:@"%.1f",temperature] floatValue] == T_CRITICAL) {
			// Saturated at 379.3 C
			SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:[[NSString stringWithFormat:@"%.1f",temperature] floatValue]
																							  inContext:appDelegate.managedObjectContext];
			
			
			[self calculateSaturatedWithSaturatedPlotPoint:saturatedPoint
											   temperature:temperature
												   entropy:entropy];
		} else {
			SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:temperature
																							  inContext:appDelegate.managedObjectContext];
			if (entropy < [saturatedPoint.s_f floatValue]) {
				// Compressed Liquid
				[self calculateCompressedLiquidWithSaturatedPlotPoint:saturatedPoint
														  temperature:temperature
															  entropy:entropy];
			} else if (entropy > [saturatedPoint.s_f floatValue] && entropy < [saturatedPoint.s_g floatValue]) {
				// Saturated
				[self calculateSaturatedWithSaturatedPlotPoint:saturatedPoint
												   temperature:temperature
													   entropy:entropy];
			} else if (entropy > [saturatedPoint.s_g floatValue]) {
				// Superheated below 379.3 C
				[self calculateSuperheatedWithTemperature:temperature
												  entropy:entropy];
			}
		}
	}
}

- (void)calculateCompressedLiquidWithSaturatedPlotPoint:(SaturatedPlotPoint *)saturatedPoint
											temperature:(float)temperature
												entropy:(float)entropy
{
	currentPressure = [saturatedPoint.p floatValue];
	currentSpecVolume = [saturatedPoint.v_f floatValue];
	currentIntEnergy = [saturatedPoint.u_f floatValue];
	currentEnthalpy = [saturatedPoint.h_f floatValue];
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temperature]
											 pressure:[NSNumber numberWithFloat:[saturatedPoint.p floatValue]]
									   specificVolume:[NSNumber numberWithFloat:[saturatedPoint.v_f floatValue]]
									   internalEnergy:[NSNumber numberWithFloat:[saturatedPoint.u_f floatValue]]
											 enthalpy:[NSNumber numberWithFloat:[saturatedPoint.h_f floatValue]]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:[NSNumber numberWithFloat:0]];
	
	if (!self.displayView.qualityIsHidden) {
		[self.displayView hideQuality];
	}
	
	currentRegion = kCurrentRegionCompressedLiquid;
}

- (void)calculateSaturatedWithSaturatedPlotPoint:(SaturatedPlotPoint *)saturatedPoint
									 temperature:(float)temperature
										 entropy:(float)entropy
{
	float pressure, specVolume, intEnergy, enthalpy, quality;
	
	pressure = [saturatedPoint.p floatValue];
	quality = (entropy - [saturatedPoint.s_f floatValue])/([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
	specVolume = [saturatedPoint.v_f floatValue] + quality*([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
	intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
	enthalpy = [saturatedPoint.h_f floatValue] + quality*([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
	
	currentPressure = pressure;
	currentSpecVolume = specVolume;
	currentIntEnergy = intEnergy;
	currentEnthalpy = enthalpy;
	currentQuality = quality;
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temperature]
											 pressure:[NSNumber numberWithFloat:pressure]
									   specificVolume:[NSNumber numberWithFloat:specVolume]
									   internalEnergy:[NSNumber numberWithFloat:intEnergy]
											 enthalpy:[NSNumber numberWithFloat:enthalpy]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:[NSNumber numberWithFloat:quality*100]];
	if (self.displayView.qualityIsHidden) {
		[self.displayView showQuality];
	}
	
	currentRegion = kCurrentRegionSaturated;
}

- (void)calculateSuperheatedWithTemperature:(float)temperature
									entropy:(float)entropy
{
	float pressure, specVolume, intEnergy, enthalpy, quality;
	quality = 0.0;
	
	pressure = [self interpolateToPressureWithTemperature:temperature
												  entropy:entropy];
	
	double kTemperature = temperature + 273.15;
	double mPressure = pressure/1000;
	
	NSLog(@"density1");
	double density = [self.wagPruss rhoWithTemperature:kTemperature
										   andPressure:mPressure];
	specVolume = 1/density;
	NSLog(@"density2");
	
	intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:kTemperature
														   andDensity:density]/1000.0;
	enthalpy = [self.wagPruss calculateEnthalpyWithTemperature:kTemperature
													andDensity:density]/1000.0;
	
	currentPressure = pressure;
	currentSpecVolume = specVolume;
	currentIntEnergy = intEnergy;
	currentEnthalpy = enthalpy;
	
	[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temperature]
											 pressure:[NSNumber numberWithFloat:pressure]
									   specificVolume:[NSNumber numberWithFloat:specVolume]
									   internalEnergy:[NSNumber numberWithFloat:intEnergy]
											 enthalpy:[NSNumber numberWithFloat:enthalpy]
											  entropy:[NSNumber numberWithFloat:entropy]
											  quality:[NSNumber numberWithFloat:quality*100]];
	
	if (!self.displayView.qualityIsHidden) {
		[self.displayView hideQuality];
	}
	
	currentRegion = kCurrentRegionSuperheated;
}

- (float)interpolateToPressureWithTemperature:(float)temperature entropy:(float)entropy
{
	// Find list of entropies for specific temperature
	NSArray *array = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)temperature];
	
	int location = 0;
	BOOL locationReached = NO;
	
	// Find index of first entropy value in array which is less than chosen entropy value
	for (int i = 0; i < array.count; i++) {
		if ([(NSNumber *)array[i] floatValue] <= entropy) {
			continue;
		} else {
			locationReached = YES;
			location = i;
		}
	}
	
	// Interpolation to determine pressure value
	if (location != array.count - 1 && locationReached) {
		float highEnt = [(NSNumber *)array[location] floatValue];
		float lowEnt = [(NSNumber *)array[location + 1] floatValue];
		
		float weight = (entropy - lowEnt)/(highEnt - lowEnt);
		
		float highPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
		float lowPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:(location + 1)]).floatValue;
		
		return lowPres + weight*(highPres - lowPres);
	} else {
		return ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
	}
}

- (float)interpolateToEntropyWithTemperature:(float)temperature pressure:(float)pressure
{
	// Find list of entropies for specific temperature
	NSArray *array = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)temperature];
	
	int location = 0;
	BOOL locationReached = NO;
	
	// Find index of first entropy value in array which is less than chosen entropy value
	for (int i = 0; i < self.superheatedKeys.count; i++) {
		if ([(NSNumber *)self.superheatedKeys[i] floatValue] >= pressure) {
			continue;
		} else {
			locationReached = YES;
			location = i;
		}
	}
	
	// Interpolation to determine pressure value
	if (location != self.superheatedKeys.count - 1 && locationReached) {
		float lowPres = [(NSNumber *)self.superheatedKeys[location] floatValue];
		float highPres = [(NSNumber *)self.superheatedKeys[location + 1] floatValue];
		
		float weight = (pressure - lowPres)/(highPres - lowPres);
		
		float lowEnt = ((NSNumber *)[array objectAtIndex:location]).floatValue;
		float highEnt = ((NSNumber *)[array objectAtIndex:(location + 1)]).floatValue;
		
		return lowEnt + weight*(highEnt - lowEnt);
	} else {
		return ((NSNumber *)[array objectAtIndex:location]).floatValue;
	}
}

#pragma mark - Adjuster View Delegate
/*
- (void)moveMarkerToPrimaryAxisValue:(CGFloat)primValue secondaryAxisValue:(CGFloat)secValue
{
	if ([self respondsToAllProperSelectors]) {
		CGFloat xValue = ((primValue - [self.dataSource primaryAxisStartingValue])*self.frame.size.width/self.primaryAxisRange);
		CGFloat yValue = self.frame.size.height - ((secValue - [self.dataSource secondaryAxisStartingValue])*self.frame.size.height/self.secondaryAxisRange);
		
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
*/
- (void)adjusterView:(RUAAdjusterView *)adjusterView didAdjustFromLocation:(CGPoint)fromLocation toLocation:(CGPoint)toLocation
{
	if (touchHasRegistered) {
		CGFloat dx = toLocation.x - fromLocation.x;
		CGFloat width = self.chartView.frame.size.width;
		CGFloat height = self.chartView.frame.size.height;
		CGFloat rangeX = [self primaryAxisEndingValue] - [self primaryAxisStartingValue];
		CGFloat rangeY = [self secondaryAxisEndingValue] - [self secondaryAxisStartingValue];
		if (adjusterView.tag == 1) {
			// Temperature
			float dT = dx*T_TOTAL_CHANGE/adjusterView.frame.size.width;
			float newTemp = currentTemp + dT;
			if (newTemp > T_SAT_MIN && [self.chartView pointIsWithinBoundsForPrimaryAxisValue:currentEntropy
																		   secondaryAxisValue:newTemp]) {
				currentTemp = newTemp;
				[self calculateNewValuesWithTemperature:newTemp
												entropy:currentEntropy];
				
				CGFloat newY = height - ((newTemp - [self secondaryAxisStartingValue]) * height/rangeY);
				CGPoint newChartLocation = CGPointMake(self.chartView.lastLocation.x, newY);
				[self.chartView addSmallMarkerAtLocation:newChartLocation];
			}
		} else if (adjusterView.tag == 2) {
			// Pressure
			float dP = dx*currentPressure/(10.0f*adjusterView.frame.size.width);
			float newPressure = currentPressure + dP;
			
			if ([currentRegion isEqualToString:kCurrentRegionSaturated]) {
				AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				
				currentTemp = [SaturatedPlotPoint fetchTemperatureWithPressure:newPressure
																	 inContext:appDel.managedObjectContext];
				
				[self calculateNewValuesWithTemperature:currentTemp
												entropy:currentEntropy];
				//[self.chartView addSmallMarkerAtLocation:newChartLocation];
			} else {
				float newEntropy = [self interpolateToEntropyWithTemperature:currentTemp
																	pressure:newPressure];
				
				currentEntropy = newEntropy;
				currentPressure = newPressure;
				
				[self calculateNewValuesWithTemperature:currentTemp
												entropy:newEntropy];
				
				CGFloat newX = (newEntropy - [self primaryAxisStartingValue])*width/rangeX;
				CGPoint newChartLocation = CGPointMake(newX, self.chartView.lastLocation.y);
				[self.chartView addSmallMarkerAtLocation:newChartLocation];
			}
		} else if (adjusterView.tag == 3) {
			// Specific Volume
		} else if (adjusterView.tag == 4) {
			// Internal Energy
		} else if (adjusterView.tag == 5) {
			// Enthalpy
		} else if (adjusterView.tag == 6) {
			// Entropy
			float ds = dx*S_TOTAL_CHANGE/adjusterView.frame.size.width;
			float newEntropy = currentEntropy + ds;
			if ([self.chartView pointIsWithinBoundsForPrimaryAxisValue:newEntropy
													secondaryAxisValue:currentTemp]) {
				currentEntropy = newEntropy;
				[self calculateNewValuesWithTemperature:currentTemp
												entropy:newEntropy];
				
				CGFloat newX = (newEntropy - [self primaryAxisStartingValue])*width/rangeX;
				CGPoint newChartLocation = CGPointMake(newX, self.chartView.lastLocation.y);
				[self.chartView addSmallMarkerAtLocation:newChartLocation];
			}
		} else if (adjusterView.tag == 7) {
			// Quality
			float dx = (toLocation.x - fromLocation.x)*X_TOTAL_CHANGE/adjusterView.frame.size.width;
			float newQuality = currentQuality + dx;
			if (newQuality <= 100.0 && newQuality >= 0.0) {
				if ([currentRegion isEqualToString:kCurrentRegionSaturated]) {
					AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					currentQuality = newQuality;
					
					SaturatedPlotPoint *plotPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)currentTemp
																								 inContext:appDel.managedObjectContext];
					float s_f = plotPoint.s_f.floatValue;
					float s_g = plotPoint.s_g.floatValue;
					
					currentEntropy = s_f + newQuality*(s_g - s_f);
					
					[self calculateNewValuesWithTemperature:currentTemp
													entropy:currentEntropy];
					CGFloat newX = (currentEntropy - [self primaryAxisStartingValue])*width/rangeX;
					CGPoint newChartLocation = CGPointMake(newX, self.chartView.lastLocation.y);
					[self.chartView addSmallMarkerAtLocation:newChartLocation];
				}
			}
		} else {
			NSLog(@"Incorrect tag sent");
		}
	}
}

#pragma mark - Private

- (void)showQualityAdjusterView
{
	for (RUAAdjusterView *view in self.secondContainerView.subviews) {
		if ([view isMemberOfClass:[RUAAdjusterView class]] && view.tag == 7) {
			[view setHidden:NO];
		}
	}
}

- (void)hideQualityAdjusterView
{
	for (RUAAdjusterView *view in self.secondContainerView.subviews) {
		if ([view isMemberOfClass:[RUAAdjusterView class]] && view.tag == 7) {
			[view setHidden:YES];
		}
	}
}

#pragma mark - Cycles

- (void)beginCycle
{
	
}

- (void)moveCycleToPoint:(NSUInteger)point
{
	
}

- (void)endCycle
{
	
}

@end
