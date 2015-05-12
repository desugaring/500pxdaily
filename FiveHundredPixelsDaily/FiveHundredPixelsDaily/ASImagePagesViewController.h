//
//  ASImagePagesViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-19.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASImage.h"
#import "ASButtonView.h"

@interface ASImagePagesViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak) ASImage *initialActiveImage;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet ASButtonView *downloadButtonView;
@property (weak, nonatomic) IBOutlet ASButtonView *prevButtonView;
@property (weak, nonatomic) IBOutlet ASButtonView *nextButtonView;

- (void)downloadImage:(id)sender;
- (void)goToPrevImage:(id)sender;
- (void)goToNextImage:(id)sender;

@end
