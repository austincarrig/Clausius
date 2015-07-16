//
//  ImportedFile+Create.h
//  Mvuke
//
//  Created by Austin Carrig on 6/20/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ImportedFile.h"

@interface ImportedFile (Create)
+ (ImportedFile *)createImportedFileWithName:(NSString *)name type:(NSString *)type inContext:(NSManagedObjectContext *)context;
@end
