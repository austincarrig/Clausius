//
//  ViewController.h
//  Mvuke
//
//  Created by Austin Carrig on 5/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationIndicatorImageView.h"
#import "DisplayView.h"

@interface ViewController : UIViewController <LocationIndicatorImageViewDataSource,DisplayViewDataSource,LocationIndicatorImageViewDelegate> {
	float priorX;
	float priorY;
}

@end