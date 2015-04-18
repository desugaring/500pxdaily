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

@property (readonly) ASStore *activeStore;

- (void)selectCategory:(ASCategory *)category;
- (void)save;

@end
