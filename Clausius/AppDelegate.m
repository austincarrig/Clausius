/*
 * FILE : AppDelegate.cpp
 *
 * Created by Austin Carrig, some time in 2015
 *
 */


#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Get the bundle root (should just be able to use the bundle, but whatever...)
    NSString *bundleRoot = [[NSBundle mainBundle] resourcePath];
    // Drill down to the DataFiles directory
    NSString *zpath = [bundleRoot stringByAppendingString:@"/DataFiles"];
    // Build an NSFileManager
    NSFileManager *fm = [NSFileManager defaultManager];
    // Use the NSFileManager to get the contents of the bundle path
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:zpath error:nil];
    // Build a filter for .csv files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.csv'"];
    // Use the filter on the directory's contents to get the .csv files
    NSArray *allCSVs = [dirContents filteredArrayUsingPredicate:fltr];

    BOOL newfiles = NO;

    NSLog(@"%@",allCSVs);

    // Iterate through the files...
    for (NSString* fileName in allCSVs) {
        // if they can't be found in the CoreData DB...
        /*
        if (![ImportedFile fetchImportedFileWithName:fileName
                                           inContext:self.managedObjectContext]) {
            newfiles = YES;
            NSString *type;
            NSString *area;
            // Scan through the file name
            NSScanner *fileNameScanner = [NSScanner scannerWithString:fileName];
            // Find the underscore...
            [fileNameScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]
                                            intoString:&type];
            // Go past the underscore...
            [fileNameScanner setScanLocation:[fileNameScanner scanLocation]+1];
            // Scan up to the next underscore or period, and read that string in area...
            [fileNameScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"._"]
                                            intoString:&area];

            // If area is Saturated (so if the csv file is for Saturated region)...
            if ([area isEqualToString:@"Saturated"]) {
                // Load the saturated file...
                [self loadSaturatedFile:fileName type:type];
                // And load it into the CoreData DB...
                ImportedFile *file = [ImportedFile createImportedFileWithName:fileName
                                                                         type:type
                                                                    inContext:self.managedObjectContext];

                NSLog(@"%@",file);
            }
        }
         */
    }

    // If we loaded new files into the CoreData context...
    /*
    if (newfiles) {
        NSError *error;
        // Save the context...
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", error ? error : @"Unknown Error");
        }
    }
     */
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

#pragma mark - Custom Methods

/// fileName should be the file's name with '.csv' on the end
/*
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
*/
@end
