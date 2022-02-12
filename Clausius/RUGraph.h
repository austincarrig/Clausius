//
//  RUGraph.h
//  Clausius
//
//  Created by Austin Carrig on 10/13/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RUAxis.h"

/**
 *  RUGraph is an abstract superclass of RUChart. When working with data use RUChart.
 */

@interface RUGraph : NSObject
@property (strong, nonatomic) RUAxis *xAxis;
@property (strong, nonatomic) RUAxis *yAxis;

/**
 *  Function to set an axis of the graph. The function will determine which axis it is based on RUAxis's direction property.
 *
 *  @param axis An instance of RUAxis
 */

- (void)setAxis:(RUAxis *)axis;
@end
