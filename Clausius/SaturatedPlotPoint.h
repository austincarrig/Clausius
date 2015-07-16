//
//  SaturatedPlotPoint.h
//  Mvuke
//
//  Created by Austin Carrig on 6/19/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SaturatedPlotPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * t;
@property (nonatomic, retain) NSNumber * h_f;
@property (nonatomic, retain) NSNumber * h_g;
@property (nonatomic, retain) NSNumber * p;
@property (nonatomic, retain) NSNumber * s_f;
@property (nonatomic, retain) NSNumber * s_g;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * u_f;
@property (nonatomic, retain) NSNumber * u_g;
@property (nonatomic, retain) NSNumber * v_f;
@property (nonatomic, retain) NSNumber * v_g;

@end
