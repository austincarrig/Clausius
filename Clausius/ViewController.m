//
//  ViewController.m
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Masonry.h"
#import "UIColor+Mvuke.h"
#import "CoreData.h"
#import "H2O_Wagner_Pruss.h"

#import "RUDataSelector.h"
#import "RUSolver.h"

#import "RUAxis.h"

#import "Clausius-Swift.h"

const static CGFloat T_CRITICAL = 373.9; // Critical temperature of water in C
const static CGFloat P_CRITICAL = 22100.; // Critical pressure of water in kPA
const static CGFloat T_SAT_MIN = 1.0; // Minimum temperature to display on the ts diagram in C

@interface ViewController ()
@property (strong, nonatomic) UIImageView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) RUChartView *chartView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIView *secondContainerView;
@property (strong, nonatomic) DisplayView *displayView;

@property (strong, nonatomic) H2O_Wagner_Pruss *wagPruss;

@property (strong, nonatomic) NSArray *superheatedKeys;
@property (strong, nonatomic) NSArray *superheatedValues;
@property (strong, nonatomic) NSArray *superheatedMappingKeys;

@property (strong, nonatomic) NSArray *chartValueTypes;
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
	
	priorX = 0;
	priorY = 0;
	
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
	
	[self chooseNewFileWithChartType:self.chartView.chart.substanceType];
	
	UISwipeGestureRecognizer *rightRecog = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																					 action:@selector(resetChart:)];
	[rightRecog setDirection:UISwipeGestureRecognizerDirectionRight];
	[rightRecog setCancelsTouchesInView:YES];
	
	[rightRecog setNumberOfTouchesRequired:2];
	
	[self.chartView addGestureRecognizer:rightRecog];
	
	UISwipeGestureRecognizer *leftRecog = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																				action:@selector(resetChart:)];
	[leftRecog setDirection:UISwipeGestureRecognizerDirectionLeft];
	[leftRecog setCancelsTouchesInView:YES];
	
	[leftRecog setNumberOfTouchesRequired:2];
	
	[self.chartView addGestureRecognizer:leftRecog];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

#pragma mark - Lazy Init

