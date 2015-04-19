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

@class ASCategory;

@interface ASStore : ASBaseObject

@property (nonatomic, retain) NSOrderedSet *categories;
- (void)updateCategoriesIfNeeded;

@end

@interface ASStore (CoreDataGeneratedAccessors)

- (void)insertObject:(ASCategory *)value inCategoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCategoriesAtIndex:(NSUInteger)idx;
- (void)insertCategories:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCategoriesAtIndex:(NSUInteger)idx withObject:(ASCategory *)value;
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray *)values;
- (void)addCategoriesObject:(ASCategory *)value;
- (void)removeCategoriesObject:(ASCategory *)value;
- (void)addCategories:(NSOrderedSet *)values;
- (void)removeCategories:(NSOrderedSet *)values;
@end