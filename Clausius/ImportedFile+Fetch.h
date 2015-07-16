//
//  ImportedFile+Fetch.h
//  Mvuke
//
//  Created by Austin Carrig on 6/20/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ImportedFile.h"

@interface ImportedFile (Fetch)
+ (NSArray *)fetchAllImportedFilesInContext:(NSManagedObjectContext *)context;
+ (ImportedFile *)fetchImportedFileWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
@end
