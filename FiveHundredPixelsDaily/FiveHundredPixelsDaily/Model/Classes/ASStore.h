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
@class ASBaseOperation;

@interface ASStore : ASBaseObject

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSSet *categories;

- (ASBaseOperation *)operation;
- (void)updateCategories;

@end

@interface ASStore (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(ASCategory *)value;
- (void)removeCategoriesObject:(ASCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
