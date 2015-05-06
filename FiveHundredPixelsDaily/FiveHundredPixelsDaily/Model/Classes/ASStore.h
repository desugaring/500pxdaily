//
//  ASStore.h
//  
//
//  Created by Alex Semenikhine on 2015-04-11.
//
//

@import Foundation;
@import CoreData;
#import "ASBaseObject.h"
#import "ASModel.h"

@class ASCategory;

@interface ASStore : ASBaseObject

@property (nonatomic, retain) NSOrderedSet *categories;
@property (nonatomic, retain) ASModel *model;

- (void)updateCategoriesIfNeeded;
- (NSArray *)activeCategories;

@end