//
//  ASImageViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImageViewController.h"

@interface ASImageViewController ()

@end

@implementation ASImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.image.full != nil) {
        [self updateImage];
    } else {
        self.image.delegate = self;
        [self.image requestFullImageIfNeeded];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self centerAndScaleImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateImage {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image.full];
    //    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image.full.size;
    [self.scrollView addSubview:imageView];

    imageView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 1;
        self.spinner.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished == true) [self.spinner stopAnimating];
    }];

    [self centerAndScaleImage];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//
//    [self centerAndScaleImage];
//}

- (void)centerAndScaleImage {
    // Zoom level
    CGRect scrollViewFrame = self.scrollView.bounds;
    float minWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    float minHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;

    float minScale = MIN(minWidth, minHeight);
    self.scrollView.minimumZoomScale = minScale;

    self.scrollView.zoomScale = minScale;
    

    // Center
    UIImageView *imageView = (UIImageView *)self.scrollView.subviews.lastObject;
//    CGPoint newPoint = [self.scrollView convertPoint:self.scrollView.center toCoordinateSpace:imageView.window.screen.fixedCoordinateSpace];
    NSLog(@"view center: %@", NSStringFromCGPoint(self.view.center));
    ((UIImageView *)self.scrollView.subviews.lastObject).center = self.view.center;
//    CGFloat scrollContentWidth = self.scrollView.contentSize.width;
//    CGFloat scrollContentHeight = self.scrollView.contentSize.height;
//
//    CGFloat offsetX = (self.scrollView.bounds.size.width > scrollContentWidth)?
//    (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
//
//    CGFloat offsetY = (self.scrollView.bounds.size.height > scrollContentHeight)?
//    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
//
//    self.imageView.center = CGPointMake(scrollContentWidth * 0.5 + offsetX,
//                                        scrollContentHeight * 0.5 + offsetY);
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollView.subviews.lastObject;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ASImage Delegate

- (void)imageFullUpdated:(ASImage *)image {
    NSLog(@"got image, need to show");
    [self updateImage];
}

@end
