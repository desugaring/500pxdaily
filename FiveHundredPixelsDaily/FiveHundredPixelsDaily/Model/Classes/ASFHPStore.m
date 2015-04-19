//
//  ASFHPStore.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASFHPStore.h"
#import "ASCategory.h"
#import "ASFHPOperation.h"

@interface ASFHPStore()

@end

@implementation ASFHPStore

-(ASBaseOperation *)operation {
    return [[ASFHPOperation alloc] init];
}

- (NSArray *)categoryNames {
    return @[@"Abstract", @"Animals", @"Black and White", @"Celebrities", @"City & Architecture", @"Commercial", @"Concert", @"Family", @"Fashion", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"People", @"Performing Arts", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
}

- (void)updateCategoriesIfNeeded {
    // Create categories if they don't already exist
    if (self.categories.count != self.categoryNames.count) {
        NSMutableArray *newCategories = [NSMutableArray new];
        for (NSString *categoryName in self.categoryNames) {
            BOOL containsName = false;
            for (ASCategory *category in self.categories) {
                if ([category.name isEqualToString:categoryName]) {
                    containsName = true;
                }
            }
            if (containsName == false) {
                ASCategory *category = [[ASCategory alloc] init];
                category.name = categoryName;
                [newCategories addObject:category];
            }
        }
        [self addCategories:[NSOrderedSet orderedSetWithArray:newCategories]];
    }
}

@end
