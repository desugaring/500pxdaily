//
//  ASCategoryVCLinkedList.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryVCLinkedList.h"
#import "ASCategoryCollectionViewController.h"
#import "ASCategory.h"
#import "ASStore.h"

@implementation ASCategoryVCLinkedList

- (ASLinkedList *)prev {
    if (self.prev == nil) {
        ASCategoryCollectionViewController *vc = (ASCategoryCollectionViewController *)self.object;
        ASStore *store = vc.category.store;
        NSUInteger categoryIndex = [store.categories indexOfObject:vc.category];
        
        if (categoryIndex != 0) {
            ASCategory *prevCategory = store.categories[categoryIndex-1];
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = prevCategory;

            self.prev = [[ASLinkedList alloc] initWithObject:newCategoryVC];
        }
    }
    return self.prev;
}

- (ASLinkedList *)next {
    if (self.next == nil) {
        ASCategoryCollectionViewController *vc = (ASCategoryCollectionViewController *)self.object;
        ASStore *store = vc.category.store;
        NSUInteger categoryIndex = [store.categories indexOfObject:vc.category];

        if (categoryIndex != store.categories.count-1) {
            ASCategory *nextCategory = store.categories[categoryIndex+1];
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = nextCategory;

            self.next = [[ASLinkedList alloc] initWithObject:newCategoryVC];
        }
    }
    return self.next;
}

@end
