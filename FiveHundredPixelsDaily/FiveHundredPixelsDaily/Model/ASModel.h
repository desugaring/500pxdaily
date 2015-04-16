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
#import "ASCategory.h"

static NSString * const DefaultsLocalCategoryNameKey = @"PhotosCategoryName";

@interface ASModel : NSObject

@property (nonatomic) ASPhotosStore *photosStore;
@property (nonatomic)  ASFHPStore *fhpStore;
- (ASCategory *)activeCategory;

- (void)save;

// has all the core data cruft

// stores array

// singleton that all UI accesses for its data

// init creates local store and populates it if it doesn't exist

@end
