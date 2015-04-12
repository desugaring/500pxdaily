//
//  BottomNavImageViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomNavImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

// Protocol BottomNavImageDelegate