//
//  ASFHPStore.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASFHPStore.h"
#import "ASCategory.h"

@interface ASFHPStore()

@end

@implementation ASFHPStore

- (NSArray *)categoryNames {
    return @[@"Abstract", @"Animals", @"Black and White", @"Celebrities", @"City & Architecture", @"Commercial", @"Concert", @"Family", @"Fashion", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"People", @"Performing Arts", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
}

- (void)awakeCommon {
    NSLog(@"awake remote");
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

    // Set visible category if it is not set
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isVisible == TRUE"];
    request.predicate = predicate;
    NSError *error;
    NSArray *visibleCategoryResult = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (visibleCategoryResult.count == 0) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'Landscapes'"];
        request.predicate = predicate;
        NSError *error;
        NSArray *landscapeCategoryResult = [self.managedObjectContext executeFetchRequest:request error:&error];
        ((ASCategory *)landscapeCategoryResult[0]).isVisible = true;
    } else {
        ((ASCategory *)visibleCategoryResult[0]).isVisible = true;
    }
}

@end
