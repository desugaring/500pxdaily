//
//  ASModel.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASModel.h"
#import "ASStore.h"
@import CoreData;

@interface ASModel()

@property NSManagedObjectContext *moc;
@property NSManagedObjectModel *mom;
@property NSPersistentStoreCoordinator *psc;
@property ASStore *photosStore;
@property ASStore *fhpStore;

@end

@implementation ASModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureStore];
    }
    return self;
}

- (void)configureStore {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];

    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count] != 2) {

        self.fhpStore = [[ASStore alloc] initWithEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.moc] insertIntoManagedObjectContext:self.managedObjectContext];
        self.fhpStore.name = @"500px";
        self.fhpStore.type = @"fhp";

        self.photosStore = [[ASStore alloc] initWithEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.moc] insertIntoManagedObjectContext:self.moc];
        self.photosStore.name = @"Photos";
        self.photosStore.type = @"photos";
    }

    [self.photosStore updateCategories];

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
    self.moc = [[NSManagedObjectContext alloc] init];
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
