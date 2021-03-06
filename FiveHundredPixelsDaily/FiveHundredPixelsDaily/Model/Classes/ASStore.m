//
//  ASStore.m
//  
//
//  Created by Alex Semenikhine on 2015-04-11.
//
//

#import "ASStore.h"
#import "ASCategory.h"

@implementation ASStore

@dynamic categories;
@synthesize model;

- (void)updateCategoriesIfNeeded {
    // Stub
}

- (NSArray *)activeCategories {
    NSMutableArray *activeCategories = [NSMutableArray new];
    for (ASCategory *category in self.categories) {
        if ([category.isActive isEqualToNumber:@(1)] == true) [activeCategories addObject:category];
    }
    return activeCategories;
}

@end