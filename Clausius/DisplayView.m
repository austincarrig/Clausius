//
//  DisplayView.m
//  Mvuke
//
//  Created by Austin Carrig on 5/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "DisplayView.h"
#import "Masonry.h"
#import "UIColor+Clausius.h"
#import <QuartzCore/QuartzCore.h>


const static CGFloat TITLE_CONTAINER_VIEW_PADDING = 10.0f;

const static CGFloat tempDiv = 6.0;


@interface DisplayView ()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *labelsContainer;
@property (strong, nonatomic) UIView *textFieldsContainer;
@property (strong, nonatomic) UIView *unitsContainer;
@property (strong, nonatomic) UIView *hideShowQualityView;


@property CGFloat height;
@property CGFloat width;

@property (strong, nonatomic) NSNumber *temperature;
@property (strong, nonatomic) NSNumber *pressure;
@property (strong, nonatomic) NSNumber *specVolume;
@property (strong, nonatomic) NSNumber *intEnergy;
@property (strong, nonatomic) NSNumber *enthalpy;
@property (strong, nonatomic) NSNumber *entropy;
@end

@implementation DisplayView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = frame.size.height;
        self.width = frame.size.width;

        [self addSubview:self.title];
        [self addSubview:self.containerView];

        [self.containerView addSubview:self.labelsContainer];
        [self.containerView addSubview:self.textFieldsContainer];
        [self.containerView addSubview:self.unitsContainer];
        [self insertSubview:self.hideShowQualityView aboveSubview:self.containerView];

        [self.labelsContainer addSubview:self.temperatureLabel];
        [self.labelsContainer addSubview:self.pressureLabel];
        [self.labelsContainer addSubview:self.specificVolumeLabel];
        [self.labelsContainer addSubview:self.internalEnergyLabel];
        [self.labelsContainer addSubview:self.enthalpyLabel];
        [self.labelsContainer addSubview:self.entropyLabel];
        [self.labelsContainer addSubview:self.qualityLabel];

        [self.textFieldsContainer addSubview:self.temperatureTextField];
        [self.textFieldsContainer addSubview:self.pressureTextField];
        [self.textFieldsContainer addSubview:self.specificVolumeTextField];
        [self.textFieldsContainer addSubview:self.internalEnergyTextField];
        [self.textFieldsContainer addSubview:self.enthalpyTextField];
        [self.textFieldsContainer addSubview:self.entropyTextField];
        [self.textFieldsContainer addSubview:self.qualityTextField];

        [self.unitsContainer addSubview:self.temperatureUnitsLabel];
        [self.unitsContainer addSubview:self.pressureUnitsLabel];
        [self.unitsContainer addSubview:self.specificVolumeUnitsLabel];
        [self.unitsContainer addSubview:self.internalEnergyUnitsLabel];
        [self.unitsContainer addSubview:self.enthalpyUnitsLabel];
        [self.unitsContainer addSubview:self.entropyUnitsLabel];
        [self.unitsContainer addSubview:self.qualityUnitsLabel];
    }

    return self;
}

