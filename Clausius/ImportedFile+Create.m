//
//  ImportedFile+Create.m
//  Mvuke
//
//  Created by Austin Carrig on 6/20/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ImportedFile+Create.h"

@implementation ImportedFile (Create)
+ (ImportedFile *)createImportedFileWithName:(NSString *)name type:(NSString *)type inContext:(NSManagedObjectContext *)context
{
    ImportedFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"ImportedFile"
                                                       inManagedObjectContext:context];

    [file setName:name];
    [file setType:type];

    return file;
}
@end
