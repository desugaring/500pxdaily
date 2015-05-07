//
//  AppDelegate.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "AppDelegate.h"
#import "ASModel.h"
#import "ASFHPStore.h"
#import "ASCategoriesTableViewController.h"
#import "ASBackgroundImageFetcher.h"
#import "ASPhotosManager.h"

@interface AppDelegate ()

@property NSManagedObjectModel *mom;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectContext *moc;
@property ASBackgroundImageFetcher *backgroundImageFetcher;
@property ASPhotosManager *photosManager;

@property ASModel *model;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.backgroundImageFetcher = [ASBackgroundImageFetcher new];
    self.photosManager = [[ASPhotosManager alloc] init];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Model"];
    NSError *error;
    NSArray *model = [self.managedObjectContext executeFetchRequest:request error:&error];

    // Get or create model
    if (model.count == 1) {
        self.model = model.firstObject;
    } else {
        ASModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"Model" inManagedObjectContext:[self managedObjectContext]];
        self.model = model;

        // Create stores for model
        ASFHPStore *fhpStore = [NSEntityDescription insertNewObjectForEntityForName:@"FHPStore" inManagedObjectContext:[self managedObjectContext]];
        fhpStore.name = @"500px";
        fhpStore.model = self.model;
    }

    // Update stores
    for (ASStore *store in self.model.stores) {
        [store updateCategoriesIfNeeded];
    }

    // Give store to UI
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    ASCategoriesTableViewController *categoriesTableVC = (ASCategoriesTableViewController *)navigationController.topViewController;
    categoriesTableVC.store = (ASStore *)self.model.stores.firstObject;

    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSMutableArray *dailyCategories = [NSMutableArray new];
    for (ASCategory *category in ((ASStore *)self.model.stores.firstObject).categories) {
        if (category.isDaily.boolValue == true) [dailyCategories addObject:category];
    }
    [self.backgroundImageFetcher fetchImagesWithCategories:dailyCategories completion:completionHandler];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
    NSLog(@"yup");
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

    [self saveContext];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.desugaring.FiveHundredPixelsDaily" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (self.moc != nil) {
        return self.mom;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FiveHundredPixelsDaily" withExtension:@"momd"];
    self.mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.mom;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (self.psc != nil) {
        return self.psc;
    }

    // Create the coordinator and store

    self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FiveHundredPixelsDaily.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

    return self.psc;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (self.moc != nil) {
        return self.moc;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.moc setPersistentStoreCoordinator:coordinator];
    return self.moc;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    if (self.moc != nil) {
        NSError *error = nil;
        if ([self.moc hasChanges] && ![self.moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