-(void)didMoveToSuperview
{
    // Set Title
    [self.title setText:@"Water"]; // Manually Input

    // Set Text For Labels From DataSource
    UIFont *smallLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];

    if ([self.dataSource respondsToSelector:@selector(nameForLabel:inDisplayView:)]) {
        for (UILabel *label in self.labelsContainer.subviews) {
            [label setText:[self.dataSource nameForLabel:label inDisplayView:self]];
        }
    } else {
        for (UILabel *label in self.labelsContainer.subviews) {
            [label setText:@""];
        }
    }

    if ([self.dataSource respondsToSelector:@selector(unitsForLabel:inDisplayView:)]) {
        for (UILabel *label in self.unitsContainer.subviews) {
            NSString *labelText = [self.dataSource unitsForLabel:label inDisplayView:self];
            if ([labelText rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
                [label setText:labelText];
            } else {
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:labelText
                                                                                               attributes:@{NSFontAttributeName:smallLabelFont}];
                NSRange range = [labelText rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
                [attrString setAttributes:@{NSBaselineOffsetAttributeName : @5,
                                            NSFontAttributeName : [smallLabelFont fontWithSize:10.0f]}
                                    range:range];
                [label setAttributedText:attrString];
            }
        }
    } else {
        for (UILabel *label in self.unitsContainer.subviews) {
            [label setText:@""];
        }
    }

    // Set Autolayout for Title
    CGSize titleSize = [self.title.text sizeWithAttributes:@{NSFontAttributeName:self.title.font}];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.width.equalTo([NSNumber numberWithFloat:titleSize.width]);
        make.height.equalTo([NSNumber numberWithFloat:titleSize.height]);
    }];

    // Set Autolayout for Containers
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).with.offset(TITLE_CONTAINER_VIEW_PADDING);
        make.centerX.equalTo(self.title);
        make.bottom.equalTo(self);
        make.width.equalTo(self.title);
    }];

    CGFloat largestWidth = 25.0f;
    for (UILabel *label in self.labelsContainer.subviews) {
        [label setFont:smallLabelFont];
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        if (size.width > largestWidth) {
            largestWidth = size.width;
        }
    }

    [self.labelsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView);
        make.left.equalTo(self.containerView).with.offset(7.0f);
        make.width.equalTo([NSNumber numberWithFloat:largestWidth]);
    }];

    largestWidth = 30.0f;
    for (UILabel *label in self.unitsContainer.subviews) {
        CGSize size;
        if ([label.text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
            [label setFont:smallLabelFont];
            size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        } else {
            size = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:smallLabelFont.pointSize]}];
        }
        if (size.width > largestWidth) {
            largestWidth = size.width;
        }
    }

    [self.unitsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView);
        make.right.equalTo(self.containerView).with.offset(-5.0f);
        make.width.equalTo([NSNumber numberWithFloat:ceilf(largestWidth)]);
    }];

    [self.textFieldsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView);
        make.left.equalTo(self.labelsContainer.mas_right).with.offset(15.0f);
        make.right.equalTo(self.unitsContainer.mas_left).with.offset(-20.0f);
    }];

    self.containerViewHeight = (self.frame.size.height - 10.0f - titleSize.height);

    // Set Autolayout for Labels
    for (UILabel *label in self.labelsContainer.subviews) {
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
            CGFloat offset = (self.frame.size.height - 10.0f - titleSize.height)*(((CGFloat)(label.tag - 1)*2.0 + 1.0)/(2.0*self.labelsContainer.subviews.count));
            make.centerY.equalTo(self.labelsContainer.mas_top).with.offset(offset);
            make.left.equalTo(self.labelsContainer);
            make.width.equalTo([NSNumber numberWithFloat:labelSize.width]);
            make.height.equalTo([NSNumber numberWithFloat:labelSize.height]);
        }];
    }

    // Set Autolayout for Text Fields
    for (UITextField *textField in self.textFieldsContainer.subviews) {
        [textField setText:@"hello"];
        [textField setFont:smallLabelFont];
        [textField setTextColor:[UIColor blackColor]];
        [textField setTextAlignment:NSTextAlignmentLeft];
        [textField setUserInteractionEnabled:NO];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            CGSize tfSize = [textField.text sizeWithAttributes:@{NSFontAttributeName:textField.font}];
            CGFloat offset = (self.frame.size.height - 10.0f - titleSize.height)*(((CGFloat)(textField.tag - 1)*2.0 + 1.0)/(2.0*self.textFieldsContainer.subviews.count));
            make.centerY.equalTo(self.textFieldsContainer.mas_top).with.offset(offset);
            make.left.equalTo(self.textFieldsContainer);
            make.width.equalTo(self.textFieldsContainer);
            make.height.equalTo([NSNumber numberWithFloat:tfSize.height]);
        }];
        [textField setText:@""];
    }

    // Set Autolayout for Unit Labels
    for (UILabel *label in self.unitsContainer.subviews) {
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
            CGFloat offset = (self.frame.size.height - 10.0f - titleSize.height)*(((CGFloat)(label.tag - 1)*2.0 + 1.0)/(2.0*self.unitsContainer.subviews.count));
            make.centerY.equalTo(self.unitsContainer.mas_top).with.offset(offset);
            make.left.equalTo(self.unitsContainer);
            make.width.equalTo(self.unitsContainer);
            make.height.equalTo([NSNumber numberWithFloat:labelSize.height + 2.0f]);
        }];
    }

    // Add layer for lines between rows of display
    for (int i = 1; i < [self.labelsContainer.subviews count]; i++) {
        UIBezierPath *rowSeparator = [UIBezierPath bezierPath];
        CGFloat yLocation = self.containerViewHeight*(CGFloat)i/self.labelsContainer.subviews.count;
        [rowSeparator moveToPoint:CGPointMake(0, yLocation)];
        [rowSeparator addLineToPoint:CGPointMake(titleSize.width, yLocation)];
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        [lineLayer setPath:[rowSeparator CGPath]];
        [lineLayer setStrokeColor:[[[UIColor primaryColor] colorWithAlphaComponent:0.5] CGColor]];
        [self.containerView.layer addSublayer:lineLayer];
    }

    // Set Autolayout for quality cover view
    [self.hideShowQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.containerView);
        make.left.equalTo(self.containerView);
        make.right.equalTo(self.containerView);
        make.top.equalTo(self.entropyLabel.mas_bottom).with.offset(2.0f);
    }];

    self.containerViewOriginY = titleSize.height + TITLE_CONTAINER_VIEW_PADDING;
    self.numberOfRows = self.labelsContainer.subviews.count;
}

