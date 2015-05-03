
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
#import "ASButtonView.h"

@interface ASCategoriesPagesViewController : UIViewController <ASCategoryCollectionViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property NSArray *categories;
@property ASCategory *initialActiveCategory;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet ASButtonView *nextButtonView;
@property (weak, nonatomic) IBOutlet ASButtonView *prevButtonView;

- (void)goToPrevCategory:(id)sender;
- (void)goToNextCategory:(id)sender;

@end
