//
//  ASImageViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASImage.h"
#import "ASCategory.h"

@interface ASImageViewController : UIViewController <ASImageDelegate, UIScrollViewDelegate>

@property (weak) ASImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (void)imageFullUpdated:(ASImage *)image;

@end