#pragma mark - Lazy Init Title

-(UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
        [_title setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80.0]];
        [_title setTextColor:[UIColor titleColor]];
        [_title setTextAlignment:NSTextAlignmentCenter];
        [_title setNumberOfLines:1];
    }
    return _title;
}

#pragma mark - Lazy Init Containers

-(UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _containerView;
}

-(UIView *)labelsContainer
{
    if (!_labelsContainer) {
        _labelsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _labelsContainer;
}

-(UIView *)textFieldsContainer
{
    if (!_textFieldsContainer) {
        _textFieldsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _textFieldsContainer;
}

-(UIView *)unitsContainer
{
    if (!_unitsContainer) {
        _unitsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _unitsContainer;
}

-(UIView *)hideShowQualityView
{
    if (!_hideShowQualityView) {
        _hideShowQualityView = [[UIView alloc] initWithFrame:CGRectZero];
        [_hideShowQualityView setHidden:NO];
        [_hideShowQualityView setBackgroundColor:[UIColor whiteColor]];
        [_hideShowQualityView setBackgroundColor:[UIColor whiteColor]];

    }
    return _hideShowQualityView;
}

#pragma mark - Lazy Init Name Labels

-(UILabel *)temperatureLabel
{
    if (!_temperatureLabel) {
        _temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_temperatureLabel setTag:1];
    }
    return _temperatureLabel;
}

-(UILabel *)pressureLabel
{
    if (!_pressureLabel) {
        _pressureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_pressureLabel setTag:2];
    }
    return _pressureLabel;
}

-(UILabel *)specificVolumeLabel
{
    if (!_specificVolumeLabel) {
        _specificVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_specificVolumeLabel setTag:3];

    }
    return _specificVolumeLabel;
}

-(UILabel *)internalEnergyLabel
{
    if (!_internalEnergyLabel) {
        _internalEnergyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_internalEnergyLabel setTag:4];
    }
    return _internalEnergyLabel;
}

-(UILabel *)enthalpyLabel
{
    if (!_enthalpyLabel) {
        _enthalpyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_enthalpyLabel setTag:5];

    }
    return _enthalpyLabel;
}

-(UILabel *)entropyLabel
{
    if (!_entropyLabel) {
        _entropyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_entropyLabel setTag:6];
    }
    return _entropyLabel;
}

-(UILabel *)qualityLabel
{
    if (!_qualityLabel) {
        _qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_qualityLabel setTag:7];
    }
    return _qualityLabel;
}

#pragma mark - Lazy Init Text Fields

-(UITextField *)temperatureTextField
{
    if (!_temperatureTextField) {
        _temperatureTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_temperatureTextField setText:@""];
        [_temperatureTextField setTag:1];
    }
    return _temperatureTextField;
}

-(UITextField *)pressureTextField
{
    if (!_pressureTextField) {
        _pressureTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_pressureTextField setText:@""];
        [_pressureTextField setTag:2];
    }
    return _pressureTextField;
}

-(UITextField *)specificVolumeTextField
{
    if (!_specificVolumeTextField) {
        _specificVolumeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_specificVolumeTextField setText:@""];
        [_specificVolumeTextField setTag:3];
    }
    return _specificVolumeTextField;
}

-(UITextField *)internalEnergyTextField
{
    if (!_internalEnergyTextField) {
        _internalEnergyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_internalEnergyTextField setText:@""];
        [_internalEnergyTextField setTag:4];
    }
    return _internalEnergyTextField;
}

-(UITextField *)enthalpyTextField
{
    if (!_enthalpyTextField) {
        _enthalpyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_enthalpyTextField setText:@""];
        [_enthalpyTextField setTag:5];
    }
    return _enthalpyTextField;
}

-(UITextField *)entropyTextField
{
    if (!_entropyTextField) {
        _entropyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_entropyTextField setText:@""];
        [_entropyTextField setTag:6];
    }
    return _entropyTextField;
}

-(UITextField *)qualityTextField
{
    if (!_qualityTextField) {
        _qualityTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_qualityTextField setText:@""];
        [_qualityTextField setTag:7];
    }
    return _qualityTextField;
}

#pragma mark - Lazy Init Units Labels

