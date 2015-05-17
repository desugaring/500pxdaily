//
//  ASImageVCLinkedList.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-27.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImageVCLinkedList.h"

@interface ASImageVCLinkedList()

@property ASImageVCLinkedList *nextImage;
@property ASImageVCLinkedList *prevImage;
@property BOOL nextExists;
@property BOOL prevExists;
@property NSLock *prevLock;
@property NSLock *nextLock;

@end

@implementation ASImageVCLinkedList

- (instancetype)initWithImageVC:(ASImageViewController *)imageVC {
    if (self = [super init]) {
        _imageVC = imageVC;
        _nextExists = true;
        _prevExists = true;
        _prevLock = [NSLock new];
        _nextLock = [NSLock new];
    }
    return self;
}

- (ASImageVCLinkedList *)prev {
    [self.prevLock lock];
    ASImageVCLinkedList *returnValue = nil;
    if (self.prevExists == true && _prev != nil) {
        returnValue = _prev;
    } else if (self.prevExists == true) {
        NSUInteger imageIndex = [self.imageVC.image.category.images indexOfObject:self.imageVC.image];
        if (imageIndex != 0) {
            ASImageViewController *newImageVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FullImageVC"];
            newImageVC.image = self.imageVC.image.category.images[imageIndex-1];

            _prev = [[ASImageVCLinkedList alloc] initWithImageVC:newImageVC];
            _prev.next = self;
            returnValue = _prev;
        } else {
            self.prevExists = false;
        }
    }
    [self.prevLock unlock];
    return returnValue;
}

- (ASImageVCLinkedList *)next {
    [self.nextLock lock];
    ASImageVCLinkedList *returnValue = nil;
    if (self.nextExists == true && _next != nil) {
        returnValue = _next;
    } else if (self.nextExists == true) {
        NSUInteger imageIndex = [self.imageVC.image.category.images indexOfObject:self.imageVC.image];
        // If it's not last image
        if (imageIndex != self.imageVC.image.category.images.count-1) {
            ASImageViewController *newImageVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FullImageVC"];
            newImageVC.image = self.imageVC.image.category.images[imageIndex+1];

            _next = [[ASImageVCLinkedList alloc] initWithImageVC:newImageVC];
            _next.prev = self;
            returnValue = _next;
        } else {
            // If it was the last image, we need to make sure it is because the category is not going to get anymore new images
            // That's the case if the category is stale, needs to be refreshed immediately or is up to date
            NSInteger stateIntegerValue = self.imageVC.image.category.state.integerValue;
            if (stateIntegerValue == ASCategoryStateUpToDate || stateIntegerValue == ASCategoryStateStale || ASCategoryStateRefreshImmediately) self.nextExists = false;
        }
    }
    [self.nextLock unlock];
    return returnValue;
}

@end
