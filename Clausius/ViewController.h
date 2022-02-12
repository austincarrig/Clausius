//
//  ViewController.h
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUAAdjusterView.h"
#import "LocationIndicatorImageView.h"
#import "DisplayView.h"

@interface ViewController : UIViewController <LocationIndicatorImageViewDataSource,DisplayViewDataSource,LocationIndicatorImageViewDelegate,RUAAdjusterViewDelegate> {
    float priorX;
    float priorY;
    float currentTemp;
    float currentPressure;
    float currentSpecVolume;
    float currentIntEnergy;
    float currentEnthalpy;
    float currentEntropy;
    float currentQuality;
    BOOL touchHasRegistered;
    BOOL allowQualityScrubbing;
    NSString *currentRegion;
}

@end
