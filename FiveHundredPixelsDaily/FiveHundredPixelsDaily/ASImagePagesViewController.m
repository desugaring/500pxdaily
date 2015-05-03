//
//  ASImagePagesViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-19.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImagePagesViewController.h"
#import "ASImageViewController.h"
#import "ASImageVCLinkedList.h"

@interface ASImagePagesViewController ()

@property UIPageViewController *pageViewController;
@property ASImageVCLinkedList *imagesLinkedList;
@property NSMutableArray *downloadedImages;

@end

@implementation ASImagePagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Button gesture recognizers
    [self.nextButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToNextImage:)]];
    [self.prevButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrevImage:)]];
    [self.downloadButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadImage:)]];

    self.downloadedImages = [NSMutableArray new];

    // Create category controllers
    ASImageViewController *imageVC = (ASImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"FullImageVC"];
    imageVC.image = self.initialActiveImage;
    self.imagesLinkedList = [[ASImageVCLinkedList alloc] initWithImageVC:imageVC];

    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[self.imagesLinkedList.imageVC] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];

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

    // Button and title setup
    [self updateUI];
}

- (void)updateUI {
    self.navigationItem.title = self.imagesLinkedList.imageVC.image.name;

    // Update buttons
    if (self.imagesLinkedList.prev == nil) {
        self.prevButtonView.iconImageView.hidden = true;
        ((UIGestureRecognizer *)self.prevButtonView.gestureRecognizers.firstObject).enabled = false;
    } else {
        ((UIGestureRecognizer *)self.prevButtonView.gestureRecognizers.firstObject).enabled = true;
        self.prevButtonView.iconImageView.hidden = false;
    }

    if (self.imagesLinkedList.next == nil) {
        self.nextButtonView.iconImageView.hidden = true;
        ((UIGestureRecognizer *)self.nextButtonView.gestureRecognizers.firstObject).enabled = false;
    } else {
        ((UIGestureRecognizer *)self.nextButtonView.gestureRecognizers.firstObject).enabled = true;
        self.nextButtonView.iconImageView.hidden = false;
    }

    ((UIGestureRecognizer *)self.downloadButtonView.gestureRecognizers.firstObject).enabled = ([self.downloadedImages containsObject:self.imagesLinkedList.imageVC.image] == false);
}

- (void)downloadImage:(id)sender {
    [self.downloadedImages addObject:self.imagesLinkedList.imageVC.image];
    ((UIGestureRecognizer *)self.downloadButtonView.gestureRecognizers.firstObject).enabled = false;
}

#pragma mark - UIPageViewController DataSource


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed == YES) {
        ASImageViewController *newImageVC = (ASImageViewController *)self.pageViewController.viewControllers.firstObject;
        // Set pointer to current linked list item, either we went to previous or next item in the linked list, we check which way here
        self.imagesLinkedList = [self.imagesLinkedList.next.imageVC isEqual:newImageVC] ? self.imagesLinkedList.next : self.imagesLinkedList.prev;
        [self updateUI];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ASImageViewController *)viewController
{
    ASImageVCLinkedList *next = self.imagesLinkedList.next;

    return (next != nil) ? next.imageVC : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ASImageViewController *)viewController
{
    ASImageVCLinkedList *prev = self.imagesLinkedList.prev;

    return (prev != nil) ? prev.imageVC : nil;
}

- (void)goToPrevImage:(id)sender {
    ((UIGestureRecognizer *)self.prevButtonView.gestureRecognizers.firstObject).enabled = false;
    self.imagesLinkedList = self.imagesLinkedList.prev;

    [self.pageViewController setViewControllers:@[self.imagesLinkedList.imageVC]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
    [self updateUI];
}

- (void)goToNextImage:(id)sender {
    ((UIGestureRecognizer *)self.nextButtonView.gestureRecognizers.firstObject).enabled = false;
    self.imagesLinkedList = self.imagesLinkedList.next;

    [self.pageViewController setViewControllers:@[self.imagesLinkedList.imageVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
