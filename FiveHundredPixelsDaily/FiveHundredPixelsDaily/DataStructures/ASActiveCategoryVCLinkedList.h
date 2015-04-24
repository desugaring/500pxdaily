//
//  ASActiveCategoryVCLinkedList.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASLinkedList.h"
#import "ASCategoryCollectionViewController.h"

@interface ASActiveCategoryVCLinkedList : ASLinkedList

@property (readonly) ASCategoryCollectionViewController *categoryVC;
@property (readonly) NSArray *categories;

- (instancetype)initWithCategoryVC:(ASCategoryCollectionViewController *)categoryVC categories:(NSArray *)categories;

@end
