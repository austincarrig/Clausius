//
//  ImportedFile+Fetch.m
//  Mvuke
//
//  Created by Austin Carrig on 6/20/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ImportedFile+Fetch.h"

@implementation ImportedFile (Fetch)
+ (NSArray *)fetchAllImportedFilesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ImportedFile"];
    
    NSError *error;
    NSArray *files = [context executeFetchRequest:request error:&error];
    
    if (error) {
	    NSLog(@"Error in fetching imported files:%@, %@",error,[error userInfo]);
	    abort();
    }
    
    return files;
}

+ (ImportedFile *)fetchImportedFileWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ImportedFile"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *files = [context executeFetchRequest:request
    	    	    	    	    	    error:&error];
    
    if (error) {
	    NSLog(@"Error in fetching imported file with name == %@: %@, %@",name,error,[error userInfo]);
	    abort();
    }
    
    return (ImportedFile *)[files lastObject];
}
@end
