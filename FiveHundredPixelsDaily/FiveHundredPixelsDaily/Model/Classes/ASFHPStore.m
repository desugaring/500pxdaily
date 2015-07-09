//
//  ASFHPStore.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASFHPStore.h"
#import "ASCategory.h"

@implementation ASFHPStore

- (NSArray *)categoryNames {
    return @[@"Abstract", @"Animals", @"Black and White", @"City & Architecture", @"Concert", @"Family", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
//    return @[@"Abstract", @"Animals", @"Black and White", @"Celebrities", @"City & Architecture", @"Commercial", @"Concert", @"Family", @"Fashion", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"People", @"Performing Arts", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
}

- (void)updateCategoriesIfNeeded {
    // Create categories if they don't already exist
    if (self.categories.count != self.categoryNames.count) {
        NSMutableOrderedSet *newCategories = [NSMutableOrderedSet new];
        [newCategories addObjectsFromArray:self.categories.array];
        for (NSString *categoryName in self.categoryNames) {
            BOOL containsName = false;
            for (ASCategory *category in self.categories) {
                if ([category.name isEqualToString:categoryName]) {
                    containsName = true;
                }
            }
            if (containsName == false) {
                ASCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
                category.name = categoryName;
                [newCategories addObject:category];
            }
        }
        [newCategories sortUsingComparator:^NSComparisonResult(ASCategory *obj1, ASCategory *obj2) {
            if ([obj1.name integerValue] > [obj2.name integerValue])  return (NSComparisonResult)NSOrderedDescending;
            if ([obj1.name integerValue] < [obj2.name integerValue]) return (NSComparisonResult)NSOrderedAscending;
            return (NSComparisonResult)NSOrderedSame;
        }];
        self.categories = (NSOrderedSet *)newCategories.copy;
    }
}

@end
