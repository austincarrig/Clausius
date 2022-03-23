//
//  RUSolver.h
//  Clausius
//
//  Created by Austin Carrig on 10/15/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Looks like this is just 1 equation I may have used at some point, but right now it's unused...
 * Can prob delete...
 */

@interface RUSolver : NSObject
+ (float)temperatureForSpecificVolume:(float)specVol andPressure:(float)pressure;
@end
