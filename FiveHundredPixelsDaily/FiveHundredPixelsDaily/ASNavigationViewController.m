//
//  ASNavigationViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-22.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASNavigationViewController.h"
#import "ASImagePagesViewController.h"

@interface ASNavigationViewController ()

@end

@implementation ASNavigationViewController

- (BOOL)hidesBarsOnTap {
    return [self.topViewController isKindOfClass:[ASImagePagesViewController class]] == false;
}

@end
