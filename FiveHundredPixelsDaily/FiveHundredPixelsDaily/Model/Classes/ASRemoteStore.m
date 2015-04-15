//
//  ASRemoteStore.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASRemoteStore.h"
#import "ASCategory.h"

@interface ASRemoteStore()

@end

@implementation ASRemoteStore

@synthesize activeCategory = _activeCategory;

-(void)setActiveCategory:(ASCategory *)activeCategory {
    if (_activeCategory != nil) {
        _activeCategory.isActive = false;
    }
    _activeCategory = activeCategory;
}

- (NSArray *)categoryNames {
    return @[@"Abstract", @"Animals", @"Black and White", @"Celebrities", @"City & Architecture", @"Commercial", @"Concert", @"Family", @"Fashion", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"People", @"Performing Arts", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
}

- (void)awakeCommon {
    NSLog(@"hi remote ");
    // Create categories if they don't already exist
    if (self.categories.count != self.categoryNames.count) {
        for (NSString *categoryName in self.categoryNames) {
            BOOL containsName = FALSE;
            for (ASCategory *category in self.categories.allObjects) {
                if ([category.name isEqualToString:categoryName]) {
                    containsName = TRUE;
                }
            }
            if (containsName == FALSE) {
                ASCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
                category.name = categoryName;
                category.store = self;
            }
        }
    }

    // Set active category if it is not set
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isActive == TRUE"];
    request.predicate = predicate;
    NSError *error;
    NSArray *activeCategoryResults = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (activeCategoryResults.count == 0) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'Landscapes'"];
        request.predicate = predicate;
        NSError *error;
        NSArray *landscapeCategoryResult = [self.managedObjectContext executeFetchRequest:request error:&error];
        self.activeCategory = (ASCategory *)landscapeCategoryResult[0];
    } else {
        self.activeCategory = (ASCategory *)activeCategoryResults[0];
    }
}

@end