- (RUChartView *)chartView
{
	if (!_chartView) {
		_chartView = (RUChartView *)[[RUChartView alloc] initWithFrame:self.containerView.frame
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
		[_infoView setImage:[UIImage imageNamed:@"Legend.jpeg"]];
		[_infoView setHidden:YES];
		[_infoView setUserInteractionEnabled:NO];
		[_infoView setBackgroundColor:[UIColor whiteColor]];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																			  action:@selector(dismissInfo)];
		[tap setNumberOfTapsRequired:1];
		
		[_infoView addGestureRecognizer:tap];
	}
	return _infoView;
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
	if (self.navigationController.isNavigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	} else {	
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
}

- (void)resetChart:(UISwipeGestureRecognizer *)recog
{
	NSInteger index = [self.chartValueTypes indexOfObject:self.chartView.chart.valueType];
	NSLog(@"%@, %@", self.chartValueTypes[((index+1)+3)%3], self.chartValueTypes[((index-1)+3)%3]);
	if (recog.direction == UISwipeGestureRecognizerDirectionRight) {
		[self.chartView resetImage:[UIImage imageNamed:[NSString stringWithFormat:@"Water_%@_chart.png",self.chartValueTypes[((index+1)+3)%3]]]];
		self.chartView.chart = [RUChart chartWithChartType:self.chartValueTypes[((index+1)+3)%3]];
		[self inspectInfoButtonWithChartValueType:self.chartValueTypes[((index+1)+3)%3]];
	} else if (recog.direction == UISwipeGestureRecognizerDirectionLeft) {
		[self.chartView resetImage:[UIImage imageNamed:[NSString stringWithFormat:@"Water_%@_chart.png",self.chartValueTypes[((index-1)+3)%3]]]];
		self.chartView.chart = [RUChart chartWithChartType:self.chartValueTypes[((index-1)+3)%3]];
		[self inspectInfoButtonWithChartValueType:self.chartValueTypes[((index-1)+3)%3]];
	}
	
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
	
	[self.chartView removeMarker];
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

- (CGFloat)xAxisEndingValue
{
	return self.chartView.chart.xAxis.max.floatValue;
}

- (CGFloat)yAxisEndingValue
{
	return self.chartView.chart.yAxis.max.floatValue;
}

- (CGFloat)xAxisStartingValue
{
	return self.chartView.chart.xAxis.min.floatValue;
}

- (CGFloat)yAxisStartingValue
{
	return self.chartView.chart.yAxis.min.floatValue;
}

- (CGFloat)minimumYAxisValue
{
	return T_SAT_MIN;
}

#pragma mark - Display View Datasource

-(NSString *)nameForLabel:(UILabel *)label InDisplayView:(DisplayView *)displayView
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

-(NSString *)unitsForLabel:(UILabel *)label InDisplayView:(DisplayView *)displayView
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
	if ([self.chartView.chart.valueType isEqualToString:@"ts"]) {
		[self tsTouchDidRegisterAtLocation:location
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"ph"]) {
		[self phTouchDidRegisterAtLocation:location
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	} else if ([self.chartView.chart.valueType isEqualToString:@"pv"]) {
		[self pvTouchDidRegisterAtLocation:location
							 withEventType:@"Moved"
							inLocationView:locationIndicatorImageView];
	}
}

- (void)pvTouchDidRegisterAtLocation:(CGPoint)location
					   withEventType:(NSString *)eventType
					  inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
	
	// Get scales for both axes in units of [baseUnit/pixel]
	// If using log10f() the axis is log, converts value to exponent (i.e. b in value = 10^b, therefore b = log10(value))
	CGFloat primaryScale = (log10f([self xAxisEndingValue]) - log10f([self xAxisStartingValue]))/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = (log10f([self yAxisEndingValue]) - log10f([self yAxisStartingValue]))/locationIndicatorImageView.frame.size.height;
	
	// Calculate v & p given location on chart
	float specVol = powf(10.0,log10f([self xAxisStartingValue]) + primaryScale*location.x);
	float pressure = powf(10.0,log10f([self yAxisStartingValue]) + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y));
	
	float temp, density, intEnergy, enthalpy, entropy, quality = -1;
	
	// Check if we are at or above
	if (pressure < P_CRITICAL) {
		temp = ((NSNumber *)[self.wagPruss accurateTemperatureVapourLiquidWithPressure:pressure/1000.0].firstObject).floatValue;
		SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)(temp - 273.15)
																					inContext:appDel.managedObjectContext];
		density = 1./specVol;
		
		if (specVol <= saturatedPoint.v_f.floatValue) {
			// Compressed Liquid Region
			intEnergy = saturatedPoint.u_f.floatValue;
			enthalpy = saturatedPoint.h_f.floatValue;
			entropy = saturatedPoint.s_f.floatValue;
		} else if (specVol > saturatedPoint.v_f.floatValue && specVol < saturatedPoint.v_g.floatValue) {
			// Saturated Vapor (Mixture) Region
			quality = (specVol - [saturatedPoint.v_f floatValue])/([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
			intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
			enthalpy = [saturatedPoint.h_f floatValue] + quality*([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
			entropy = [saturatedPoint.s_f floatValue] + quality*([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
		} else {
			// Superheated Region below P_CRITICAL
			
			intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:temp
																   andDensity:density]/1000.0;
			
			enthalpy = intEnergy + pressure*specVol;
			
			entropy = [self.wagPruss calculateEntropyWithTemperature:temp
														  andDensity:density]/1000.0;
		}
		
		[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temp - 273.15]
												 pressure:[NSNumber numberWithFloat:pressure]
										   specificVolume:[NSNumber numberWithFloat:specVol]
										   internalEnergy:[NSNumber numberWithFloat:intEnergy]
												 enthalpy:[NSNumber numberWithFloat:enthalpy]
												  entropy:[NSNumber numberWithFloat:entropy]
												  quality:(quality == -1 ? nil : [NSNumber numberWithFloat:quality*100])];
		
		return;
	}
	
	temp = [RUSolver temperatureForSpecificVolume:specVol
									  andPressure:pressure];
	
	density = 1./specVol;
	
	intEnergy = [self.wagPruss calculateInternalEnergyWithTemperature:temp
														   andDensity:density];
	enthalpy = [self.wagPruss calculateEnthalpyWithTemperature:temp
													andDensity:density];
	entropy = [self.wagPruss calculateEntropyWithTemperature:temp
												  andDensity:density];
	
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
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	CGFloat primaryScale = ([self xAxisEndingValue] - [self xAxisStartingValue])/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = (log10f([self yAxisEndingValue]) - log10f([self yAxisStartingValue]))/locationIndicatorImageView.frame.size.height;
	
	float enthalpy = [self xAxisStartingValue] + primaryScale*location.x;
	float pressure = powf(10.0, log10f([self yAxisStartingValue]) + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y));
	
	float temp, specVol, intEnergy, entropy, quality = -1;
	
	if (pressure < P_CRITICAL) {
		temp = ((NSNumber *)[self.wagPruss accurateTemperatureVapourLiquidWithPressure:pressure/1000.].firstObject).floatValue;
		SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)(temp - 273.15)
																						  inContext:appDelegate.managedObjectContext];
		
		if (enthalpy < saturatedPoint.h_f.floatValue) {
			// Compressed Liquid Region
			specVol = saturatedPoint.v_f.floatValue;
			intEnergy = saturatedPoint.u_f.floatValue;
			entropy = saturatedPoint.s_f.floatValue;
		} else if (enthalpy >= saturatedPoint.h_f.floatValue && enthalpy <= saturatedPoint.h_g.floatValue) {
			// Saturated Vapor (Mixture) Region
			quality = (enthalpy - [saturatedPoint.h_f floatValue])/([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
			specVol = [saturatedPoint.v_f floatValue] + quality*([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
			intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
			entropy = [saturatedPoint.s_f floatValue] + quality*([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
		} else if (enthalpy > saturatedPoint.h_g.floatValue) {
			// Superheated Vapor Region
			NSLog(@"Finish Me");
		}
		
		[self.displayView updateTextFieldsWithTemperature:[NSNumber numberWithFloat:temp - 273.15]
												 pressure:[NSNumber numberWithFloat:pressure]
										   specificVolume:[NSNumber numberWithFloat:specVol]
										   internalEnergy:[NSNumber numberWithFloat:intEnergy]
												 enthalpy:[NSNumber numberWithFloat:enthalpy]
												  entropy:[NSNumber numberWithFloat:entropy]
												  quality:(quality == -1 ? nil : [NSNumber numberWithFloat:quality*100])];
	} else {
		// Superheated Vapor Region
		NSLog(@"Finish Me");
	}
}

- (void)tsTouchDidRegisterAtLocation:(CGPoint)location
					   withEventType:(NSString *)eventType
					  inLocationView:(LocationIndicatorImageView *)locationIndicatorImageView
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Get the scales (units/pixel)for both axes based on graph
	CGFloat primaryScale = ([self xAxisEndingValue] - [self xAxisStartingValue])/locationIndicatorImageView.frame.size.width;
	CGFloat secondaryScale = ([self yAxisEndingValue] - [self yAxisStartingValue])/locationIndicatorImageView.frame.size.height;
	
	float temperature = [self yAxisStartingValue] + secondaryScale*(locationIndicatorImageView.frame.size.height - location.y);
	// If temperature is below the minimum temp, reset the minimum temp
	if (temperature < T_SAT_MIN) {
		temperature = T_SAT_MIN;
	}
	
	float entropy = location.x*primaryScale;
	float __block pressure, specVolume, intEnergy, enthalpy, quality = 0;
	
	// Check if finger is above or below critical temperature (379.3 C)
	if (temperature > T_CRITICAL) {
		// Find list of entropies for specific temperature
		NSArray *array = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)temperature];
		
		int location = 0;
		BOOL locationReached = NO;
		
		// Find index of first entropy value in array wh 2ich is less than chosen entropy value
		for (int i = 0; i < array.count; i++) {
			if ([(NSNumber *)array[i] floatValue] <= entropy) {
				continue;
			} else {
				locationReached = YES;
				location = i;
			}
		}
		
		if (location != array.count - 1 && locationReached) {
			float highEnt = [(NSNumber *)array[location] floatValue];
			float lowEnt = [(NSNumber *)array[location + 1] floatValue];
			
			float weight = (entropy - lowEnt)/(highEnt - lowEnt);
			
			float highPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
			float lowPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:(location + 1)]).floatValue;
			
			pressure = lowPres + weight*(highPres - lowPres);
		} else {
			pressure = ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
		}
		
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
	} else if (temperature <= T_CRITICAL) {
		if ([[NSString stringWithFormat:@"%.1f",temperature] floatValue] == T_CRITICAL) {
			SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:[[NSString stringWithFormat:@"%.1f",temperature] floatValue]
																							  inContext:appDelegate.managedObjectContext];
			
			
			pressure = [saturatedPoint.p floatValue];
			quality = (entropy - [saturatedPoint.s_f floatValue])/([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
			specVolume = [saturatedPoint.v_f floatValue] + quality*([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
			intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
			enthalpy = [saturatedPoint.h_f floatValue] + quality*([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
			
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
		} else {
			SaturatedPlotPoint *saturatedPoint = [SaturatedPlotPoint fetchSaturatedPointWithTemperature:(int)temperature
																							  inContext:appDelegate.managedObjectContext];
			if (entropy < [saturatedPoint.s_f floatValue]) {
				pressure = [saturatedPoint.p floatValue];
				specVolume = [saturatedPoint.v_f floatValue];
				intEnergy = [saturatedPoint.u_f floatValue];
				enthalpy = [saturatedPoint.h_f floatValue];
				
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
			} else if (entropy > [saturatedPoint.s_f floatValue] && entropy < [saturatedPoint.s_g floatValue]) {
				pressure = [saturatedPoint.p floatValue];
				quality = (entropy - [saturatedPoint.s_f floatValue])/([saturatedPoint.s_g floatValue] - [saturatedPoint.s_f floatValue]);
				specVolume = [saturatedPoint.v_f floatValue] + quality*([saturatedPoint.v_g floatValue] - [saturatedPoint.v_f floatValue]);
				intEnergy = [saturatedPoint.u_f floatValue] + quality*([saturatedPoint.u_g floatValue] - [saturatedPoint.u_f floatValue]);
				enthalpy = [saturatedPoint.h_f floatValue] + quality*([saturatedPoint.h_g floatValue] - [saturatedPoint.h_f floatValue]);
				
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
			} else if (entropy > [saturatedPoint.s_g floatValue]) {
				NSArray *array = (NSArray *)[self.superheatedValues objectAtIndex:(NSUInteger)temperature];
				
				int location = 0;
				BOOL locationReached = NO;
				for (int i = 0; i < array.count; i++) {
					if ([(NSNumber *)array[i] floatValue] <= entropy) {
						continue;
					} else {
						locationReached = YES;
						location = i;
					}
				}
				
				if (location != array.count - 1 && locationReached) {
					float highEnt = [(NSNumber *)array[location] floatValue];
					float lowEnt = [(NSNumber *)array[location + 1] floatValue];
					
					float weight = (entropy - lowEnt)/(highEnt - lowEnt);
					
					float highPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
					float lowPres = ((NSNumber *)[self.superheatedKeys objectAtIndex:(location + 1)]).floatValue;
					
					pressure = lowPres + weight*(highPres - lowPres);
				} else {
					pressure = ((NSNumber *)[self.superheatedKeys objectAtIndex:location]).floatValue;
				}
				
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
			}
		}
	}
	
	priorX = location.x;
	priorY = location.y;
}

- (void)chooseNewFileWithChartType:(NSString *)chartType
{
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSString *path = [bundleRoot stringByAppendingString:@"/Data Files"];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
	NSPredicate *fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.csv' AND self BEGINSWITH '%@_Super_'",chartType]];
	NSArray *allCSVs = [dirContents filteredArrayUsingPredicate:fltr];
	
	self.superheatedKeys = [RUDataSelector loadSuperheatedKeyValuesWithFileName:[allCSVs firstObject]];
	self.superheatedValues = [RUDataSelector loadSuperheatedValuesWithFileName:[allCSVs firstObject]];
	
	NSArray *array = [RUDataSelector loadSuperheatedRowMappingValuesWithFileName:[allCSVs firstObject]];
	
	NSLog(@"%@", array);
}
/*
- (void)loadSuperheatedData:(NSString *)fileName
{
	// Re-instantiate the superheated data arrays (because we are re-loading data)
	self.superheatedKeys = [NSMutableArray array];
	self.superheatedValues = [NSMutableArray arrayWithObjects:@[], nil]; // empty array at index=0 is so that the array indeces are mapped to 0
	
	// Get the directory, find the specified file
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:@"Data Files"];
	NSString *string = [NSString stringWithUTF8String:[[NSData dataWithContentsOfFile:path] bytes]];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	
	NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
	NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	NSString *pressureString;
	[scanner scanUpToCharactersFromSet:newline
							intoString:&pressureString];
	NSScanner *pressureScanner = [NSScanner scannerWithString:pressureString];
	
	NSMutableArray *pressureValues = [[NSMutableArray alloc] init];
	
	// Get all pressure values
	while (![pressureScanner isAtEnd]) {
		NSString *pressureVal;
		// Delimited by commas
		[pressureScanner scanUpToCharactersFromSet:comma
										intoString:&pressureVal];
		
		if (![pressureScanner isAtEnd]) {
			[pressureScanner setScanLocation:[pressureScanner scanLocation]+1];
		}
		[pressureValues addObject:[NSNumber numberWithFloat:[pressureVal floatValue]]];
	}
	
	self.superheatedKeys = pressureValues;
	
	//
	while (![scanner isAtEnd]) {
		NSString *lineString;
		[scanner scanUpToCharactersFromSet:newline
								intoString:&lineString];
		if (![scanner isAtEnd]) {
			[scanner setScanLocation:[scanner scanLocation]+1];
		}
		
		NSScanner *lineScanner = [NSScanner scannerWithString:lineString];
		
		// Get temperature, delimited by comma in first index of row (unused in this scheme, but gets rid of first element)
		NSString *temperatureString;
		[lineScanner scanUpToCharactersFromSet:comma
									intoString:&temperatureString];
		if (![lineScanner isAtEnd]) {
			[lineScanner setScanLocation:[lineScanner scanLocation]+1];
		}
		
		// Store one line of entropies
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		
		int count = 0;
		while (![lineScanner isAtEnd]) {
			NSString *valueString;
			[lineScanner scanUpToCharactersFromSet:comma
										intoString:&valueString];
			if (![lineScanner isAtEnd]) {
				[lineScanner setScanLocation:[lineScanner scanLocation]+1];
			}
			
			if (!([valueString isEqualToString:@"#VALUE!"] || [valueString isEqualToString:@"#NAME?"] || [valueString isEqualToString:@""]) && valueString) {
				[tempArray addObject:[NSNumber numberWithFloat:[valueString floatValue]]];
			} else {
				break;
			}
			count ++;
		}
		
		// Add the corresponding entropy array to the end of the array of entropy arrays
		[self.superheatedValues addObject:tempArray];
	}
}
*/
@end
