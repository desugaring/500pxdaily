//
//  ASImageVCLinkedList.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-27.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASImageViewController.h"
#import "ASCategory.h"

@interface ASImageVCLinkedList : NSObject

@property (readonly) ASImageViewController *imageVC;
@property (nonatomic) ASImageVCLinkedList *next;
@property (nonatomic) ASImageVCLinkedList *prev;

- (instancetype)initWithImageVC:(ASImageViewController *)imageVC;

@end
