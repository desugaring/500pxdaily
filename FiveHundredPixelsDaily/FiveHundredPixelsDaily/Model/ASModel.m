//
//  ASModel.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASModel.h"
#import "ASFHPStore.h"
#import "ASPhotosStore.h"

@interface ASModel()

@property NSManagedObjectModel *mom;
@property NSPersistentStoreCoordinator *psc;
@property NSManagedObjectContext *moc;

@property (nonatomic) ASPhotosStore *photosStore;
@property (nonatomic) ASFHPStore *fhpStore;
@property (nonatomic, readwrite) ASStore *activeStore;

@end

@implementation ASModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"PhotosCategoryName": @"500px Daily" }];

        // Store inits, create if they don't already exist
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
        NSError *error;
        NSArray *stores = [self.managedObjectContext executeFetchRequest:request error:&error];

        if ([stores count] != 2) {
            self.fhpStore = [[ASFHPStore alloc] initWithEntity:[NSEntityDescription entityForName:@"FHPStore" inManagedObjectContext:self.moc] insertIntoManagedObjectContext:self.managedObjectContext];
            self.fhpStore.name = @"500px";

            self.photosStore = [[ASPhotosStore alloc] initWithEntity:[NSEntityDescription entityForName:@"PhotosStore" inManagedObjectContext:self.moc] insertIntoManagedObjectContext:self.moc];
            self.photosStore.name = @"Photos";
        } else {
            for (ASStore *store in stores) {
                if ([store isKindOfClass: ASPhotosStore.class]) {
                    self.photosStore = (ASPhotosStore *)store;
                } else if ([store isKindOfClass: ASFHPStore.class]) {
                    self.fhpStore = (ASFHPStore *)store;
                }
            }
        }

        [self.fhpStore createCategoriesIfNeeded];

        // Set active category
        NSString *activeCategoryName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveCategory"];
        if (activeCategoryName == nil)  activeCategoryName = @"Landscapes";

        [self.fhpStore.categories enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ASCategory *category, NSUInteger idx, BOOL *stop) {
            if ([category.name isEqualToString:activeCategoryName]) {
                [self selectCategory:category];
                *stop = true;
            }
        }];
    }
    
    return self;
}

- (void)selectCategory:(ASCategory *)category {
    // Previous category now no longer active
    if (self.activeStore != nil) self.activeStore.activeCategory.isActive = false;

    // Set new store if store changed
    if (category.store != self.activeStore) self.activeStore = category.store;

    // Set and mark new active category
    self.activeStore.activeCategory = category;
    self.activeStore.activeCategory.isActive = true;
}

#pragma mark - Core Data stack

- (void)save {
    [self deleteAllImages];
    [self saveContext];
}

- (void)deleteAllImages {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Image"];
    NSError *error;
    NSArray *images = [self.moc executeFetchRequest:request error:&error];

    for (ASImage *image in images) {
        [self.moc deleteObject:(NSManagedObject *)image];
    }
}

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
