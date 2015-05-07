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

@interface ASCategoriesTableViewController()

@property NSMutableArray *selectedCategories;
@property NSUInteger categoriesCount;

@end

@implementation ASCategoriesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self  action:@selector(goToSettings:)];
    self.categoriesCount = self.store.categories.count;
    self.selectedCategories = [NSMutableArray arrayWithCapacity:self.categoriesCount];
    for (ASCategory *category in self.store.categories) {
        if (category.isActive.boolValue == true) [self.selectedCategories addObject:category];
    }
}

- (void)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"ShowSettings" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categoriesCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category" forIndexPath:indexPath];

    ASCategory *category = (ASCategory *)self.store.categories[indexPath.row];
    [cell configureCellWithCategory:category];
    cell.delegate = self;
    if ([self.selectedCategories containsObject:category] == true) [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCategory *category = ((ASCategoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).category;
    [self.selectedCategories addObject:category];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCategory *category = ((ASCategoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).category;
    [self.selectedCategories removeObject:category];
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
