//
//  ASImageViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImageViewController.h"

@interface ASImageViewController()

@property UIImageView *imageView;
@property CGSize scrollViewSize;

@end

@implementation ASImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollViewSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height);

    if(self.image.full == nil) {
        self.image.delegate = self;
        [self.image requestFullImageIfNeeded];
        [self.spinner startAnimating];
    } else if (self.imageView == nil) {
        [self updateImage];
    }
    NSLog(@"scroll frame w: %f, h: %f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    NSLog(@"scroll bounds w: %f, h: %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSLog(@"view frame w: %f, h: %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"view bounds w: %f, h: %f", self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)updateImage {
    [self.spinner stopAnimating];

    self.imageView = [[UIImageView alloc] initWithImage:self.image.full];
    //    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image.full.size;
    [self.scrollView addSubview:self.imageView];

    [self centerAndScaleImageWithSize:self.scrollViewSize];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"size is %f %f", size.width, size.height);
        [self centerAndScaleImageWithSize:size];
    } completion:nil];
}

- (void)centerAndScaleImageWithSize:(CGSize)size {
    // Zoom level
    self.scrollView.zoomScale = 1.0;
    float minWidth = size.width / self.scrollView.contentSize.width;
    float minHeight = size.height / self.scrollView.contentSize.height;

    float minScale = MIN(minWidth, minHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.5;
    self.scrollView.zoomScale = minScale;
    self.scrollView.tileContainerView = self.imageView;
    // Center
//    self.imageView.center = CGPointMake(size.width/2, size.height/2);
//    NSLog(@"center w: %f, h: %f", self.imageView.center.x, self.imageView.center.y);
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollView.subviews.lastObject;
}

#pragma mark - ASImage Delegate

- (void)imageFullUpdated:(ASImage *)image {
    if (self.imageView == nil) [self updateImage];
}

@end
