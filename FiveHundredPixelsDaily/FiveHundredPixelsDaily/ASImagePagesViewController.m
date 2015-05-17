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
#import "ASSettingsTableViewController.h"
#import "ASDownloadManager.h"

@interface ASImagePagesViewController () <UIAlertViewDelegate>

@property UIPageViewController *pageViewController;
@property ASImageVCLinkedList *imagesLinkedList;
@property NSMutableArray *downloadedImages;

@end

@implementation ASImagePagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Bar buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Thumbnails"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackToThumbnails:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self  action:@selector(goToSettings:)];

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
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{ UIPageViewControllerOptionInterPageSpacingKey: @(20.0) }];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[self.imagesLinkedList.imageVC] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];
    imageVC.view.gestureRecognizers = self.pageViewController.gestureRecognizers;

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

    // UI and Full image fetches
    [self updateState];
}

- (void)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
}

- (void)goBackToThumbnails:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
    [[ASDownloadManager sharedManager] cancelAllDownloadTasks];
    NSManagedObjectContext *moc = self.initialActiveImage.managedObjectContext;
    [moc performBlock:^{
        NSError *error;
        if ([moc hasChanges] == true) {
            [moc save:&error];
            if (error != nil) NSLog(@"error saving full images: %@", error);
        }
    }];
}

- (void)updateState {
    // Change linked list to current VC
    ASImageViewController *activeVC = (ASImageViewController *)self.pageViewController.viewControllers.firstObject;
    if (self.imagesLinkedList.next != nil && [self.imagesLinkedList.next.imageVC isEqual:activeVC]) {
        // Cancel previous
        if (self.imagesLinkedList.prev != nil) [self.imagesLinkedList.prev.imageVC.image cancelRequestIfNeeded];
        // Set new imageVC
        self.imagesLinkedList = self.imagesLinkedList.next;
        // Request next
        if (self.imagesLinkedList.next != nil) [self.imagesLinkedList.next.imageVC.image requestFullImageIfNeeded];

    } else if (self.imagesLinkedList.prev != nil && [self.imagesLinkedList.prev.imageVC isEqual:activeVC]) {
        // Cancel next
        if (self.imagesLinkedList.next != nil) [self.imagesLinkedList.next.imageVC.image cancelRequestIfNeeded];
        // Set new imageVC
        self.imagesLinkedList = self.imagesLinkedList.prev;
        // Request prev
        if (self.imagesLinkedList.prev != nil) [self.imagesLinkedList.prev.imageVC.image requestFullImageIfNeeded];
    }
    // Request current
    [self.imagesLinkedList.imageVC.image requestFullImageIfNeeded];

    // Update UI
    [self updateUI];
}

- (void)updateUI {
    self.navigationItem.title = self.imagesLinkedList.imageVC.image.name;

    BOOL imageAlreadyDownloaded = [self.downloadedImages containsObject:self.imagesLinkedList.imageVC.image];
    [self.downloadButtonView setEnabled:(imageAlreadyDownloaded == false)];

    BOOL prevExists = (self.imagesLinkedList.prev != nil);
    [self.prevButtonView setEnabled:prevExists];
    self.prevButtonView.nameLabel.text = prevExists ? self.imagesLinkedList.prev.imageVC.image.name.uppercaseString : @"";

    BOOL nextExists = (self.imagesLinkedList.next != nil);
    [self.nextButtonView setEnabled:nextExists];
    self.nextButtonView.nameLabel.text = nextExists ? self.imagesLinkedList.next.imageVC.image.name.uppercaseString : @"";

    BOOL hideButtons = (prevExists == false && nextExists == false);
    self.nextButtonView.hidden = hideButtons;
    self.prevButtonView.hidden = hideButtons;
}

- (void)downloadImage:(id)sender {
    NSString *albumName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbum"];
    if (albumName == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download album not selected" message:@"Please choose a Photos album to save photos to" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to Settings", nil];
        alertView.tintColor = [UIColor blackColor];
        [alertView show];
    } else {
        // Save image
        ASImage *image = self.imagesLinkedList.imageVC.image;
        [self.downloadedImages addObject:image];
        NSLog(@"downloaded");
        [self.downloadButtonView setEnabled:false];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveImageToPhotos" object:nil userInfo:@{ @"image": image.full }];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [self performSegueWithIdentifier:@"ShowSettings" sender:self];
    }
}

#pragma mark - UIPageViewController DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ASImageViewController *)viewController {
    ASImageVCLinkedList *next = self.imagesLinkedList.next;
    return (next != nil) ? next.imageVC : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ASImageViewController *)viewController {
    ASImageVCLinkedList *prev = self.imagesLinkedList.prev;
    return (prev != nil) ? prev.imageVC : nil;
}

#pragma mark - PageVC Navigation

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed == true) [self updateState];
}

- (void)goToPrevImage:(id)sender {
    [self goToImageVC:self.imagesLinkedList.prev.imageVC inDirection:UIPageViewControllerNavigationDirectionReverse];
}

- (void)goToNextImage:(id)sender {
    [self goToImageVC:self.imagesLinkedList.next.imageVC inDirection:UIPageViewControllerNavigationDirectionForward];
}

- (void)goToImageVC:(ASImageViewController *)imageVC inDirection:(UIPageViewControllerNavigationDirection)direction {
    __block ASImagePagesViewController *blockSafeSelf = self;
    [self.pageViewController setViewControllers:@[imageVC]
                                      direction:direction
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished == true) [blockSafeSelf updateState];
                                     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSettings"]) {
        UINavigationController *navVC = (UINavigationController *)segue.destinationViewController;
        ASSettingsTableViewController *settingsVC = (ASSettingsTableViewController *)navVC.topViewController;
        settingsVC.store = self.initialActiveImage.category.store;
    }
}

@end
