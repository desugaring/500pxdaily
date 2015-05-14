//
//  ASCategoryVCLinkedList.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryVCLinkedList.h"
#import "ASCategory.h"
#import "ASStore.h"

@interface ASCategoryVCLinkedList()

@property ASCategoryVCLinkedList *nextCategory;
@property ASCategoryVCLinkedList *prevCategory;
@property BOOL nextExists;
@property BOOL prevExists;
@property NSLock *prevLock;
@property NSLock *nextLock;

@end

@implementation ASCategoryVCLinkedList

- (instancetype)initWithCategoryVC:(ASCategoryCollectionViewController *)categoryVC categories:(NSArray *)categories {
    if (self = [super init]) {
        _categoryVC = categoryVC;
        _categories = categories;
        _nextExists = true;
        _prevExists = true;
        _prevLock = [NSLock new];
        _nextLock = [NSLock new];
    }
    return self;
}

- (ASCategoryVCLinkedList *)prev {
    [self.prevLock lock];
    ASCategoryVCLinkedList *returnValue = nil;
    if (self.prevExists == true && _prev != nil) {
        returnValue = _prev;
    } else if (self.prevExists == true) {
        NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];
        if (categoryIndex != 0) {
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = self.categories[categoryIndex-1];
            newCategoryVC.delegate = self.categoryVC.delegate;

            _prev = [[ASCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
            _prev.next = self;
            returnValue = _prev;
        } else {
            self.prevExists = false;
        }
    }
    [self.prevLock unlock];
    return returnValue;
}

- (ASCategoryVCLinkedList *)next {
    [self.nextLock lock];
    ASCategoryVCLinkedList *returnValue = nil;
    if (self.nextExists == true && _next != nil) {
        [self.nextLock unlock];
        return _next;
    } else if (self.nextExists == true) {
        NSUInteger categoryIndex = [self.categories indexOfObject:self.categoryVC.category];
        if (categoryIndex != self.categories.count-1) {
            ASCategoryCollectionViewController *newCategoryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
            newCategoryVC.category = self.categories[categoryIndex+1];
            newCategoryVC.delegate = self.categoryVC.delegate;

            _next = [[ASCategoryVCLinkedList alloc] initWithCategoryVC:newCategoryVC categories:self.categories];
            _next.prev = self;
            returnValue = _next;
        } else {
            self.nextExists = false;
        }
    }
    [self.nextLock unlock];
    return returnValue;
}

@end
