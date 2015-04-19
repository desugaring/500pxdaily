//
//  ASModel.h
//  
//
//  Created by Alex Semenikhine on 2015-04-18.
//
//

@import Foundation;
@import CoreData;

@class ASStore;

@interface ASModel : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *stores;
@end

@interface ASModel (CoreDataGeneratedAccessors)

- (void)insertObject:(ASStore *)value inStoresAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStoresAtIndex:(NSUInteger)idx;
- (void)insertStores:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStoresAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStoresAtIndex:(NSUInteger)idx withObject:(ASStore *)value;
- (void)replaceStoresAtIndexes:(NSIndexSet *)indexes withStores:(NSArray *)values;
- (void)addStoresObject:(ASStore *)value;
- (void)removeStoresObject:(ASStore *)value;
- (void)addStores:(NSOrderedSet *)values;
- (void)removeStores:(NSOrderedSet *)values;

@end
