//
//  ASCategoriesTableViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoriesTableViewController.h"
#import "ASCategory.h"
#import "ASCategoryTableViewCell.h"
#import "ASCategoriesPagesViewController.h"
#import "ASSettingsTableViewController.h"

@implementation ASCategoriesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self  action:@selector(goToSettings:)];
}

- (void)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.store.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category" forIndexPath:indexPath];

    [cell configureCellWithCategory:(ASCategory *)self.store.categories[indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Select the categories you're interested in viewing";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    headerView.textLabel.textColor = [UIColor whiteColor];
    headerView.backgroundView.backgroundColor = [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1.0];
}

#pragma mark - CategoryTableViewCell Delegate

- (void)goToCategory:(ASCategory *)category {
    [self performSegueWithIdentifier:@"ShowPages" sender:category];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPages"]) {
        ASCategoriesPagesViewController *categoriesPagesVC = (ASCategoriesPagesViewController *)segue.destinationViewController;
        categoriesPagesVC.categories = [self.store activeCategories];

        categoriesPagesVC.initialActiveCategory = (ASCategory *)sender;
    } else if ([segue.identifier isEqualToString:@"ShowSettings"]) {
        UINavigationController *navVC = (UINavigationController *)segue.destinationViewController;
        ASSettingsTableViewController *settingsVC = (ASSettingsTableViewController *)navVC.topViewController;
        settingsVC.store = self.store;
    }
}

@end
