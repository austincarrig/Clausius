//
//  ViewController.h
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUALocationIndicatorImageView.h"
#import "RUADisplayView.h"

@interface ViewController : UIViewController <RUALocationIndicatorImageViewDataSource,RUADisplayViewDataSource,RUALocationIndicatorImageViewDelegate> {
	float priorX;
	float priorY;
}

@end