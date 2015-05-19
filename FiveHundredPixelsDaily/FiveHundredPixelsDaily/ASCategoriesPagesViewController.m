//
//  ASCategoriesPagesViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-18.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoriesPagesViewController.h"
#import "ASImagePagesViewController.h"
#import "ASImage.h"
#import "ASCategoryVCLinkedList.h"
#import "ASSettingsTableViewController.h"
#import "ASDownloadManager.h"

@interface ASCategoriesPagesViewController ()

@property UIPageViewController *pageViewController;
@property ASCategoryVCLinkedList *categoriesLinkedList;

@end

@implementation ASCategoriesPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Custom back butotn
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Categories"] style:UIBarButtonItemStylePlain target:self action:@selector(goToCategories:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self  action:@selector(goToSettings:)];

    // Button gesture recognizers
    [self.nextButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToNextCategory:)]];
    [self.prevButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrevCategory:)]];

    // Create category controllers
    ASCategoryCollectionViewController *categoryVC = (ASCategoryCollectionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
    categoryVC.category = self.initialActiveCategory;
    categoryVC.delegate = self;
    self.categoriesLinkedList = [[ASCategoryVCLinkedList alloc] initWithCategoryVC:categoryVC categories:self.categories];

    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
#warning Disables swipe gestures
    //self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[self.categoriesLinkedList.categoryVC] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];

    // Add it as child
    [self.pageViewController willMoveToParentViewController:self];
    [self addChildViewController:self.pageViewController];

    [self.containerView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    // Add Contraints
    [self.pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.containerView addConstraints:@[
                                                   [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pageViewController.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                                   [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                                   [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.pageViewController.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                                   [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.pageViewController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                                   ]];

    // For easier swiping
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;

    // Buttons and title setup
    [self updateUI];
}

- (void)goToCategories:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
    [[ASDownloadManager sharedManager] cancelAllDownloadTasks];
    [self saveChangesForCategory:self.categoriesLinkedList.categoryVC.category];
}

- (void)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
}

- (void)updateState {
    ASCategory *oldCategory = self.categoriesLinkedList.categoryVC.category;

    // Change linked list to current VC
    ASCategoryCollectionViewController *activeVC = (ASCategoryCollectionViewController *)self.pageViewController.viewControllers.firstObject;
    if (self.categoriesLinkedList.next != nil && [self.categoriesLinkedList.next.categoryVC isEqual:activeVC]) {
        self.categoriesLinkedList = self.categoriesLinkedList.next;
    } else if (self.categoriesLinkedList.prev != nil && [self.categoriesLinkedList.prev.categoryVC isEqual:activeVC]) {
        self.categoriesLinkedList = self.categoriesLinkedList.prev;
    }

    // Update UI
    [self updateUI];

    // Save changes of previous category
    [self saveChangesForCategory:oldCategory];
}

- (void)saveChangesForCategory:(ASCategory *)category {
    [category.managedObjectContext performBlock:^{
        if ([category.managedObjectContext hasChanges] == true) {
            NSError *error;
            [category.managedObjectContext save:&error];
            if (error != nil) {
                NSLog(@"error saving context in view will disappear %@", error);
            } else {
                NSLog(@"saved %@ successfully", category.name);
            }
            if (category.state.integerValue != ASCategoryStateBusyRefreshing || category.state.integerValue != ASCategoryStateBusyGettingImages) [category.managedObjectContext refreshObject:category mergeChanges:false];
        }
    }];
}

- (void)updateUI {
    self.navigationItem.title = self.categoriesLinkedList.categoryVC.category.name;

    BOOL prevExists = (self.categoriesLinkedList.prev != nil);
    [self.prevButtonView setEnabled:prevExists];
    self.prevButtonView.nameLabel.text = prevExists ? self.categoriesLinkedList.prev.categoryVC.category.name.uppercaseString : @"";

    BOOL nextExists = (self.categoriesLinkedList.next != nil);
    [self.nextButtonView setEnabled:nextExists];
    self.nextButtonView.nameLabel.text = nextExists ? self.categoriesLinkedList.next.categoryVC.category.name.uppercaseString : @"";

    BOOL hideButtons = (prevExists == false && nextExists == false);
    self.nextButtonView.hidden = hideButtons;
    self.prevButtonView.hidden = hideButtons;
}

#pragma mark - UIPageViewController DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ASCategoryCollectionViewController *)viewController {
    ASCategoryVCLinkedList *next = self.categoriesLinkedList.next;
    return (next != nil) ? next.categoryVC : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ASCategoryCollectionViewController *)viewController {
    ASCategoryVCLinkedList *prev = self.categoriesLinkedList.prev;
    return (prev != nil) ? prev.categoryVC : nil;
}

#pragma mark - CategoryVC Navigation

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed == YES) [self updateState];
}

- (void)goToNextCategory:(id)sender {
    [self goToCategoryVC:self.categoriesLinkedList.next.categoryVC inDirection:UIPageViewControllerNavigationDirectionForward];
}

- (void)goToPrevCategory:(id)sender {
    [self goToCategoryVC:self.categoriesLinkedList.prev.categoryVC inDirection:UIPageViewControllerNavigationDirectionReverse];
}

- (void)goToCategoryVC:(ASCategoryCollectionViewController *)categoryVC inDirection:(UIPageViewControllerNavigationDirection)direction {
    __block ASCategoriesPagesViewController *blocksafeSelf = self;
    [self.pageViewController setViewControllers:@[categoryVC]
                                      direction:direction
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished == true) [blocksafeSelf updateState];
                                     }];
}

#pragma mark - CategoryCollectionVC Delegate

- (void)categoryImageWasSelected:(ASImage *)image {
    [self performSegueWithIdentifier:@"ShowImage" sender:image];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowImage"]) {
        ASImagePagesViewController *imagePagesVC = (ASImagePagesViewController *)segue.destinationViewController;
        ASImage *image = (ASImage *)sender;
        imagePagesVC.initialActiveImage = image;

    } else if ([segue.identifier isEqualToString:@"ShowSettings"]) {
        UINavigationController *navVC = (UINavigationController *)segue.destinationViewController;
        ASSettingsTableViewController *settingsVC = (ASSettingsTableViewController *)navVC.topViewController;
        settingsVC.store = self.initialActiveCategory.store;
    }
}

@end
