//
//  ASCategoryVCLinkedList.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryCollectionViewController.h"

@interface ASCategoryVCLinkedList : NSObject

@property (readonly) ASCategoryCollectionViewController *categoryVC;
@property (readonly) NSArray *categories;
@property (nonatomic) ASCategoryVCLinkedList *next;
@property (nonatomic) ASCategoryVCLinkedList *prev;

- (instancetype)initWithCategoryVC:(ASCategoryCollectionViewController *)categoryVC categories:(NSArray *)categories;

@end
