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

@interface ASCategoriesPagesViewController ()

@property UIPageViewController *pageViewController;
@property NSMutableOrderedSet *categoryControllers;

@end

@implementation ASCategoriesPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.initialActiveCategory.name;

    // Create category controllers
    ASCategoryCollectionViewController *initialPageVC;

    self.categoryControllers = [NSMutableOrderedSet new];
    for (ASCategory *category in self.categories) {
        ASCategoryCollectionViewController *categoryVC = (ASCategoryCollectionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CategoryCollectionVC"];
        categoryVC.delegate = self;
        categoryVC.category = category;

        [self.categoryControllers addObject:categoryVC];

        if ([category isEqual:self.initialActiveCategory] == true) initialPageVC = categoryVC;
    }

    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[initialPageVC] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];

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
}

#pragma mark - UIPageViewController DataSource

- (void)categoryChangedTo:(ASCategory *)category {
    self.navigationItem.title = category.name;

    // Update buttons
    NSUInteger activeCategoryIndex = [self.categories indexOfObject:category];

    if (activeCategoryIndex == 0) {
        [self.prevCategoryButton setTitle:@"" forState:UIControlStateNormal];
        self.prevCategoryButton.enabled = false;
    } else {
        [self.prevCategoryButton setTitle:((ASCategory *)self.categories[activeCategoryIndex-1]).name forState:UIControlStateNormal];
        self.prevCategoryButton.enabled = true;
    }

    if (activeCategoryIndex == self.categories.count-1) {
        [self.nextCategoryButton setTitle:@"" forState:UIControlStateNormal];
        self.nextCategoryButton.enabled = false;
    } else {
        [self.nextCategoryButton setTitle:((ASCategory *)self.categories[activeCategoryIndex+1]).name forState:UIControlStateNormal];
        self.nextCategoryButton.enabled = true;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed == YES) {
        ASCategory *activeCategory = ((ASCategoryCollectionViewController *)self.pageViewController.viewControllers.firstObject).category;
        [self categoryChangedTo:activeCategory];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ASCategoryCollectionViewController *)viewController
{
    NSUInteger index = [self.categories indexOfObject:viewController.category];

    if (index == [self.categories count]-1) return nil;

    return self.categoryControllers[index+1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ASCategoryCollectionViewController *)viewController
{
    NSUInteger index = [self.categories indexOfObject:viewController.category];

    if (index == 0) return nil;

    return self.categoryControllers[index-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToPrevCategory:(id)sender {
    ASCategoryCollectionViewController *activeVC = self.pageViewController.viewControllers.firstObject;
    NSUInteger index = [self.categories indexOfObject:activeVC.category];

    [self.pageViewController setViewControllers:@[self.categoryControllers[index-1]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];

    [self categoryChangedTo:self.categories[index-1]];
}

- (IBAction)goToNextCategory:(id)sender {
    ASCategoryCollectionViewController *activeVC = self.pageViewController.viewControllers.firstObject;
    NSUInteger index = [self.categories indexOfObject:activeVC.category];

    [self.pageViewController setViewControllers:@[self.categoryControllers[index+1]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];

    [self categoryChangedTo:self.categories[index+1]];
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
        imagePagesVC.activeImage = image;
    }
}

@end
