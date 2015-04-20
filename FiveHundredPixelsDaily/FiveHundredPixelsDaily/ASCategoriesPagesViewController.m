//
//  ASCategoriesPagesViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-18.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoriesPagesViewController.h"

@interface ASCategoriesPagesViewController ()

@end

@implementation ASCategoriesPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)goToPrevCategory:(id)sender {
}

- (IBAction)goToNextCategory:(id)sender {
}

#pragma mark - CategoryCollectionVC Delegate

- (void)categoryImageWasSelected:(ASImage *)image {
    [self performSegueWithIdentifier:@"ShowImage" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowImage"]) {
        <#statements#>
    }
}

@end
