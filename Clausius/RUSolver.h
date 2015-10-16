//
//  RUSolver.h
//  Clausius
//
//  Created by Austin Carrig on 10/15/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSolver : NSObject
+ (float)temperatureForSpecificVolume:(float)specVol andPressure:(float)pressure;
@end
