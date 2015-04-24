//
//  ASActiveCategoryVCLinkedList.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASActiveCategoryVCLinkedList.h"
#import "ASCategory.h"
#import "ASStore.h"

@implementation ASActiveCategoryVCLinkedList

- (instancetype)initWithCategoryVC:(ASCategoryCollectionViewController *)categoryVC categories:(NSArray *)categories {
    if (self = [super initWithObject:categoryVC]) {
        _categoryVC = categoryVC;
        _categories = categories;
    }
    return self;
}

- (ASLinkedList *)prev {
    if (super.prev == nil) {
        NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];
        
        if (categoryIndex != 0) {
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = self.categories[categoryIndex-1];
            newCategoryVC.delegate = self.categoryVC.delegate;

            super.prev = [[ASActiveCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
            super.prev.next = self;
        }
    }
    return super.prev;
}

- (ASLinkedList *)next {
    if (super.next == nil) {
        NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];

        if (categoryIndex != self.categories.count-1) {
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = self.categories[categoryIndex+1];
            newCategoryVC.delegate = self.categoryVC.delegate;

            super.next = [[ASActiveCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
            super.next.prev = self;
        }
    }
    return super.next;
}

@end
