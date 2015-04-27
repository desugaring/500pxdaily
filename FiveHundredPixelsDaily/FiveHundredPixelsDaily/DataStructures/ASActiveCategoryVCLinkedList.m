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

@interface ASActiveCategoryVCLinkedList()

@property NSLock *prevLock;
@property NSLock *nextLock;
@property ASActiveCategoryVCLinkedList *nextCategory;
@property ASActiveCategoryVCLinkedList *prevCategory;
@property BOOL nextExists;
@property BOOL prevExists;

@end

@implementation ASActiveCategoryVCLinkedList

- (instancetype)initWithCategoryVC:(ASCategoryCollectionViewController *)categoryVC categories:(NSArray *)categories {
    if (self = [super init]) {
        _categoryVC = categoryVC;
        _categories = categories;
        _nextExists = true;
        _prevExists = true;
    }
    return self;
}

- (ASActiveCategoryVCLinkedList *)prev {
    if (self.prevExists == false) return nil;
    if (self.prevExists == true && _prev != nil) return _prev;

    NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];
    if (categoryIndex != 0) {
        ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
        newCategoryVC.category = self.categories[categoryIndex-1];
        newCategoryVC.delegate = self.categoryVC.delegate;

        _prev = [[ASActiveCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
        _prev.next = self;
        return _prev;
    } else {
        self.prevExists = false;
        return nil;
    }
}

- (ASActiveCategoryVCLinkedList *)next {
    if (self.nextExists == false) return nil;
    if (self.nextExists == true && _next != nil) return _next;

    NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];
    if (categoryIndex != self.categories.count-1) {
        ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
        newCategoryVC.category = self.categories[categoryIndex+1];
        newCategoryVC.delegate = self.categoryVC.delegate;

        _next = [[ASActiveCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
        _next.prev = self;
        return _next;
    } else {
        self.nextExists = false;
        return nil;
    }
}

@end
