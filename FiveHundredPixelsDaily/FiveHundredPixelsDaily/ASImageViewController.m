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

@end

@implementation ASImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.image.full == nil) {
        self.image.delegate = self;
        [self.image requestFullImageIfNeeded];
        [self.spinner startAnimating];
    } else if (self.imageView == nil) {
        [self updateImage];
    }
    NSLog(@"wil lappear %@", self.image.name);
}

-(void)viewWillLayoutSubviews {
    [self.view layoutIfNeeded];
}

- (void)updateImage {
    [self.spinner stopAnimating];

    self.imageView = [[UIImageView alloc] initWithImage:self.image.full];
    self.scrollView.contentSize = self.image.full.size;
    [self.scrollView addSubview:self.imageView];

    [self centerAndScaleImageWithSize:self.view.bounds.size];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"size is %f %f", size.width, size.height);
        [self centerAndScaleImageWithSize:size];
    } completion:nil];
}

// Make sure you use Editor->Pin->Top Space and Bottom Space in Storyboard for the scrollview
// or else you'll have screwed up view bounds on viewWillAppear and viewDidLoad
- (void)centerAndScaleImageWithSize:(CGSize)size {
    self.scrollView.zoomScale = 1.0;
    float minWidth = size.width / self.scrollView.contentSize.width;
    float minHeight = size.height / self.scrollView.contentSize.height;

    float minScale = MIN(minWidth, minHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.zoomScale = minScale;
    self.scrollView.tileContainerView = self.imageView;
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
