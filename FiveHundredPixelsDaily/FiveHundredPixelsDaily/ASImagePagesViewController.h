//
//  ASImagePagesViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-19.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASImage.h"

@interface ASImagePagesViewController : UIViewController

@property (weak) ASImage *activeImage;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)downloadImage:(UIButton *)sender;

@end
