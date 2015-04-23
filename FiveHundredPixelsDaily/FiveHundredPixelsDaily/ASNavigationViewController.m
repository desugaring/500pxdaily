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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBarsOnTap {
    return [self.topViewController isKindOfClass:[ASImagePagesViewController class]] == false;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
