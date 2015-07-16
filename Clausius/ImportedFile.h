//
//  ImportedFile.h
//  Mvuke
//
//  Created by Austin Carrig on 6/20/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImportedFile : NSManagedObject

@property (nonatomic, retain) NSString * graphType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;

@end
