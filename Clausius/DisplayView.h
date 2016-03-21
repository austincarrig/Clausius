//
//  DisplayView.h
//  Mvuke
//
//  Created by Austin Carrig on 5/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplayViewDataSource;

@interface DisplayView : UIView
@property (strong, nonatomic) UILabel *title;

@property (strong, nonatomic) UILabel *temperatureLabel;
@property (strong, nonatomic) UILabel *pressureLabel;
@property (strong, nonatomic) UILabel *specificVolumeLabel;
@property (strong, nonatomic) UILabel *internalEnergyLabel;
@property (strong, nonatomic) UILabel *enthalpyLabel;
@property (strong, nonatomic) UILabel *entropyLabel;
@property (strong, nonatomic) UILabel *qualityLabel;

@property (strong, nonatomic) UITextField *temperatureTextField;
@property (strong, nonatomic) UITextField *pressureTextField;
@property (strong, nonatomic) UITextField *specificVolumeTextField;
@property (strong, nonatomic) UITextField *internalEnergyTextField;
@property (strong, nonatomic) UITextField *enthalpyTextField;
@property (strong, nonatomic) UITextField *entropyTextField;
@property (strong, nonatomic) UITextField *qualityTextField;

@property (strong, nonatomic) UILabel *temperatureUnitsLabel;
@property (strong, nonatomic) UILabel *pressureUnitsLabel;
@property (strong, nonatomic) UILabel *specificVolumeUnitsLabel;
@property (strong, nonatomic) UILabel *internalEnergyUnitsLabel;
@property (strong, nonatomic) UILabel *enthalpyUnitsLabel;
@property (strong, nonatomic) UILabel *entropyUnitsLabel;
@property (strong, nonatomic) UILabel *qualityUnitsLabel;

@property CGFloat containerViewHeight;
@property CGFloat containerViewOriginY;
@property NSUInteger numberOfRows;

@property BOOL qualityIsHidden;

@property id <DisplayViewDataSource> dataSource;

-(instancetype)initWithFrame:(CGRect)frame;

/**
 *  Used to update all the number fields in the display
 */
-(void)updateTextFieldsWithTemperature:(NSNumber *)temperature
							  pressure:(NSNumber *)pressure
						specificVolume:(NSNumber *)specificVolume
						internalEnergy:(NSNumber *)internalEnergy
							  enthalpy:(NSNumber *)enthalpy
							   entropy:(NSNumber *)entropy
							   quality:(NSNumber *)quality;

/**
 *  Used to update the title if the graph type chanegs
 */
-(void)updateTitle:(NSString *)title;

-(void)showQuality;
-(void)hideQuality;

-(void)changeUnit:(NSString *)unit withTag:(NSUInteger)index;
@end

@protocol DisplayViewDataSource <NSObject>

-(NSString *)nameForLabel:(UILabel *)label inDisplayView:(DisplayView *)displayView;
-(NSString *)unitsForLabel:(UILabel *)label inDisplayView:(DisplayView *)displayView;

@optional

-(NSSet *)tagsForAdjusterViewsInDisplayView:(DisplayView *)displayView;

@end