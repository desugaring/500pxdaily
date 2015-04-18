//
//  ASPhotosStore.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASPhotosStore.h"
#import "ASCategory.h"
#import "ASModel.h"
#import "ASPhotosOperation.h"

@implementation ASPhotosStore

- (ASCategory *)category {
    return ((ASCategory *)self.categories[0]);
}

-(ASBaseOperation *)operation {
    return [[ASPhotosOperation alloc] init];
}

- (void)awakeCommon {
    NSLog(@"awake local");
    if (self.categories.count == 0) {
        ASCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
        category.store = self;
    }
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:DefaultsLocalCategoryNameKey options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:DefaultsLocalCategoryNameKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [NSUserDefaults standardUserDefaults] && [keyPath isEqualToString:DefaultsLocalCategoryNameKey]) {
        // check if the name matches, otherwise change it, reset the images
        NSLog(@"keyPath: %@, object: %@, change: %@", keyPath, object, change);
        if ([self.category.name isEqualToString:(NSString *)change[NSKeyValueChangeNewKey]] == FALSE) {
            self.category.name = (NSString *)change[NSKeyValueChangeNewKey];
            [self.category resetImages];
        }
    }

}

@end
