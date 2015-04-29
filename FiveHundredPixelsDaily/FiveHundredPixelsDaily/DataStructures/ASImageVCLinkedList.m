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

@end

@implementation ASImageVCLinkedList

- (instancetype)initWithImageVC:(ASImageViewController *)imageVC {
    if (self = [super init]) {
        _imageVC = imageVC;
        _nextExists = true;
        _prevExists = true;
    }
    return self;
}

- (ASImageVCLinkedList *)prev {
    if (self.prevExists == false) return nil;
    if (self.prevExists == true && _prev != nil) return _prev;

    NSUInteger imageIndex = [self.imageVC.image.category.images indexOfObject:self.imageVC.image];
    if (imageIndex != 0) {
        ASImageViewController *newImageVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FullImageVC"];
        newImageVC.image = self.imageVC.image.category.images[imageIndex-1];

        _prev = [[ASImageVCLinkedList alloc] initWithImageVC:newImageVC];
        _prev.next = self;
        return _prev;
    } else {
        self.prevExists = false;
        return nil;
    }
}

- (ASImageVCLinkedList *)next {
    if (self.nextExists == false) return nil;
    if (self.nextExists == true && _next != nil) return _next;

    NSUInteger imageIndex = [self.imageVC.image.category.images indexOfObject:self.imageVC.image];
    if (imageIndex != self.imageVC.image.category.images.count-1) {
        ASImageViewController *newImageVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FullImageVC"];
        newImageVC.image = self.imageVC.image.category.images[imageIndex+1];

        _next = [[ASImageVCLinkedList alloc] initWithImageVC:newImageVC];
        _next.prev = self;
        return _next;
    } else {
        self.nextExists = false;
        return nil;
    }
}

@end
