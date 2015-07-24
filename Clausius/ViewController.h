//
//  ViewController.h
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUAAdjusterView.h"
#import "RUALocationIndicatorImageView.h"
#import "RUADisplayView.h"

@interface ViewController : UIViewController <RUALocationIndicatorImageViewDataSource,RUALocationIndicatorImageViewDelegate,RUADisplayViewDataSource,RUAAdjusterViewDelegate> {
	float priorX;
	float priorY;
	float currentTemp;
	float currentEntropy;
	BOOL touchHasRegistered;
}

@end