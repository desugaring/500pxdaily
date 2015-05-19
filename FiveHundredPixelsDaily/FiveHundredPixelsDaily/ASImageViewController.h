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
#import "ASCenteredScrollView.h"

@interface ASImageViewController : UIViewController <ASImageDelegate, UIScrollViewDelegate>

@property (weak) ASImage *image;
@property (weak, nonatomic) IBOutlet ASCenteredScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (void)imageFullUpdated:(ASImage *)image withTask:(NSURLSessionDownloadTask *)task;

@end
