
//
//  ASCategoriesPagesViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-18.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCategoryCollectionViewController.h"
#import "ASCategory.h"

@interface ASCategoriesPagesViewController : UIViewController <ASCategoryCollectionViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property NSOrderedSet *categories;
@property ASCategory *initialActiveCategory;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *prevCategoryButton;
@property (weak, nonatomic) IBOutlet UIButton *nextCategoryButton;

- (IBAction)goToPrevCategory:(id)sender;
- (IBAction)goToNextCategory:(id)sender;

@end
