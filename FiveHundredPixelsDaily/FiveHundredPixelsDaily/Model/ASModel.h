//
//  ASModel.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;
@class ASPhotosStore;
@class ASFHPStore;

static NSString * const DefaultsLocalCategoryNameKey = @"PhotosCategoryName";

@interface ASModel : NSObject

@property NSManagedObjectContext *moc;
@property ASPhotosStore *photosStore;
@property ASFHPStore *fhpStore;

- (void)save;

// has all the core data cruft

// stores array

// singleton that all UI accesses for its data

// init creates local store and populates it if it doesn't exist

@end
