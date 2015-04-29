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

@interface ASCategoriesPagesViewController ()

@property UIPageViewController *pageViewController;
@property ASCategoryVCLinkedList *categoriesLinkedList;

@end

@implementation ASCategoriesPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Background image
//    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DarkScratch"]];
//    bgView.frame = self.view.bounds;
//    bgView.contentMode = UIViewContentModeTopLeft;
//    bgView.alpha = 0.7;
//    [self.view insertSubview:bgView atIndex:0];

    // Create category controllers
    ASCategoryCollectionViewController *categoryVC = (ASCategoryCollectionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
    categoryVC.category = self.initialActiveCategory;
    categoryVC.delegate = self;
    self.categoriesLinkedList = [[ASCategoryVCLinkedList alloc] initWithCategoryVC:categoryVC categories:self.categories];

    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
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

- (void)updateUI {
    self.navigationItem.title = self.categoriesLinkedList.categoryVC.category.name;

    // Update buttons
    if (self.categoriesLinkedList.prev == nil) {
        [self.prevCategoryButton setTitle:@"" forState:UIControlStateNormal];
        self.prevCategoryButton.enabled = false;
    } else {
        [self.prevCategoryButton setTitle:(self.categoriesLinkedList.prev).categoryVC.category.name forState:UIControlStateNormal];
        self.prevCategoryButton.enabled = true;
    }

    if (self.categoriesLinkedList.next == nil) {
        [self.nextCategoryButton setTitle:@"" forState:UIControlStateNormal];
        self.nextCategoryButton.enabled = false;
    } else {
        [self.nextCategoryButton setTitle:(self.categoriesLinkedList.next).categoryVC.category.name forState:UIControlStateNormal];
        self.nextCategoryButton.enabled = true;
    }
}

#pragma mark - UIPageViewController DataSource


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed == YES) {
        ASCategoryCollectionViewController *newCategoryVC = (ASCategoryCollectionViewController *)self.pageViewController.viewControllers.firstObject;
        // Set pointer to current linked list item, either we went to previous or next item in the linked list, we check which way here
        self.categoriesLinkedList = [self.categoriesLinkedList.next.categoryVC isEqual:newCategoryVC] ? self.categoriesLinkedList.next : self.categoriesLinkedList.prev;
        [self updateUI];
    }

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ASCategoryCollectionViewController *)viewController
{
    ASCategoryVCLinkedList *next = self.categoriesLinkedList.next;

    return (next != nil) ? next.categoryVC : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ASCategoryCollectionViewController *)viewController
{
    ASCategoryVCLinkedList *prev = self.categoriesLinkedList.prev;

    return (prev != nil) ? prev.categoryVC : nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToPrevCategory:(UIButton *)sender {
    self.prevCategoryButton.enabled = false;
    self.categoriesLinkedList = self.categoriesLinkedList.prev;

    [self.pageViewController setViewControllers:@[self.categoriesLinkedList.categoryVC]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
    [self updateUI];
}

- (IBAction)goToNextCategory:(UIButton *)sender {
    self.nextCategoryButton.enabled = false;
    self.categoriesLinkedList = self.categoriesLinkedList.next;

    [self.pageViewController setViewControllers:@[self.categoriesLinkedList.categoryVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    [self updateUI];
}

#pragma mark - CategoryCollectionVC Delegate

- (void)categoryImageWasSelected:(ASImage *)image {
    [self performSegueWithIdentifier:@"ShowImage" sender:image];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
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
