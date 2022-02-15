
#import "AppDelegate.h"
#import "CoreData.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSString *bundleRoot = [[NSBundle mainBundle] resourcePath];
    NSString *zpath = [bundleRoot stringByAppendingString:@"/DataFiles"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:zpath error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.csv'"];
    NSArray *allCSVs = [dirContents filteredArrayUsingPredicate:fltr];

    BOOL newfiles = NO;

    NSLog(@"%@",allCSVs);

    for (NSString* fileName in allCSVs) {
        if (![ImportedFile fetchImportedFileWithName:fileName
                                           inContext:self.managedObjectContext]) {
            newfiles = YES;
            NSString *type;
            NSString *area;
            NSScanner *fileNameScanner = [NSScanner scannerWithString:fileName];
            [fileNameScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]
                                            intoString:&type];
            [fileNameScanner setScanLocation:[fileNameScanner scanLocation]+1];
            [fileNameScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"._"]
                                            intoString:&area];

            if ([area isEqualToString:@"Saturated"]) {
                [self loadSaturatedFile:fileName type:type];

                ImportedFile *file = [ImportedFile createImportedFileWithName:fileName
                                                                         type:type
                                                                    inContext:self.managedObjectContext];

                NSLog(@"%@",file);
            }
        }
    }

    if (newfiles) {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", error ? error : @"Unknown Error");
        }
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Austin.Mvuke" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Clausius" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Clausius.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Custom Methods

/// fileName should be the file's name with '.csv' on the end

- (void)loadSaturatedFile:(NSString *)fileName type:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:@"DataFiles"];
    NSString *string = [NSString stringWithUTF8String:[[NSData dataWithContentsOfFile:path] bytes]];

    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\n, "]];

    NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];

    while (![scanner isAtEnd]) {
        SaturatedPlotPoint *plotPoint = [SaturatedPlotPoint createSatPlotPointWithType:type
                                                                             inContext:self.managedObjectContext];
        NSString *lineString;
        [scanner scanUpToCharactersFromSet:newline
                                intoString:&lineString];
        [scanner setScanLocation:[scanner scanLocation]+1];
        if (lineString) {
            NSString *placeholder;
            NSScanner *smallScanner = [NSScanner scannerWithString:lineString];
            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setT:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setP:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setV_f:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setV_g:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setU_f:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setU_g:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setH_f:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setH_g:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [smallScanner setScanLocation:[smallScanner scanLocation]+1];
            [plotPoint setS_f:[NSNumber numberWithFloat:[placeholder floatValue]]];

            [smallScanner scanUpToCharactersFromSet:comma
                                         intoString:&placeholder];
            [plotPoint setS_g:[NSNumber numberWithFloat:[placeholder floatValue]]];
        }
    }
}

@end