-(UILabel *)temperatureUnitsLabel
{
    if (!_temperatureUnitsLabel) {
        _temperatureUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_temperatureUnitsLabel setTag:1];
    }
    return _temperatureUnitsLabel;
}

-(UILabel *)pressureUnitsLabel
{
    if (!_pressureUnitsLabel) {
        _pressureUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_pressureUnitsLabel setTag:2];
    }
    return _pressureUnitsLabel;
}

-(UILabel *)specificVolumeUnitsLabel
{
    if (!_specificVolumeUnitsLabel) {
        _specificVolumeUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_specificVolumeUnitsLabel setTag:3];

    }
    return _specificVolumeUnitsLabel;
}

-(UILabel *)internalEnergyUnitsLabel
{
    if (!_internalEnergyUnitsLabel) {
        _internalEnergyUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_internalEnergyUnitsLabel setTag:4];
    }
    return _internalEnergyUnitsLabel;
}

-(UILabel *)enthalpyUnitsLabel
{
    if (!_enthalpyUnitsLabel) {
        _enthalpyUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_enthalpyUnitsLabel setTag:5];

    }
    return _enthalpyUnitsLabel;
}

-(UILabel *)entropyUnitsLabel
{
    if (!_entropyUnitsLabel) {
        _entropyUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_entropyUnitsLabel setTag:6];
    }
    return _entropyUnitsLabel;
}

-(UILabel *)qualityUnitsLabel
{
    if (!_qualityUnitsLabel) {
        _qualityUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4.0, self.frame.size.height/tempDiv)];
        [_qualityUnitsLabel setTag:7];
    }
    return _qualityUnitsLabel;
}

#pragma mark - Dynamic Methods

-(void)updateTitle:(NSString *)title
{
    if (title) {
        [self.title setText:title];
        [self.title sizeToFit];
    }
}

-(void)updateTextFieldsWithTemperature:(NSNumber *)temperature
                              pressure:(NSNumber *)pressure
                        specificVolume:(NSNumber *)specificVolume
                        internalEnergy:(NSNumber *)internalEnergy
                              enthalpy:(NSNumber *)enthalpy
                               entropy:(NSNumber *)entropy
                               quality:(NSNumber *)quality;
{
    if (temperature) {
        self.temperature = temperature;
        [self.temperatureTextField setText:[NSString stringWithFormat:@"%d",[temperature intValue]]];
    }

    if (pressure) {
        self.pressure = pressure;
        if (pressure.integerValue >= 1000) {
            [self.pressureTextField setText:[NSString stringWithFormat:@"%.1f",[pressure floatValue]/1000.]];

            if ([self.pressureUnitsLabel.text isEqualToString:@"kPa"]) {
                [self.pressureUnitsLabel setText:@"MPa"];
            }
        } else {
            [self.pressureTextField setText:[NSString stringWithFormat:@"%.1f",[pressure floatValue]]];

            if ([self.pressureUnitsLabel.text isEqualToString:@"MPa"]) {
                [self.pressureUnitsLabel setText:@"kPa"];
            }
        }
    }

    if (specificVolume) {
        if (specificVolume.floatValue < 10) {
            [self.specificVolumeTextField setText:[NSString stringWithFormat:@"%.4f", [specificVolume floatValue]]];
        } else {
            [self.specificVolumeTextField setText:[NSString stringWithFormat:@"%.3f", [specificVolume floatValue]]];
        }
    }

    if (internalEnergy) {
        [self.internalEnergyTextField setText:[NSString stringWithFormat:@"%.1f", [internalEnergy floatValue]]];
    }

    if (enthalpy) {
        [self.enthalpyTextField setText:[NSString stringWithFormat:@"%.1f", [enthalpy floatValue]]];
    }

    if (entropy) {
        [self.entropyTextField setText:[NSString stringWithFormat:@"%.2f", [entropy floatValue]]];
    }

    if (quality.floatValue && quality.floatValue != -1) {
        [self showQuality];
        [self.qualityTextField setText:[NSString stringWithFormat:@"%.1f", [quality floatValue]]];
    } else {
        [self hideQuality];
    }
}

- (void)hideQuality {
    [self.hideShowQualityView setHidden:NO];
    self.qualityIsHidden = YES;
}

- (void)showQuality {
    [self.hideShowQualityView setHidden:YES];
    self.qualityIsHidden = NO;
}

-(void)changeUnit:(NSString *)unit withTag:(NSUInteger)index
{
    NSArray *unitLabels = self.unitsContainer.subviews;

    for (UILabel *label in unitLabels) {
        if (label.tag == index) {
            [label setText:unit];
        }
    }
}

@end
